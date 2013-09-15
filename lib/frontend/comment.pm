package frontend::comment;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;
use Net::Akismet;
use HTML::Entities;
use HTML::Parser; ## needed for TagFilter, which calls SUPER on it.
use HTML::TagFilter;
use LWP::UserAgent;
use URI::Escape;

prefix '/comment';

get '/' => sub {
	redirect uri_for('comment/archive/1');
};

get '/archive/:page' => sub {
	my $page = params->{page} || 1;
	my $comments_rs  = _get_comment_archive();
	my $comments_obj = $comments_rs->page($page);
	my @comments     = $comments_obj->all;
	template 'comment/list', {
	  title => "All comments on all articles on charlieharvey.org.uk.",
		pager => $comments_obj->pager,
		page_offset => $page,
		comments => \@comments,
	};
};

get '/api/recent' => sub {
	# list of most recent 10 comments as rss list
	# each one is called an item and has a link,
	# description, title, summary
	set serializer => 'mutable';
	my $comments_rs  = _get_comment_archive();
	my @cs = $comments_rs->page(1)->all;
	my @comments = map {
			title => $_->title,
			url => $_->url,
			link => uri_for($_->link)->as_string,
			id  => $_->id,
			nick => $_->nick,
			body => $_->body,
			created_at => $_->updated_at->ymd,
		}, @cs;
	return {comments => \@comments}
};

get '/api/:id' => sub {
	set serializer => 'mutable';
	my $comment = _get_comment_by_id(params->{id});
	if(!$comment) {
		send_error("Couldn't find comment with id" . params->{id});
		return
	}
	return {comment => { 
		id => $comment->id,
		nick => $comment->nick,
		body => $comment->body,
		created_at => $comment->updated_at->ymd,
		title => $comment->title,
		url => $comment->url,
		link => uri_for($comment->link)->as_string,
	}}
};

get '/feed/?' => sub {
	redirect uri_for "/comment/feed/rss"
};

get '/feed/:format' => sub {
	my $comments_rs  = _get_comment_archive();
	my @cs = $comments_rs->page(1)->all;
	my $format = params->{format};
	if(uc $format ne 'RSS' && uc $format ne 'ATOM') {
		send_error("Bad feed format. RSS or Atom.");
		return
	}
	my $feed = create_feed( 
    format => params->{format}, #Feed format (RSS or Atom) 
    title => 'Recent comments on charlieharvey.org.uk',
		description => "You can find out the random things that people say on the internets",
		image => {
			title => "charlieharvey.org.uk comments feed", 
			width => 240,
			height => 45,
			url    => "/graphics/minilogo.png",
			link   => uri_for("/comments"),
		},
    entries => [ map { 
			title   => $_->title || "Untitled", 
			link    => uri_for($_->link)->as_string,
			author  => $_->nick,
			content => $_->body,
			issued  => $_->updated_at,
		}, @cs ], #makes collection of feed entries
  );
  return $feed;
};

get '/create' => sub {
  template 'comment/create', { 
		title => "Add your comment", 
	};
};

post '/create' => sub {
  my $no_html    = HTML::TagFilter->new({allow=>{}});
  my $min_html   = HTML::TagFilter->new();
	my $page_id    = $no_html->filter(_char_clean(params->{page_id},20)); #TODO and writing_id?
	my $email      = $no_html->filter(_char_clean(params->{email},250));
	my $ctitle     = $no_html->filter(_char_clean(params->{ctitle},250));
	my $body       = $min_html->filter(substr(params->{body}, 0, 2500));
	my $nick       = $no_html->filter(_char_clean(params->{nick},140));
	my $url        = $no_html->filter(_char_clean(params->{url},250));

	my $referer    = request->referer;
	my $remote     = request->remote_address;
	my $user_agent = request->user_agent;
  my @errors;
	
	if (!$remote) {
		push @errors, "Missing remote address. It is required for antispam measures. Sorry."; 
	}
	elsif (length $body  < 50) {
		push @errors, "I don&#8217;t accept super short comments as they are often spammy.";
	}
	elsif (  _botscout_lookup( $email, $remote )
        || _stopforumspam_lookup( $email, $remote )
        || _akismet_lookup( $email, $remote, $user_agent, $referer, $body, $nick, $url )) {
		sleep 30; 
		push @errors, "You look to me like a spammer. Maybe you are, maybe you&#8217;re not but that is how it looks."; 
	}
	# count a hrefs
	my $count = 0;
	while ($body =~ /a\s+href/g) {$count++} 
	if ($count > 2) {
		sleep 30;
		push @errors, "Your email looked spammy. Maybe there were lots of links in it or something like that?"
	}

	if (@errors) {
		template 'comment/create', {
			title => "Add your comment",
			errors => \@errors,
			body => $body,
			email => $email,
			ctitle => $ctitle,
			nick => $nick,
			url => $url,
			page_id => $page_id,
		};
	}
	else {
		# publish the comment
		_create_comment({
			ctitle	=> $ctitle, 
			email		=> $email,
			nick		=> $nick,
			url			=> $url,
			body		=> $body,
			page_id => $page_id,
		});
		template 'comment/create_success', {
			title => "Comment added",
			msg => "Thanks for taking the time to comment :-)",
			page_id => $page_id,
		};
	}
};

get '/:id' => sub {
	my $comment = _get_comment_by_id(params->{id});
	if(!$comment) {
			redirect '/404';
			return
	}
	my $author = $comment->nick || "Anonymous coward";
	template 'comment/view', { 
			comment => $comment, 
			title => $comment->title
							 . ". A comment by "
							 . $author
							 . " with id "
							 . $comment->id,
			description => $comment,
	}; 
};

###

sub _get_comment_by_id {
	my $id = shift;
  my $schema = schema 'frontend';
	my $comment = $schema->resultset('Comment')->find({id => $id});
	return $comment;
}

sub _get_comment_archive {
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Comment')->search({}, {order_by => {-desc => 'updated_at'}});
    return $results;
}

sub _char_clean {
	my ($str,$maxlen) = @_;
	return substr(encode_entities($str),0,$maxlen);
}

sub _botscout_lookup {
	my ($email, $remote) = (shift,shift);
	my $botscout_query   = "http://botscout.com/test/?multi&mail="
												 . uri_escape($email)
												 . "&ip=$remote&key="
											   . config->{BOTSCOUT_KEY};
  my $botscout_result  = _retrieve($botscout_query);
  my $botscout_verdict = substr $botscout_result, 0, 1;
	return 1 if ('Y' eq $botscout_verdict);
}

sub _stopforumspam_lookup {
	my ($email, $remote) = @_;
	my $stopforumspam_query = "http://www.stopforumspam.com/api?email="
														. uri_escape($email)
														. "&ip=$remote";
	my $stopforumspam_result = _retrieve($stopforumspam_query);
  $stopforumspam_result =~ s/.*<appears>(yes|no)<\/appears>.*/$1/ig;
  return 1 if ('yes' eq $stopforumspam_result); 
}

sub _akismet_lookup {
    my ($email, $remote, $user_agent, $referrer, $body, $nick, $url) = @_;
    my $akismet = Net::Akismet->new(
        KEY => config->{AKISMET_KEY},
        URL => config->{AKISMET_URL},
    ) or die('Key verification failure!');    # prolly better not die!

    my $akismet_verdict = $akismet->check(
        USER_IP              => $remote,
        COMMENT_USER_AGENT   => $user_agent,
        COMMENT_TYPE         => 'comment',
        COMMENT_CONTENT      => $body,
        COMMENT_AUTHOR       => $nick,
        COMMENT_AUTHOR_EMAIL => $email,
        COMMENT_AUTHOR_URL   => $url,
        REFERRER             => $referrer,
    );

		return 1 if ('true' eq $akismet_verdict);
}

sub _create_comment {
	my $argref = shift;
  my $schema = schema 'frontend';
	my $new_comment = $schema->resultset('Comment')->new({ 
			title => $argref->{ctitle},
			body  => $argref->{body},
			email => $argref->{email},
			nick  => $argref->{nick},
			url   => $argref->{url},
	});
	my $page = $schema->resultset('Page')->find({ id => $argref->{page_id}});
  $new_comment->add_to_page($page);
	$new_comment->insert;
}

sub _retrieve {
	my $url = shift;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get($url);
	if($response->is_success) {
    return $response->decoded_content;
	}
}
