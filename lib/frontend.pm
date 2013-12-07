package frontend;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::Email;
use Dancer::Plugin::Cache::CHI;
use Try::Tiny;
use XML::RSS;
use LWP::Simple ();

use frontend::comment;
use frontend::daily_mail;
use frontend::flick;
use frontend::page;
use frontend::popular;
use frontend::tag;
use frontend::writing;

our $VERSION = '0.1';

prefix undef;

check_page_cache;

get '/' => sub {
    cache_page template 'index', {
      active_nav => 'Home',
			title => "127.0.0.1",
			description => "The lair of the ciderpunx",
		};
};

get '/about.pl' => sub {
	redirect uri_for '/about'
};

get '/about/?' => sub {
    template 'about', {
      active_nav => 'About',
			title => "About",
			description => "About Charlie Harvey and about charlieharvey.org.uk. Blah, blah, blah.",
		};
};

get '/about/charlie-harvey/?' => sub {
    template 'about-charlie', {
      active_nav => 'About',
			title => "About Charlie",
			description => "About Charlie Harvey. Cider, geekery, perl and navel gazing",
		};
};

get '/about/this-site/?' => sub {
    template 'about-site', {
      active_nav => 'About',
			title => "About charlieharvey.org.uk",
			description => "About Charlie Harvey's website, charlieharvey.org.uk. Standards-compliant, fully responsive navel 
			                gazing. ",
		};
};

get '/archive/?' => sub {
		redirect uri_for('/page/index/archive/1');
};

get '/daily_mail.pl' => sub {
		redirect uri_for('/daily_mail/');
};

get '/flick.pl' => sub {
		redirect uri_for('/flick/');
};

get '/mills_boon.pl' => sub {
	redirect uri_for '/mills_and_boon'
};

get '/mills_and_boon/?' => sub {
	my @errors = ();
	my $rss = new XML::RSS;
	my $feed ='';
 
	my $content = LWP::Simple::get('http://www.millsandboon.co.uk/rss/onlineread.xml');
	unless ($content) { 
		push @errors, "Could not retrieve feed";
	}	
	unless ($rss->parse($content)) {
		push @errors, "Could not parse feed"; 
	}
 
	# get last 7 channel items, skip chapter names and concat together
	my $i=0;
	my $last = $#{$rss->{items}};
	$last = 7 if $last>7; 
	foreach my $item (@{$rss->{'items'}}) {
		$i++;
		next unless (defined($item->{'description'}));
		next if($item->{'title'} =~ /^ADV: /); #ad filter
		last if($i>$last); # no more than $last stories please.
		$feed.=$item->{'description'};
	}

	$feed =~ s{<(/?p)>}{[$1]}g;	  # keep p tags
	$feed =~ s{</?[^>]+>}{}g;     # lose the rest
	$feed =~ s{\[(/?p)\]}{<$1>}g;	# put ps back
	# Converts chrs beyond 127 to html entities
	$feed =~ s{([^\x20-\x7F])}{'&#' . ord($1) . ';'}gse;
	$feed =~ s{&#8217;}{'}g; # fucking "smart" quotes

	if ($feed && !@errors) {
		my $story = _to_markov($feed);
		template 'mills_boon', {
			title => 'Throbbing manhood',
			description => 'This page first of all grabs Mills and Boon&#8217;s online read rss. 
											Then it uses a simple markov chain to build a statistically probable 
											Mills and Boon story.',
			story => $story,
		}	
	}
	else {
		template 'mills_boon', {
			title => "Fuck. Something went wrong",
			errors => \@errors,
			description => "Afraid something broke",
		};
	}
};

get '/most_popular.pl' => sub {
	redirect uri_for '/popular/week'
};

get '/rot13.pl' => sub {
	redirect uri_for '/rot13'
};

get '/rot13' => sub {
	my $rot13ed = _rot13(params->{rot13}) || '';
	template 'rot13', {
			title => "ROT13 tool",
			description => "Lets you ROT13 or unROT13 arbitrary text strings.",
			rot13 => $rot13ed,
	}
};

get '/rot13/api/:to_rot' => sub { 
	set serializer => 'mutable';
	return {msg => _rot13(params->{to_rot}) || ''};
}; 

get '/rss.pl' => sub {
	redirect uri_for '/newsfeed'
};

## TODO: need a better search tool than swifttype for search.
get '/search/?' => sub {
    template 'search', {
			title => "Search Results",
			description => "Search results page on charlieharvey.org.uk",
		};
};

get '/tagcloud/?' => sub {
	redirect uri_for '/tag/cloud'
};

get '/twitterhaiku.pl' => sub {
	template 'twitterhaiku', {
		title => 'MOTHBALLED: Twitter haiku',
		desctiption => 'Twitter Haiku was  
										Wonderous. Twitter axed their feed.
										Poetry no more.'
	}
};

get '/writings/?' => sub {
	redirect uri_for '/file'
};

get '/writings.pl' => sub {
	redirect uri_for '/file'
};

get '/contact/?' => sub {
    template 'contact', {
      active_nav => 'About',
			title => "Contact me",
			description => "Contact Charlie Harvey",
			referer => request->referer,
			useragent => request->user_agent,
			remote_host => request->remote_address,
		};
};

post '/contact' => sub {
	my $sender = params->{sender};
	my $body = params->{body};
	$sender    =~ s/%40/@/;
	$body      =~ s/\+/ /gs;
	$body      =~ s/%([a-f0-9]{2})/chr(hex($1))/gei;

	my @seo_spammers = ('stellaseo5@gmail.com'
		, 'donnagabriel'
		, 'ramonelliot\d+@gmail.com'
    , 'ivanballard.*@gmail.com'
    , 'stellafair\d+@gmail.com'
	);

	my @errors;

	unless ($body) {
		push @errors, "Body is empty";
	}
	unless ($sender) {
		push @errors, "Email is empty"
	}
	if (grep {$sender =~ /$_/gi} @seo_spammers) {
	  sleep 10;
		push @errors,"You are a spammer"
	}
		
	if(@errors) {
		template 'contact', {
      active_nav => 'About',
			title => "Contact me",
			errors => \@errors,
			body => $body,
			sender => $sender,
			referer => request->referer,
			useragent => request->user_agent,
			remote_host => request->remote_host,
		};
	}
	else {
		_email_charlie($sender,$body);
		template 'contact_success', { 
      active_nav => 'About',
			title => "Thanks for your email",
			body => $body,
			sender => $sender,
			success => "Your email was sent. Thanks $sender :-)"
		}
	}
};

# Flush the CHI cache. 
get '/flush' => sub { cache_clear };


# this takes care of 404s and should be the last route.
any qr{.*}  => sub {
  status 'not_found';
	template '404', {
		title => 'Not Found -- Error 404',
		description => 'Seriously, this is a 404 page. Why are you even indexing this?'
	};
};

### Helper functions

sub _email_charlie {
	my ($sender,$body) = @_;
	 try {
        email {
					from    => $sender,
					to      => config->{'DEFAULT_EMAIL'},
					subject => 'charlieharvey.org.uk-contact.pl',
					body    => $body, 
				}
	 }
	 catch {
		error "Something went wrong when sending email"
	 }
}

sub _rot13 {
	my $to_return=shift || '';
	$to_return =~ tr |A-Za-z|N-ZA-Mn-za-m|;
	return $to_return;
}

sub _get_mills_boon_feed {
}

sub _to_markov {
	my $MAX = 300; # max number of words in story.
	my $feed_content = shift;
	my %table;
	my @result;
	my $w1 = my $w2 = my $NL = "<br />";
	foreach(split /\s+/,$feed_content) {
		push (@{$table{$w1}{$w2}},$_);
		($w1,$w2)=($w2,$_);
	}
	$w1=$w2=$NL;
	for(my $i=0;$i<$MAX;$i++) {
		my $suf=$table{$w1}{$w2};
		if($suf) {
			my $r=int(rand @$suf);
			last if((my $t=$suf->[$r]) eq $NL);
			push @result,$t;
			($w1,$w2)=($w2,$t);
		}
	}
	push @result, $NL;
	return join ' ', @result;
}



true;
