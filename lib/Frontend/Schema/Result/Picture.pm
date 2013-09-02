use utf8;
package Frontend::Schema::Result::Picture;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Picture

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

=head1 TABLE: C<Pictures>

=cut

__PACKAGE__->table("Pictures");

=head1 ACCESSORS

=head2 RollID

  accessor: 'roll_id'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 FrameID

  accessor: 'frame_id'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 ParentTopicID

  accessor: 'parent_topic_id'
  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 Description

  accessor: 'description'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 Views

  accessor: 'views'
  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 Rating

  accessor: 'rating'
  data_type: 'float'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "RollID",
  {
    accessor => "roll_id",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
  "FrameID",
  {
    accessor => "frame_id",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
  "ParentTopicID",
  {
    accessor => "parent_topic_id",
    data_type => "varchar",
    is_nullable => 1,
    size => 64,
  },
  "Description",
  {
    accessor => "description",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
  "Views",
  {
    accessor      => "views",
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 1,
  },
  "Rating",
  {
    accessor      => "rating",
    data_type     => "float",
    default_value => 0,
    is_nullable   => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</RollID>

=item * L</FrameID>

=back

=cut

__PACKAGE__->set_primary_key("RollID", "FrameID");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vQCwTUbrnQwzE4VBIHo4Pg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
