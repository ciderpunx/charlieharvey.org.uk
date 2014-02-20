use utf8;
package Frontend::Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Page - Pages for dotorg 2.0

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Tree::AdjacencyList>

=back

=cut

__PACKAGE__->load_components(qw( Tree::AdjacencyList InflateColumn::DateTime ));

=head1 TABLE: C<pages>

=cut

__PACKAGE__->table("pages");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 parent_id

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 body

  data_type: 'text'
  is_nullable: 0

=head2 related

  data_type: 'text'
  is_nullable: 0

=head2 is_live

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 is_cover

  data_type: 'tinyint'
  is_nullable: 1

=head2 slug

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 150

=head2 updated_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parent_id",
  { data_type => "integer", is_nullable => 1 },
  "title",
	{ data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "body",
  { data_type => "text", is_nullable => 0 },
  "related",
  { data_type => "text", is_nullable => 0 },
  "is_live",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_cover",
  { data_type => "tinyint", is_nullable => 1 },
  "slug",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 150 },
  "updated_at",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 1,
  },
  "created_at",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "NOW()",
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ac9xTtgnCuBmAlf5OJxFAQ

__PACKAGE__->parent_column('parent_id');
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many('page_tags', 'Frontend::Schema::Result::PageTag', 'page_id');
__PACKAGE__->has_many('page_comments', 'Frontend::Schema::Result::PageComment', 'page_id');
__PACKAGE__->many_to_many(tags => 'page_tags', 'tag');
__PACKAGE__->many_to_many(comments => 'page_comments', 'comment');

sub is_root {
    my ($self) = @_;
    return !$self->parent_id;
}
sub tag_str {
    my $self = shift;
    return join ', ', sort map { lc $_->title} $self->tags;
}
sub recent_children {
    my ($self,$max) = (shift,shift);
		$max = 5 if(!$max);
    my $rs   = $self->result_source->resultset->search(
        { parent_id => { '=', $self->id } ,
					is_live => {'=', 1},
				},
        { 
					order_by => {-desc => 'created_at'},
          rows    => $max, 
				}
    );
    return $rs->all;
}
sub top_categories {
    my $self = shift;
    my $rs   = $self->result_source->resultset->search(
        { parent_id => { '=', 1} ,
					is_live => {'=', 1},
				},
        { 
					order_by => {-desc => 'created_at'},
				}
    );
    return $rs->all;
}
sub auto_summary {
	my $self = shift; 
	my $summary = $self->body;
  $summary =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;
  $summary = substr($summary,0,300);
  $summary =~ s/&\w*$//;	   # remove trailing broken entities &am and such
  $summary =~ s/[\r\n"]+//g; # remove newlines and quotes
  $summary =~ s/\s+/ /g;	   # squeeze whitespace
  $summary =~ s/^\s+//;		   # chop leading whitespace
  $summary =~ s/\s+$//;		   # chop trailing whitespace
	return $summary;
}

sub link {
	my $self = shift; 
	return '/page/' . $self->slug;
}

sub nice_updated {
	my $self = shift;
	my $date = $self->updated_at;
	$date =~ s/T.*//;
	return $date;
}
sub nice_created {
	my $self = shift;
	my $date = $self->created_at;
	$date =~ s/T.*//;
	return $date;
}

1;
