use utf8;
package Frontend::Schema::Result::FeedsFeedMash;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::FeedsFeedMash

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

=head1 TABLE: C<feeds_feed_mashes>

=cut

__PACKAGE__->table("feeds_feed_mashes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 feed_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 feed_mash_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 image_xpath

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 flv_xpath

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "feed_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "feed_mash_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "image_xpath",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "flv_xpath",
  { data_type => "varchar", is_nullable => 1, size => 150 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e4lTvt+O2lkMwUR77fl/LA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
