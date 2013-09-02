use utf8;
package Frontend::Schema::Result::PageComment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::PageComment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<page_comments>

=cut

__PACKAGE__->table("page_comments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 page_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 comment_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "comment_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:la80iSl+BuD7y2fN3pzrmA


__PACKAGE__->belongs_to(page => 'Frontend::Schema::Result::Page', 'page_id');
__PACKAGE__->belongs_to(comment => 'Frontend::Schema::Result::Comment', 'comment_id');
1;
