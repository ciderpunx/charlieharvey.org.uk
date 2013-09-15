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

get '/feed/?' => sub {
	redirect uri_for "/file/feed/rss"
};

get '/feed/:format' => sub {
	my $file_rs  = _file_archive();
	my @fs = $file_rs->page(1)->all;
	my $format = params->{format};
	if(uc $format ne 'RSS' && uc $format ne 'ATOM') {
		send_error("Bad feed format. RSS or Atom.");
		return
	}
	my $feed = create_feed( 
    format => params->{format}, #Feed format (RSS or Atom) 
    title => 'Recent files on charlieharvey.org.uk',
		description => "Philes and writings from charlieharvey.org.uk",
		image => {
			title => "charlieharvey.org.uk files and writings feed", 
			width => 240,
			height => 45,
			url    => "/graphics/minilogo.png",
			link   => uri_for("/comments"),
		},
    entries => [ map { 
			title   => $_->title || "Untitled", 
			link    => uri_for($_->link)->as_string,
			author  => config->{SITE_AUTHOR},
			content => $_->details,
			issued  => $_->updated,
		}, @fs ], 
  );
  return $feed;
};

## single writing
get '/node/:id' => sub {
	my $file = _file(params->{id});
	template 'writing/view' => {
		title => "Files, " . $file->title,
		description => "Metadata and info about the file " . $file->title . ".",
		file        => $file,
	}
};

## API and feed for category? 

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
		title => "Charlie&#8217;s files, page $page",
		description => "A list of all of Charlie Harvey&#8217;s philes and scripts and writings. Page $page",
		files       => \@files,
		pager				=> $pager,
		url_base    => "/file/archive",
	}
};

##
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
