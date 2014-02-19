package frontend::writing;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;

prefix '/file';

get '/' => sub {
	redirect  uri_for('file/archive/1');
};

## recently published writings
get '/api/recent' => sub {
	set serializer => 'mutable';
	my $file_rs  = _file_archive();
	my @fs       = $file_rs->page(1)->all;
	my @files    = map {
		title => $_->title,
		link  => uri_for($_->link)->as_string,
		id    => $_->uid,
		body  => $_->details,
		category => $_->category,
		created_at => $_->updated->ymd,
		author     => config->{SITE_AUTHOR},
	}, @fs;
	
	return {files => \@files}
};

## recently published writings for a category
get '/api/:category/recent' => sub {
	set serializer => 'mutable';
	my $category = params->{category};
	my $file_rs  = _category_archive($category);
	my @fs       = $file_rs->page(1)->all;
	if (!@fs) {
		send_error("Couldn't find files for category '$category'");
		return
	}
	
	my @files    = map {
		title => $_->title,
		link  => uri_for($_->link)->as_string,
		id    => $_->uid,
		body  => $_->details,
		category => $category,
		created_at => $_->updated->ymd,
		author     => config->{SITE_AUTHOR},
	}, @fs;
	
	return {files => \@files}
};

# single writing
get '/api/:id' => sub {
	set serializer => 'mutable';
	my $file = _file(params->{id});
	if (!$file) {
		send_error("Cannot find file with id " . params->{id});
		return
	}
	return {
		file => {
			title => $file->title,
			link  => uri_for($file->link)->as_string,
			id    => $file->uid,
			category => $file->category,
			body  => $file->details,
			created_at => $file->updated->ymd,
			author     => config->{SITE_AUTHOR},
		}
	}
};

# main feed
get '/feed/?' => sub {
	redirect uri_for "/file/feed/rss"
};

# category feed, never have a category called cat or the world might end
get '/feed/cat/:category/:format' => sub {
	my $category = params->{category};
	my $file_rs  = _category_archive($category);
	my @fs = $file_rs->page(1)->all;
	my $format = params->{format};

	return _make_feed($format,$category,\@fs);
};

# the global feed
get '/feed/:format' => sub {
	my $file_rs  = _file_archive();
	my @fs = $file_rs->page(1)->all;
	my $format = params->{format};

	return _make_feed($format,'',\@fs);
};

## single writing
get '/uid/:id' => sub {
	my $file = _file(params->{id});
	template 'writing/view' => {
		active_nav => "Files",
		title => "Files, " . $file->title,
		description => "Metadata and info about the file " . $file->title . ".",
		file        => $file,
	}
};

# redirect to first page of category
get '/category/:cat' => sub {
	redirect uri_for '/file/category/' . params->{cat} . '/page/1'
};

## paginated category
get '/category/:cat/page/:page' => sub {
	my $category = params->{cat};
	my $page     = params->{page} || 1;
	my $file_rs  = _category_archive($category);
	my $file_obj = $file_rs->page($page);
	my $pager    = $file_obj->pager;
	my @files    = $file_obj->all;
	template 'writing/list', {
		active_nav => "Files",
		title => "All $category files, page $page",
		description => "$category files and writings that Charlie Harvey has posted. Page $page",
		files       => \@files,
		pager				=> $pager,
		category    => ucfirst $category,
		url_base    => "/file/category/$category/page",
	}
};

## all categories, paginated
get '/archive/:page' => sub {
  my $page     = params->{page};
	my $file_rs  = _file_archive();
	my $file_obj = $file_rs->page($page);
	my $pager    = $file_obj->pager;
	my @files    = $file_obj->all;
	template 'writing/list', {
		active_nav => "Files",
		title => "Charlie&#8217;s files, page $page",
		description => "A list of all of Charlie Harvey&#8217;s philes and scripts and writings. Page $page",
		files       => \@files,
		pager				=> $pager,
		url_base    => "/file/archive",
	}
};

## Helper, private methods
sub _file {
	  my $id = shift;
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Writing')->find({uid=>$id});
    return $results;
}

sub _file_archive {
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Writing')->search({},{order_by=>{-desc => 'updated'}});
    return $results;
}

sub _category_archive {
	  my $category = shift;
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Writing')->search({category=>$category},{
				order_by=>{-desc => 'updated'}
		});
    return $results;
}

sub _make_feed {
	my ($format,$category,$fs) = (shift,shift,shift);

	if(uc $format ne 'RSS' && uc $format ne 'ATOM') {
		$format="RSS";
	}

	my $link_uri = $category 
									? "feed/cat/$category/$format"
									: "/feed/$format"
	;
	my $feed = create_feed( 
    format => $format, #Feed format (RSS or Atom) 
    title => "Recent $category files on charlieharvey.org.uk",
		description => ucfirst $category . " philes and writings from charlieharvey.org.uk",
		image => {
			title => "charlieharvey.org.uk $category files and writings feed", 
			width => 240,
			height => 45,
			url    => "/graphics/minilogo.png",
			link   => uri_for(""),
		},
    entries => [ map { 
			title   => $_->title || "Untitled", 
			link    => uri_for($_->link)->as_string,
			author  => config->{SITE_AUTHOR},
			content => $_->details,
			issued  => $_->updated,
		}, @$fs ], 
  );
  return $feed;
}
