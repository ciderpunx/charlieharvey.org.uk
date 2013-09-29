package frontend;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::Email;
use Dancer::Plugin::Cache::CHI;
use Try::Tiny;

use frontend::page;
use frontend::tag;
use frontend::comment;
use frontend::writing;
use frontend::popular;

our $VERSION = '0.1';

prefix undef;

check_page_cache;

get '/' => sub {
    cache_page template 'index', {
			title => "127.0.0.1",
			description => "The lair of the ciderpunx",
		};
};

get '/about.pl' => sub {
	redirect uri_for '/about'
};

get '/about/?' => sub {
    template 'about', {
			title => "About",
			description => "About Charlie Harvey and about charlieharvey.org.uk. Blah, blah, blah.",
		};
};

get '/about/charlie-harvey/?' => sub {
    template 'about-charlie', {
			title => "About Charlie",
			description => "About Charlie Harvey. Cider, geekery, perl and navel gazing",
		};
};

get '/about/this-site/?' => sub {
    template 'about-site', {
			title => "About charlieharvey.org.uk",
			description => "About Charlie Harvey's website, charlieharvey.org.uk. Standards-compliant, fully responsive navel 
			                gazing. ",
		};
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

get '/writings/?' => sub {
	redirect uri_for '/file'
};

get '/writings.pl' => sub {
	redirect uri_for '/file'
};

get '/contact/?' => sub {
    template 'contact', {
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
			title => "Thanks for your email",
			body => $body,
			sender => $sender,
			success => "Your email was sent. Thanks $sender :-)"
		}
	}
};

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

sub _rot13($){
	my $to_return=shift || '';
	$to_return =~ tr |A-Za-z|N-ZA-Mn-za-m|;
	return $to_return;
}

true;
