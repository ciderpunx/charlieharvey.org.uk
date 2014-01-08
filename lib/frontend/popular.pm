package frontend::popular;
use Dancer ':syntax';
use Dancer::Plugin::Feed;
use Dancer::Plugin::Database;
use v5.14;  # for given/when
use POSIX qw(strftime);
use HTML::Entities;

prefix '/popular';

get '/' => sub { redirect uri_for('/popular/week') };

# popular this week
get '/:period/?' => sub {
		my $period = _validate_period(params->{period});
		my $pages = _popular_for($period);
		my @page_ordering = _page_ordering($pages);
		my $pstr = "this $period";
		$pstr = "over all time" if ($period eq 'all-time');
		template 'popular/stats', {
			active_nav      => 'About',
			title => "Most popular pages $pstr",
			description => "Most popular pages on charlieharvey.org.uk $pstr",
			pages	=> $pages,
			order => \@page_ordering,
			period => $period,
	}
};
get '/:period/api/?' => sub {
		my $period = _validate_period(params->{period});
		my $pages = _popular_for($period);
		my @page_ordering = _page_ordering($pages);

		set serializer => 'mutable'; 
		return {page_titles_ordered => \@page_ordering, pages => $pages }			
};

get '/:period/feed/?' => sub {
	redirect uri_for '/popular/' . _validate_period(params->{period}) . "/feed/rss"
};

get '/:period/feed/:format/?' => sub {
		my $format = params->{format};
		
		if(uc $format ne 'RSS' && uc $format ne 'ATOM') {
			send_error("Bad feed format. RSS or Atom.");
			return
		}
		
		my $period = _validate_period(params->{period});
		my $pages = _popular_for($period);
		my @page_ordering = _page_ordering($pages);
		
		my $feed = create_feed( 
			format => $format,  
			title => "Popular pages on charlieharvey.org.uk for period: $period",
			description => "$period popular pages from Charlie Harvey&#8217;s website, charlieharvey.org.uk",
			image => {
				title => "charlieharvey.org.uk popular pages", 
				width => 240,
				height => 45,
				url    => "/graphics/minilogo.png",
				link   => uri_for("/popular/$period"),
			},
			entries => [ map { 
				title   => $_ || "Untitled", 
				link    => $pages->{$_}{url},
				author  => config->{SITE_AUTHOR},
				content => $_ . " (". $pages->{$_}{unique_visits} . " unique visits)",
			}, @page_ordering ] 
		);
};

## Helpers

sub _popular_for {
	my $period = shift;
	my $b = 7;
	given ($period) {
		when (/^month$/)			{$b = 31}
		when (/^year$/)				{$b = 365}
		when (/^all\-time$/)	{$b = 10000} # arbitrarily large figure for convenience
		default							  {$b = 7}
	}; 
	my $today     = strftime "%Y-%m-%d", localtime;
	my $back_time = strftime "%Y-%m-%d", localtime time - $b * 86400;
	my $query = "SELECT COUNT( DISTINCT `idvisit` ) AS unique_visits,  
 							   		  COUNT( DISTINCT `idlink_va` ) AS hits, 
  										(SELECT `name` FROM piwik_log_action WHERE idaction_url=idaction) AS url,  
 										  REPLACE( (SELECT `name` FROM piwik_log_action WHERE idaction_name=idaction),
																'Charlie Harvey : ','' ) AS title
 								 FROM `piwik_log_link_visit_action`
 							  WHERE `server_time` >= '$back_time'
 							 	  AND `server_time` <= '$today'
 								  AND `idsite`=1
 								  AND `idaction_name` IS NOT NULL
									AND `idaction_name` > 0
 						 GROUP BY `idaction_name`
 						 ORDER BY `unique_visits` DESC
 							  LIMIT 10;"
	;
	my $sth = database('piwik')->prepare($query);
	$sth->execute;
	my $results = $sth->fetchall_hashref('title');
	# Make the titles UTF-8 friendly, just htmlentities them
	for (keys %{$results}) {
		my $newtitle = encode_entities($_);
		$newtitle =~ s/&#151;/&mdash;/g; # horrible but it keeps the validator happy
		unless ($newtitle eq $_) {
			$results->{$newtitle}=$results->{$_};
			$results->{$newtitle}{title}=$newtitle;
			delete $results->{$_}
		}
	}
	return $results;
}

sub _page_ordering {
	my $pages = shift;
	my @page_ordering;
	for (sort { ($pages->{$b}{unique_visits} <=> $pages->{$a}{unique_visits}) || ($a cmp $b) } keys %$pages) {
			push @page_ordering, $_ ;
	}
	return @page_ordering;
}

sub _validate_period {
	my $period = shift;
	$period = 'week' unless grep {$_ eq lc $period} ('week','month', 'year', 'all-time');
	return $period;
}
