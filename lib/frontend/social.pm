package frontend::social;
use utf8;
use Dancer ':syntax';
use XML::RSS;
use LWP::Simple qw($ua);
use HTML::Entities;

prefix '/social';

get '/' => sub {
  template 'social/list', {
    title => "What have I been doing on the social media?",
    description => "My social media activities.",
    tweets => _tweets(),
    scrobbles => _scrobbles(),
  }
};

get '/api/tweets/?' => sub {
  set serializer => 'mutable';
  return {tweets => _tweets()}
};

get '/api/scrobbles/?' => sub {
  set serializer => 'mutable';
  return {scrobbles => _scrobbles()}
};

get '/api/all/?' => sub {
  set serializer => 'mutable';
  return {
    scrobbles => _scrobbles(),
    tweets    => _tweets(),  
  }
};

##

sub _tweets {
  my $url   = "http://ox4.org/~charlie/tweets.xml";
  my $limit = 5;
  my @items;

  $ua->timeout(2);
  my $content=LWP::Simple::get($url);
  return unless $content;
  my $rss = new XML::RSS;
  $rss->parse($content);

  my $i=0;
  for my $item (@{$rss->{items}}) {
    $i++;
    last if $i>$limit;
    my $title=$item->{title};
    my $link=$item->{link};
                $title = encode_entities($title, '^\n\x20-\x25\x27-\x7e'); 
    $title =~ s/&amp;gt;/&gt;/g;  
    $title =~ s/&amp;lt;/&lt;/g;
    $title =~ s/>/&gt;/g;  
    $title =~ s/</&lt;/g;     
    $title =~s/@?ciderpunx\://;
    $title =~ s/(https?:\/\/[\w\-\.\?\=\/]+)\b?/<a href="$1">$1<\/a>/ig;
    $title =~ s/\s#(\w+)\s?/ <a href="http:\/\/twitter.com\/search?q=%23$1">#$1<\/a> /ig;
    $title =~ s/@(\w+)\b?/<a href="http:\/\/twitter.com\/$1">\@$1<\/a>/ig;
    $title =~ s/^\s+//;
    $title =~ s/\s+$//;
                $title =~ s/&amp;#/&#/g;
                $title =~ s{(pic.twitter.com\/\w+)}{<a href="http://$1">$1</a>}g;
    push @items, {title=>$title, link=>$link};
  }
  return \@items;
}

sub _scrobbles {
  # my $url      = "http://ws.audioscrobbler.com/1.0/user/ciderpunx/recenttracks.rss";
  my $url   = "http://xiffy.nl/lastfmrss.php?user=ciderpunx";   
  my $limit  = 5;
  my @items;

  $ua->timeout(2);
  my $content=LWP::Simple::get($url);
  return unless $content;
  my $rss = new XML::RSS;
  $rss->parse($content);

  my $i=0;
  foreach my $item (@{$rss->{items}}) {
    $i++;
    last if $i>$limit;
    my $title=$item->{title};
    my $link=$item->{link};
    $title = encode_entities($title, '^\n\x20-\x25\x27-\x7e'); 
    $title =~ s/&amp;gt;/&gt;/g;
    $title =~ s/&amp;lt;/&lt;/g;
    $link =~ s/&\W/&amp;/g;
    push @items, {title=>$title, link=>$link};
  }
  return \@items;
}
