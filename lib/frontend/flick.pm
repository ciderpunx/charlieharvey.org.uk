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

get '/view/:id/page/:page/?' => sub {
	my $page = params->{page};
	my $id   = params->{id};

	my $ref   = _get_photo_info($id);
	my $photo = _get_photo_detail($ref);
	my $exif  = _get_photo_exif($id);

  template 'flick/view', {
			active_nav  => 'Images',
			title				=> $photo->{title} . " &mdash; from Charlie&#8217;s flickr photos page $page",
			description => $photo->{title} . ". A photograph by Charlie Harvey (aka Ludwig Van Standard Lamp).",
			exif				=> $exif,
			page				=> $page,
			photo				=> $photo,
	 };
};




## 

sub _get_flickr_photo_collection {
  my ($per_page,$page) = (shift,shift);
  my $api = new Flickr::API({'key' => config->{FLICKR_KEY}});
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

sub _get_photo_detail {
  my $ref = shift;
  my $child = $ref->{children};
  my %photo;
  my $owner = $child->[1]{attributes}{username};
  my $title = $child->[3]{children}[0]{content} || 'Untitled';
  my $descr = $child->[5]{children}[0]{content};
	if($descr) {
		$descr =~ s/&gt;/>/gi;
		$descr =~ s/&lt;/</gi;
		$descr =~ s/rel=&quot;nofollow&quot;//gi; 
		$descr =~ s/&quot;/"/gi;
		$descr =~ s/\n/<br \/>/g;
	}
  my $taken = $child->[9]{attributes}{taken};
  my $attr = $ref->{attributes};
  my $img = "http://farm" . $attr->{farm} . ".static.flickr.com/" . $attr->{server} . "/" . $attr->{id} . "_" . $attr->{secret} . "_b.jpg";
  my $original =   "http://farm" . $attr->{farm} . ".static.flickr.com/" . $attr->{server} . "/" . $attr->{id} . "_" . $attr->{originalsecret} . "_o.jpg";
  my $exif_href = "http://flickr.com/photo_exif.gne?id=" . $attr->{id}; 
  
  %photo = ( 
    'owner' => $owner,
    'title' => $title,
    'taken' => $taken,
    'description' => $descr,
    'original' => $original, 
    'img' => $img, 
    'exif_href' => $exif_href,
  ); 
  return \%photo;
}

sub _get_photo_info {
  my $id = shift;
  my $api = new Flickr::API({'key' => config->{FLICKR_KEY}});
  my $response = $api->execute_method(
      'flickr.photos.getInfo', {
      'photo_id' => $id,
    }
  );
  return $response->{tree}{children}[1]; 
}

sub _get_photo_exif {
  my $id = shift;
  my $api = new Flickr::API({'key' => config->{FLICKR_KEY}});
  my $response = $api->execute_method(
      'flickr.photos.getExif', {
      'photo_id' => $id,
    }
  );

  my %exif;

  for(@{$response->{tree}{children}[1]{children}}) {
    next unless exists $_->{name} && $_->{name} eq 'exif';
    next if $exif{lc($_->{attributes}{label})};
    if($_->{children}[3]{children}[0]{content})  {
      $exif{lc($_->{attributes}{label})} = $_->{children}[3]{children}[0]{content}; 
    }
    else {
      $exif{lc($_->{attributes}{label})} = $_->{children}[1]{children}[0]{content};
    }
  }

  return \%exif;
}
