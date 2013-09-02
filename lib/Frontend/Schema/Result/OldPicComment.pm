use utf8;
package Frontend::Schema::Result::OldPicComment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::OldPicComment

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

=head1 TABLE: C<`old-pic-comments`>

=cut

__PACKAGE__->table(\"`old-pic-comments`");

=head1 ACCESSORS

=head2 CommentID

  accessor: 'comment_id'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

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

=head2 Comment

  accessor: 'comment'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 IP

  accessor: 'ip'
  data_type: 'varchar'
  is_nullable: 1
  size: 96

=cut

__PACKAGE__->add_columns(
  "CommentID",
  {
    accessor => "comment_id",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 64,
  },
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
  "Comment",
  {
    accessor => "comment",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
  "IP",
  { accessor => "ip", data_type => "varchar", is_nullable => 1, size => 96 },
);

=head1 PRIMARY KEY

=over 4

=item * L</CommentID>

=back

=cut

__PACKAGE__->set_primary_key("CommentID");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wpFhSv9uycDeYSVgZrM0kg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
