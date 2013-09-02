package frontend::page;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);

prefix '/page';

get '/' => sub {
	redirect '/page/id/' 
					 . config->{ROOT_PAGE_ID};
};

get '/id/:id' => sub {
		my $page = _get_page_by_id(params->{id});
		if(!$page) {
			redirect '/404'
		}
		else {
			redirect '/page/' . $page->slug;
		}
};

get '/:slug/?' => sub {
	my $slug = params->{slug};
	$slug =~ s{\/$}{}; 
	my $page = _get_page_by_slug($slug);
	
	if(!$page) {
		redirect '/404';
		return
	}
	
	my @ancestors = $page->ancestors;
	my @recent_children = $page->recent_children;

	if ($page->is_root) {
		template 'page/root', { 
			page => $page, 
			title => $page->title,
			ancestors => \@ancestors,
			recent_children => \@recent_children,
			description => "Charlie Harvey&#8217;s blog. With articles about tech, cider, vegan food and computer science. Amongst other things.",
		}; # index page, use index teplate
	}
	elsif ($page->is_cover) {
		template 'page/cover', { 
			page => $page, 
			title => $page->title,
			ancestors => \@ancestors,
			recent_children => \@recent_children,
			description => $page->auto_summary,
		}; # cover page
	}
	else {
		template 'page/view', { 
			page => $page, 
			title => $page->title,
			ancestors => \@ancestors,
			description => $page->auto_summary,
		}; # normal page view
	}
};

get '/:slug/archive/?' => sub {
	redirect '/page/' . params->{slug} . '/archive/1'
};

get '/:slug/archive/:page/?' => sub {
	my $slug = params->{slug};
	my $page_offset = params->{page};
	$page_offset = 1 unless ($page_offset && $page_offset =~ /\d+/ && $page_offset > 0);
	$slug =~ s{\/$}{}; 
	my $page = _get_page_by_slug($slug);
	unless ($page && $page->is_cover) {
		redirect '/404';
		return;
	}

	my $page_rs = _get_page_archive($page->id);
	my $page_obj = $page_rs->page($page_offset);
	my @pages = $page_obj->all;
	template 'page/archive', { 
			page => $page, 
			pages => \@pages,
			pager => $page_obj->pager, 
			page_offset => $page_offset,
			title => $page->title 
							 . " archive, page " 
							 . $page_offset,
			description => "Archive of posts about " 
										 . $page->title
										 . " (page $page_offset)"
										
	}; # archive view
};


sub _get_page_archive {
    my ($id) = @_;
    my $schema = schema 'frontend';
    my $results = $schema->resultset('Page')->search({ 
				parent_id => { '=', $id } ,
				is_live => {'=', 1},
			},
      { 
					order_by => { -desc => 'id' },
    });
    return $results;
}

sub _get_page_by_slug {
	my $slug = shift;
  my $schema = schema 'frontend';
	my $page = $schema->resultset('Page')->find({slug => $slug});
	return $page;
}

sub _get_page_by_id {
	my $id = shift;
  my $schema = schema 'frontend';
	my $page = $schema->resultset('Page')->find({id => $id});
	return $page;
}

