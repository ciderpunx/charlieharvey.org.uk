use utf8;
package Frontend::Schema::Result::Topic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Topic

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

=head1 TABLE: C<Topics>

=cut

__PACKAGE__->table("Topics");

=head1 ACCESSORS

=head2 TopicID

  accessor: 'topic_id'
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

=head2 Summary

  accessor: 'summary'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "TopicID",
  {
    accessor => "topic_id",
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
  "Summary",
  {
    accessor => "summary",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</TopicID>

=back

=cut

__PACKAGE__->set_primary_key("TopicID");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y5xSFGm+ULOpa0AmbxSd4A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
