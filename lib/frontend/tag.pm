package frontend::tag;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;

prefix '/tag';

get '/' => sub {
	my $tags_rs  = _all_tags();
	my @tags     = $tags_rs->all;
	template 'tag/list', {
		title => "All tags on website",
		description => "A collection of all the tags on charlieharvey.org.uk.",
		tags => \@tags,
	}
};

get '/cloud' => sub {
	my $tags_rs  = _all_tags();
	my @tags     = $tags_rs->all;
	template 'tag/list', {
		title => "A tagcloud of stuff on Charlie&#8217;s site",
		description => "A collection of all the tags on charlieharvey.org.uk, but represented as a tag cloud.",
		tags => \@tags,
	}
};

# recent tags: api
get '/api/?' => sub {
	set serializer => 'mutable';

	my $tag_rs = _all_tags();
	my @ts = $tag_rs->all;
	my @tags = map {title => $_->title, id => $_->id, link => uri_for($_->link)->as_string }, @ts;
	return {tags => \@tags}
};

# single tag, all entries, paged
get '/api/:id' => sub {
	set serializer => 'mutable';

	my $t = _tag(params->{id});
	if (!$t) {
		send_error "Cannot retrieve tag with id " . params->{id};
		return
	}

	my @tag_pages = map {
		title => $_->title, 
		link  => uri_for($_->link)->as_string,
		id    => $_->id,
		summary => $_->auto_summary,
		updated_at => $_->updated_at->ymd,
		author => config->{SITE_AUTHOR},
	}, $t->page;

	my @tag_writings = map {
		title => $_->title, 
		link  => uri_for($_->link)->as_string,
		id    => $_->id,
		summary => $_->details, #TODO: summary method in model
		updated_at => $_->updated->ymd,
		author => config->{SITE_AUTHOR},
	}, $t->writing;

	return {tag => {
		title => $t->title, 
		id => $t->id,
		link => uri_for($t->link)->as_string,
		pages => \@tag_pages,
		writings => \@tag_writings,
	}}
};

# stuff tagged: feed
get '/:title/feed/:format' => sub {
	my $tag = _tag_by_title(params->{title});
	if (!$tag) {
		send_error "Cannot find tag called " . params->{title};
		return
	}
	my $format = params->{format};
	if(uc $format ne 'RSS' && uc $format ne 'ATOM') {
		send_error("Bad feed format. RSS or Atom.");
		return
	}
	my $rhash = _stuff_tagged($tag,1);
	my @results;
	for my $key (reverse sort keys $rhash->{results}) {
		push @results, {
			title   => $rhash->{results}{$key}->title || "Untitled", 
			link    => uri_for($rhash->{results}{$key}->link)->as_string,
			author  => config->{SITE_AUTHOR},
			summary => $rhash->{results}{$key}->auto_summary || "",
			issued  => $rhash->{results}{$key}->updated_at || $rhash->{results}{$key}->updated ,
		}, # makes collection of feed entries
	}

	return create_feed( 
    format => params->{format}, #Feed format (RSS or Atom) 
    title => 'Stuff tagged ' . $tag->title . ' on charlieharvey.org.uk',
		description => "Stuff tagged " . $tag->title . " from charlieharvey.org.uk",
		image => {
			title => "charlieharvey.org.uk feed for tag: " . $tag->title, 
			width => 240,
			height => 45,
			url    => "/graphics/minilogo.png",
			link   => uri_for("/comments"),
		},
    entries => \@results, 
  );	
};


get '/:title/?' => sub {
	redirect uri_for('/tag/' . params->{title} . '/1');
};

get '/:title/:page' => sub {
	my $page = params->{page} || 1;
	my $tag = _tag_by_title(params->{title});
	if (!$tag) {
		redirect '/404';
		return
	}
	
	my $rs = _stuff_tagged($tag,$page);
	template 'tag/view', {
		title => "Stuff tagged " . $tag->title . ", page $page",
		description => "Tagged " 
									 . $tag->title 
									 . ": A page of stuff tagged "
									 . $tag->title 
									 . " on Charlie Harvey&#8217;bs site.",
		tag     => $tag,
		results => $rs->{results},
		pager   => $rs->{pager},
		entry_count => $rs->{entry_count},
	}
};

##
sub _tag {
	  my $id = shift;
    my $schema = schema 'frontend';
    my $tag = $schema->resultset('Tag')->find({id => $id});
    return $tag;
}

sub _tag_by_title {
	  my $title = shift;
    my $schema = schema 'frontend';
    my $tag = $schema->resultset('Tag')->find({title => $title});
    return $tag;
}

# SELECT me.id, me.title, (
# COUNT( writing_tag.writing_id ) + COUNT( page_tag.page_id )
# ) AS c
# FROM tags me
# LEFT JOIN writing_tags writing_tag ON writing_tag.tag_id = me.id
# LEFT JOIN page_tags page_tag ON page_tag.page_id = me.id
# GROUP BY title
# ORDER BY c DESC

sub _all_tags {
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Tag')->search(
			{  }, 
			{ join      => ['page_tag','writing_tag'],
				'+select'  => [ 
					{count => 'page_tag.page_id', -as => 'page_count'}, 
					{count => 'writing_tag.writing_id', -as => 'writing_count'}, 
				],
				'+as' => [qw/page_count writing_count/],
				order_by => {-asc => 'title'},
				group_by => 'title',
			});
    return $results;
}

sub _stuff_tagged {
	my ($tag,$page) = @_;

	my $pg_rs = $tag->page->search({is_live=>1},{order_by=>{-desc=>'updated_at'}})->page($page);
	my $pg_pager = $pg_rs->pager;
	my @pages = $pg_rs->all;

	my $wr_rs = $tag->writing->search({},{order_by=>{-desc=>'updated'}})->page($page);
	my $wr_pager = $wr_rs->pager;
	my @writings = $wr_rs->all;

	my %results;
	# Choose the longer pager as our pager
	$results{pager} =
        $pg_pager->last_page >= $wr_pager->last_page
      ? $pg_pager
			: $wr_pager;
	
	$results{entry_count} = 
				$pg_pager->total_entries + $wr_pager->total_entries;

	for (@writings) {
		$results{results}{$_->updated->ymd . "Writing" . $_->id} = $_;
	}
	for (@pages) {
		$results{results}{$_->updated_at->ymd . "Page" . $_->id} = $_;
	}

	return \%results;
}
