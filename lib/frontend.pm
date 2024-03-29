package frontend;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::Email;
use Dancer::Plugin::Feed;
use Dancer::Plugin::Cache::CHI;
use Try::Tiny;
use XML::RSS;
use XML::Simple;
use LWP::Simple ();
use LWP::UserAgent;
use JSON;

use frontend::comment;
use frontend::daily_mail;
use frontend::flick;
use frontend::newsfeed;
use frontend::page;
use frontend::popular;
use frontend::social;
use frontend::tag;
use frontend::writing;

require "dumbcaptcha.pl";

our $VERSION = '0.3';

prefix undef;

check_page_cache;

get '/' => sub {
    my $collection_ref 
                  = frontend::flick::_get_flickr_photo_collection(5, 1);
    my $photos    = frontend::flick::_get_photos($collection_ref, 1);
    my $tweets    = frontend::social::_tweets();
    my $scrobbles  = frontend::social::_scrobbles();
    my $page_rs    = frontend::page::_page_recent();
    my @blogs      = $page_rs->all;
    my $populars  = frontend::popular::_popular_for('week');
    my @pop_ord    = frontend::popular::_page_ordering($populars);

    cache_page template 'index', {
      active_nav  => 'Home',
      title       => "Charlie Harvey 127.0.0.1",
      description => "Charlie Harvey's website &mdash; the lair of the ciderpunx. Being the home page of Charlie Harvey with diverse musings on cider, geekery and perl.",
      tweets      => $tweets,
      scrobbles   => $scrobbles,
      blogs       => \@blogs,
      populars    => $populars,
      pop_ord     => \@pop_ord,
      pics        => $photos,
      # full_width_image => "//farm4.static.flickr.com/3670/9009590123_88e46e13af_o.jpg",
    };
};

get '/about.pl' => sub {
  redirect uri_for '/about'
};

get '/about/?' => sub {
    template 'about', {
      active_nav  => 'About',
      title        => "About Charlie Harvey",
      description => "About Charlie Harvey and about charlieharvey.org.uk. Blah, blah, blah.",
    };
};

get '/about/api/?' => sub {
    template 'about-api', {
      title        => "Charlie Harvey REST Content API Documentation",
      active_nav  => 'About',
      description => "Documentation for the charlieharvey.org.uk REST Content API, with some sample code and a few examples.",
    };
};

get '/about/charlie-harvey/?' => sub {
    template 'about-charlie', {
      active_nav  => 'About',
      title        => "About Charlie Harvey (Personal info)",
      description => "About Charlie Harvey (personal information). Cider, geekery, perl and navel gazing",
    };
};

get '/about/feeds/?' => sub {
    template 'about-feeds', {
      title        => "RSS and Atom site feeds on charlieharvey.org.uk",
      active_nav  => 'About',
      description => "Information about the various RSS and Atom available from charlieharvey.org.uk.",
    };
};

get '/about/this-site/?' => sub {
    template 'about-site', {
      active_nav  => 'About',
      title        => "About charlieharvey.org.uk",
      description => "About Charlie Harvey's website, charlieharvey.org.uk. Standards-compliant, fully responsive navel 
                      gazing. ",
    };
};

get '/archive.pl' => sub {
    redirect uri_for('/page/index/archive/1');
};

get '/archive/?' => sub {
    redirect uri_for('/page/index/archive/1');
};

get '/blog/?' => sub {
  redirect uri_for '/page/index'
};

get '/boozeulator.pl' => sub {
  redirect uri_for '/boozeulator'
};

get '/boozeulator' => sub {
  my $name    = (params->{name})    || '';
  my $percent = (params->{percent}) || 0;
  my $price    = (params->{price})    || 0;
  my $ml      = (params->{ml})      || 0;
  $percent    = 0 if $percent > 100 || $percent <= 0;
  $price      = 0 if $price < 0.01;
  $ml          = 0 if $ml < 1;
  my $errors  = '';
  my $success  = '';
  my $ppp      = 0;
  my $units    = 0;

  if($name && $percent && $price && $ml) {
    $ppp      = sprintf("%.2f", ($ml*($percent/100))/($price/100));
    $units    = sprintf("%.4f", ($ml*$percent)/1000);
    $success  = "Booze-u-lation successful!";
  } 
  else {
    if ($name || $percent || $price || $ml) {
      $errors = ["Missing name, percentage ABV, price or amount in ml. Fill in all the things."]
    }
  }
  template 'boozeulator', {
      title        => "The Booze-u-lator",
      description => "The world famous Booze-u-lator: calculate the most efficient way to get pissed.",
      name        => $name,
      percent      => $percent,
      ml          => $ml,
      price        => $price,
      ppp          => $ppp,
      units        => $units,
      errors      => $errors,
      success      => $success,
  }
};

# TODO: Boozeulator API
#get '/boozeulator/api/:name/:price/:percent/:mls' => sub { 
#  set serializer => 'mutable';
#  return {ppp => (params->{mls}), units => 0};
#}; 

get '/cal.pl' => sub {
   redirect uri_for '/'
};

get '/cgi-bin/*' => sub {
   redirect uri_for '/'
};

get '/cv.pl' => sub {
  redirect uri_for '/cv'
};

get '/cv/?' => sub {
    template 'cv', {
      active_nav  => 'About',
      title        => "My Curriculum Vita&eacute;",
      description => "Charlie Harvey&#8217;s CV or resum&eacute; as they say in the US.",
    };
};

get '/daily_mail.pl' => sub {
    redirect uri_for('/daily_mail/');
};

get '/dbpage.pl/?' => sub {
  if(my $id = param('id')) {
    redirect uri_for "/page/id/$id"
  }
  else {
    redirect uri_for '/page/index'
  }
};

get '/flick.pl' => sub {
    redirect uri_for('/flick/');
};

get '/flick_view.pl' => sub {
  my $id    = (params->{id})    || '504996476';
  my $page  = (params->{page})  || '1';
  redirect uri_for("/flick/view/$id/page/$page");
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
  unless ($content && $rss->parse($content)) {
    push @errors, "Could not parse feed"; 
  }
 

  if ($feed && !@errors) {
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

    $feed =~ s{<(/?p)>}{[$1]}g;    # keep p tags
    $feed =~ s{</?[^>]+>}{}g;     # lose the rest
    $feed =~ s{\[(/?p)\]}{<$1>}g;  # put ps back
    # Converts chrs beyond 127 to html entities
    $feed =~ s{([^\x20-\x7F])}{'&#' . ord($1) . ';'}gse;
    $feed =~ s{&#8217;}{'}g; # fucking "smart" quotes
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

get '/monk_feed.pl' => sub {
  redirect uri_for '/monk_feed/ciderpunx'
};

get '/monk_feed/:monk/?' => sub {
  my $monk = lc params->{monk} || 'ciderpunx';
  my $base_url = "http://perlmonks.org";
  my $src_url = "http://www.perlmonks.org/?node_id=32704&foruser=$monk&order=desc&limit=10";
  my $data = LWP::Simple::get($src_url);
  my $ref = XMLin($data);
  my $user = $ref->{INFO}->{foruser};

  my %ents = $ref->{NODE};
  my $feed = create_feed( 
    format      => 'RSS', #Feed format (RSS or Atom) 
    title        => "charlieharvey.org.uk: Perlmonks user RSS feed for $user",
    description => "A feed of nodes posted by the perlmonks user $user. That's it.",
    image        => {
            title   => "charlieharvey.org.uk: Perlmonks RSS feed for $user", 
            width   => 120,
            height => 23,
            url    => "http://perlmonks.org/favicon.ico",
            link   => "http://perlmonks.org",
    },

    entries => [ map { 
        title   => '<![CDATA[' . $ref->{NODE}{$_}{content} . ']]>', 
        link    => $base_url   . "/?node_id=$_",
        author  => '<![CDATA[' . $user . ']]>',
        summary => '<![CDATA[' . $ref->{NODE}{$_}{content} . ']]>',
        # issued  => $ref->{NODE}{$_}{lastedit},
    }, keys %ents ], #makes collection of feed entries
  );
  return $feed;
};

get '/most_popular.pl' => sub {
  redirect uri_for '/popular/week'
};

get '/page_category.pl/?' => sub {
  my $slug = param('slug');
  my $pg = param('pg');
  if($slug && $pg) {
    redirect uri_for "/page/$slug/archive/$pg"
  }
  elsif($slug) {
    redirect uri_for "/page/$slug"
  }
  else {
    redirect uri_for '/page/index'
  }
};


get '/photos.pl' => sub {
  redirect uri_for '/flick/list/1'
};

get '/rot13.pl' => sub {
  redirect uri_for '/rot13'
};

get '/rot-13' => sub {
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

get '/rot13/api/?' => sub { 
  redirect 'http://charlieharvey.org.uk/about/api#rot13' # is this the best way to do this uri_for doesn't like the #rot13
};

get '/rot13/api/:to_rot' => sub { 
  set serializer => 'mutable';
  return {msg => _rot13(params->{to_rot}) || ''};
};

get '/rss.pl' => sub {
  redirect uri_for '/newsfeed'
};

get '/rss/latest.xml' => sub {
  redirect uri_for '/page/feed/rss'
};

get '/search.pl' => sub {
  redirect uri_for '/search'
};

## TODO: need a better search tool than swifttype for search.
get '/search/?' => sub {
    template 'search', {
      title => "Search page",
      description => "Search results page on charlieharvey.org.uk",
    };
};

get '/ddg/?' => sub {
  my $term = params->{'q'};
  redirect "https://duckduckgo.com/?sites=charlieharvey.org.uk&q=$term&ka=Cabin,DDG_ProximaNova,freesans,helvetica,arial,sans-serif&kd=1&kh=1&kj=%230a2637&kt=Libre%20Baskerville,URW%20Bookman%20L,Georgia,serif&kx=%23446688&ky=%23fafafa&ia=web";
};

get '/tagcloud/?' => sub {
  redirect uri_for '/tag/cloud'
};

get '/tag.atom/:tag' => sub {
  my $tag = params->{tag};
  redirect uri_for "/tag/$tag/feed/atom";
};

get '/tag.rss/:tag' => sub {
  my $tag = params->{tag};
  redirect uri_for "/tag/$tag/feed/rss";
};

get '/td/?' => sub {
   redirect uri_for '/'
};

get '/todo.pl' => sub {
   redirect uri_for '/'
};

get '/twitterhaiku.pl' => sub {
  template 'twitterhaiku', {
    title => 'MOTHBALLED: Twitter haiku',
    desctiption => 'Twitter Haiku was  
                    Wonderous. Twitter axed their feed.
                    Poetry no more.'
  }
};

get '/webmail.pl' => sub {
   redirect uri_for '/'
};

get '/writings/?' => sub {
  redirect uri_for '/file'
};

get '/writings.pl' => sub {
  redirect uri_for '/file'
};


get '/contact/?' => sub {
    my $remote_host = "";
    $remote_host = request->header('x-forwarded-for');
    unless($remote_host) {
      $remote_host = request->remote_host;
    }
    if($remote_host) {
      $remote_host =~ s{, 127\.0\.0\.1$}{};
    }
    my $logstring = "$remote_host," . request->referer . ", " . request->user_agent . "\n";
    open my $out, '>>', '/var/log/contactspammers.log' or die('cannot open spammer log');
    print $out $logstring;
    close $out;
    send_error("Spammers not appreciated", 403);
    exit;
};

post '/contact/?' => sub {
  redirect uri_for '/contact'
};

get '/contact_charlie/?' => sub {
    my $remote_host = "";
    $remote_host = request->header('x-forwarded-for');
    unless($remote_host) {
      $remote_host = request->remote_host;
    }
    if($remote_host) {
      $remote_host =~ s{, 127\.0\.0\.1$}{};
    }
    my $captchas = captchas();
    my $dumb_captcha_question_id = int(rand @$captchas);

    template 'contact', {
      active_nav => 'About',
      title => "Contact me",
      description => "Contact Charlie Harvey",
      referer => request->referer,
      useragent => request->user_agent,
      remote_host => $remote_host,
      dumb_captcha_question_id => $dumb_captcha_question_id,
      dumb_captcha_question => $captchas->[$dumb_captcha_question_id][0],
    };
};

post '/contact_charlie' => sub {
  my @errors;

  my $def_spammer = params->{sender};
  if($def_spammer ne  '') {
    sleep 5;
    push @errors,"You look like a spammer";
  }
  if(_spammy_user_agent(request->user_agent)) {
    sleep 5;
    push @errors,"You look like a spammer";
  }
  my $token = params->{'h-captcha-response'};
  if(_verify_hcaptcha($token)) {
    sleep 5;
    push @errors,"Failed to complete CAPTCHA";
  }
  my $dumb_captcha_ans = params->{'dumb-captcha-response'};
  my $dumb_captcha_ques = params->{'dumb-captcha-question'};
  unless(_verify_dumb_captcha($dumb_captcha_ans, $dumb_captcha_ques)) {
    sleep 5;
    push @errors,"Failed to complete dumb CAPTCHA";
  }

  my $remote_host = "";
  $remote_host = request->header('x-forwarded-for');
  unless($remote_host) {
    $remote_host = request->remote_host;
  }
  if($remote_host) {
    $remote_host =~ s{, 127\.0\.0\.1$}{};
  }
  my $sender = params->{bobitsk};
  my $body   = params->{body};

  my $hrefs = () = $body =~ m{http}gi;
  if($hrefs>2) {
    sleep 5;
    push @errors,"You look like a spammer";
  }
  unless (length $body > 70) {
    sleep 5;
    push @errors, "You look like a spammer";
  }


  $sender    =~ s/%40/@/;
  $body      =~ s/\+/ /gs;
  $body      =~ s/%([a-f0-9]{2})/chr(hex($1))/gei;

  my @seo_spammers = ('stellaseo5@gmail.com'
    , 'donnagabriel'
    , 'ramonelliot\d+@gmail.com'
    , 'ivanballard.*@gmail.com'
    , 'stellafair\d+@gmail.com'
    , 'michaelfields3590@gmail.com'
  );

  unless ($body) {
    push @errors, "Body is empty";
  }
  unless ($sender) {
    push @errors, "Email is empty"
  }
  if (grep {$sender =~ /$_/gi} @seo_spammers) {
    sleep 5;
    push @errors,"You look like a spammer"
  }
  if(_body_contains_spam_phrases($body)) {
    sleep 5;
    push @errors,"Your email contained a phrase often used by spammers";
  }
  if (    frontend::comment->_honeypot_lookup( $sender)
        || frontend::comment->_akismet_lookup( $sender, request->remote_host, request->user_agent, request->referer, $body, $sender, '' )) {
    sleep 5;
    push @errors, "You look a spammer";
  }

  if(@errors) {
    my $captchas = captchas();
    my $new_dumb_captcha_question_id = int (rand @$captchas);
    template 'contact', {
      active_nav => 'About',
      title => "Contact me",
      errors => \@errors,
      body => $body,
      sender => $sender,
      referer => request->referer,
      useragent => request->user_agent,
      remote_host => request->remote_host,
      dumb_captcha_question_id => $new_dumb_captcha_question_id,
      dumb_captcha_question => $captchas->[$new_dumb_captcha_question_id][0],
    };
  }
  else {
    if($remote_host) {
      $body     .= "\nRemote Host: $remote_host";
    }
    $body     .= "\nReferer: " . request->referer;
    $body     .= "\nUA:      " . request->user_agent;
    $body     .= "\nBdy len: " . length $body;
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
get '/inc' => sub { 
  print join ", ", @INC;
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

sub _verify_hcaptcha {
  my $token = shift;
  my $secret_key = config->{HCAPTCHA_SECRET};
  my $verify_url = config->{HCAPTCHA_VERIFY_URL};
  my $json_data = "{'secret': $secret_key, 'token': $token}";
  my $req =  HTTP::Request->new( 'POST', $verify_url);
  $req->header( 'Content-Type' => 'application/json' );
  $req->content( $json_data );
  my $lwp = LWP::UserAgent->new;
  my $response = $lwp->request( $req );

  if($response->is_success) {
    my $json = decode_json($response->content);
    if($json->{success} eq 'true') {
      return 1;
    }
  }
  return 0;
}

sub _verify_dumb_captcha {
  my ($answer, $question_id) = (shift, shift);
  my $captchas = captchas();
  my $correct_answer = $captchas->[$question_id][1];
  if(uc $answer eq uc $correct_answer) {
    return 1;
  }
  return 0;
}

sub _spammy_user_agent {
  my $ua = shift;
  my @dodgy_uas = (
    'Edition Campaign 34',
    'Kinza',
  );
  if(grep {$ua =~ /$_/gi} @dodgy_uas) {
    return 1;
  }
  return 0;
}

sub _body_contains_spam_phrases {
  my $body = shift;
  my @phrases = (
    'content on your site',
    '\sseo\s',
    '\sseo',
    'seo\s',
    'cams',
    '\svape\s',
    '\sfeedback\s*?form',
    '\scontact\s*?form',
    '\sadvertis',
    '\scoupon',
    '\sSent from my iPhone\s',
    '\sapartament\s',
    '\sporn\s',
    '\sbacklinks\s',
    '\sloans\s',
    'cialis',
    '\samoxicillin\s',
    '\sviagra\s',
    '\scidofovir\s',
    '\scasino\s',
    '\srolex\s',
    '\ssavior\s',
    'xevil',
		'https://telegra.ph/',
		'<img src',
		'/sukranian/s',
  );
  if(grep {$body =~ /$_/gi} @phrases) {
    return 1;
  }
  return 0;
}

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
