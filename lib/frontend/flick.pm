package frontend::flick;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;
use Dancer::Plugin::Cache::CHI;
use Flickr::API;

prefix '/flick';
	
check_page_cache;

get '/' => sub {
	redirect uri_for 'flick/list/1' 
};

get '/list/:page/?' => sub {
  my $per_page = 24;
	my $page = params->{page};

	my $collection_ref = _get_flickr_photo_collection($per_page, $page);
  my $photos = _get_photos($collection_ref, $page);
  my $meta = _get_meta($collection_ref);

	my $next = int($meta->{page}) < $meta->{pages} 
						 ? int($meta->{page})+1
						 : undef
	;
	my $prev = int($meta->{page}) > 1 
						 ? int($meta->{page})-1
						 : undef
	;
	my $last = $meta->{page} eq $meta->{pages}
						 ? undef
						 : $meta->{pages}
	;
	my $first = int($meta->{page})==1
							? undef
							: 1
	;
  template 'flick/list', {
			active_nav  => 'Images',
			title				=> "Charlie&#8217;s flickr photos $page",
			description => "Gallery of Charlie Harvey(aka Ludwig Van Standard Lamp)&#8217;s photography from flickr.",
			page				=> $meta->{page},
			perpage			=> $meta->{perpage},
			total				=> $meta->{total},
			mt          => $meta,
			nxt 				=> $next,
			prv	 			  => $prev,
			frst				=> $first,
			lst 				=> $last,
			photos      => $photos,
	 };

};

## 

sub _get_flickr_photo_collection {
  my ($per_page,$page) = (shift,shift);
  my $api = new Flickr::API({'key' => 'fbcb61dd948f59db78012dc958b5e112'});
  my $response = $api->execute_method(
    'flickr.people.getPublicPhotos', {
        'user_id'  => '8361414@N05',
        'per_page' => $per_page,
        'page'     => $page,
    },
  );

  return $response->{tree}{children}[1]; 
}

sub _get_photos {
  my ($collection_ref,$page) = (shift,shift);
  my @photos;
  my @kids = @{$collection_ref->{children}};
  foreach(@kids) {
    next unless exists $_->{name};
    my $attr = $_->{attributes};
    my $img = "http://farm" . $attr->{farm} . ".static.flickr.com/" . $attr->{server} . "/" . $attr->{id} . "_" . $attr->{secret} . "_m.jpg";
    my $href = "/flick/view/" . $attr->{id} . "/page/" . $page;
    #my $href =   "http://farm" . $attr->{farm} . ".static.flickr.com/" . $attr->{server} . "/" . $attr->{id} . "_" . $attr->{secret} . "_b.jpg";
    my $title = $attr->{title};
    push @photos, { 'href' => $href, 'img' => $img, 'title' => $title };
  }
  return \@photos;
}

sub _get_meta {
  my $collection_ref = shift;
  return $collection_ref->{attributes};
}
