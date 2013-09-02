package frontend;
use utf8;
use Dancer ':syntax';
use Email::Send; #TODO: use the proper dancer plugin.

use frontend::page;
use frontend::comment;

our $VERSION = '0.1';

prefix undef;

get '/' => sub {
    template 'index', {
			title => "127.0.0.1",
			description => "The lair of the ciderpunx",
		};
};


## TODO: need a better search tool than swifttype for search.
get '/search/?' => sub {
    template 'search', {
			title => "Search Results",
			description => "Search results page on charlieharvey.org.uk",
		};
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
		# send the email
		_email_charlie($sender,$body);
		template 'contact_success', { 
			title => "Thanks for your email",
			body => $body,
			sender => $sender,
			success => "Your email was sent. Thanks $sender :-)"
		}
	}
};
sub _email_charlie {
	my ($sender,$body) = @_;
	my $charlie = 'charlie@newint.org';
		my $msg = <<"__MESSAGE__";
From: $sender
To: $charlie
Subject: charlieharvey.org.uk-contact.pl	

$body

__MESSAGE__
;
	my $mail_sender = Email::Send->new({mailer => 'SMTP'});
  $mail_sender->mailer_args([Host => 'charlieharvey.dns-systems.net']);        
	return $mail_sender->send($msg);
}

# this takes care of 404s and should be the last route.
any qr{.*}  => sub {
  status 'not_found';
	template '404', {
		title => 'Not Found -- Error 404',
		description => 'Seriously, this is a 404 page. Why are you even indexing this?'
	};
};

true;
