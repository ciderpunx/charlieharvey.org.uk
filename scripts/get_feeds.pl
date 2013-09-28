#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.10.0;
use Data::Dumper;
use XML::FeedPP;

my $feed = XML::FeedPP::RSS->new();
#$feed->merge( "http://www.theregister.co.uk/headlines.rss" ); 
$feed->merge( "http://libcom.org/library-latest/feed" );
$feed->merge( "https://network23.org/activity/feed/" );
$feed->merge( "http://news.ycombinator.com/rss" );
$feed->merge( "http://charlie.ox4.org/aggregator/rss" );
$feed->merge( "https://www.schneier.com/blog/atom.xml" );
my $now = time();
$feed->pubDate( $now );       # touch date
$feed->title("The headlines from the internets");
$feed->link("http://charlieharvey.org.uk/headlines.rss");
$feed->language("en-GB");
$feed->copyright("The individual feeds have various licences. This feed is public domain");
$feed->image(" "," "," "," "," "," ");
$feed->description("A collection of aggregated headlines from various places on the internets that I find interesting");
$feed->limit_item(25);
$feed->normalize();
my $rss = $feed->to_string('UTF-8', indent => 4);# get Atom source code

print $rss;
