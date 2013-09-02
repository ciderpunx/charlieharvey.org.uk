use utf8;
package Frontend::Schema::Result::Rating;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Rating

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

=head1 TABLE: C<Ratings>

=cut

__PACKAGE__->table("Ratings");

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

=head2 Rating

  accessor: 'rating'
  data_type: 'integer'
  is_nullable: 1

=head2 IP

  accessor: 'ip'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 96

=head2 RateTime

  accessor: 'rate_time'
  data_type: 'integer'
  default_value: 0
  is_nullable: 0

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
  "Rating",
  { accessor => "rating", data_type => "integer", is_nullable => 1 },
  "IP",
  {
    accessor => "ip",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 96,
  },
  "RateTime",
  {
    accessor      => "rate_time",
    data_type     => "integer",
    default_value => 0,
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</IP>

=item * L</RateTime>

=back

=cut

__PACKAGE__->set_primary_key("IP", "RateTime");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mxDCHX46eoVw1cuHjo4upw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
