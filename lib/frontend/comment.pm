package frontend::comment;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Net::Akismet;
use HTML::TagFilter;
use LWP::UserAgent;

prefix '/comment';

# TODO investigate mutable views.

get '/archive/:page' => sub {
	# paged list of all comments
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

get '/feed' => sub {
	# list of most recent 10 comments as rss list
	# each one is called an item and has a link,
	# description, title, summary
};

get '/:id' => sub {
	my $comment = _get_comment_by_id(params->{id});
	if(!$comment) {
			redirect '/404'
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

get '/create' => sub {

};

post '/create' => sub {
  my $no_html    = HTML::TagFilter->new(allow=>{});
  my $min_html   = HTML::TagFilter->new();
	my $page_id    = $no_html->filter(_char_clean(params->{page_id},20)); #TODO and writing_id?
	my $email      = $no_html->filter(_char_clean(params->{email},250));
	my $ctitle     = $no_html->filter(_char_clean(params->{title},250));
	my $body       = $min_html->filter(_char_clean(params->{body}, 2500));
	my $nick       = $no_html->filter(_char_clean(params->{nick},140));
	my $url        = $no_html->filter(_char_clean(params->{url},250));

	my $referer    = request->referer;
	my $remote     = request->remote_host;
	my $user_agent = request->user_agent;

  my @errors = "";

	unless ($remote && $user_agent) { # REQUIRED
		error "Missing remote or UA";
		push @errors, "Missing remote or UA"; 
	}

	# check email against spam lists
	if( (length $body < 50)
		 || _botscout_lookup($email,$remote) 
	   || _stopforumspam_lookup($email,$remote) 
	   || _akismet_lookup($email, $remote, $user_agent, $referer, $body, $nick, $url)) {
		sleep 30;
		# redirect back to the form		
		push @errors, "You look to me like a spammer. Maybe you are, maybe you&#8217;re not but that is how it looks."; 
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
		template 'comment/create_success', {
			title => "Comment added",
			msg => "Thanks for taking the time to comment :-)",
			page_id => $page_id,
		};
	}

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
	my ($maxlen, $str) = @_;
  substr(encode_entities($str, '^\n\x20-\x25\x27-\x7e'),0,$maxlen);
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
        KEY => config->{akismet_key},
        URL => config->{akismet_url},
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
}

sub _retrieve {
	my $url = shift;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get($url);
	if($response->is_success) {
    return $response->decoded_content;
	}
}
