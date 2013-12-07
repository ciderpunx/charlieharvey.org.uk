package frontend::newsfeed;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;
use Dancer::Plugin::XML::RSS;
use Dancer::Plugin::Cache::CHI;
use LWP::Simple ();

prefix '/newsfeed';

get '/' => sub {
	my @feeds = split/\s*,\s*/, config->{'FEEDS'};			
	my @contents = map { _get_feed( $_) } @feeds;	
  cache_page template 'newsfeed/view', { 
			title => "News Headlines from Charlie Harvey&#8217;s favourite RSSes",
			description => "News Headlines from Charlie Harvey&#8217;s favourite RSS feeds",
			feeds => \@contents, 
	};
};

## 

sub _get_feed {
	my $feed = shift;	

	rss->parse( LWP::Simple::get($feed) );

	my @stories;
	my $display_max = config->{'FEED_MAX'};

	for ( my $i = 0; $i < $display_max; $i++ ) {
		next unless exists rss->{items}->[$i] and ref rss->{items};
		push @stories, rss->{items}->[$i];
	}

	return { 
		title   => rss->{channel}{title} =>
		link    => rss->{channel}{link}, 
		stories => \@stories,					
	};
}
