use utf8;
package Frontend::Schema::Result::Todo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Todo

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

=head1 TABLE: C<todo>

=cut

__PACKAGE__->table("todo");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 cat

  data_type: 'varchar'
  default_value: 'uncat'
  is_nullable: 0
  size: 10

=head2 task

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=head2 priority

  data_type: 'tinyint'
  is_nullable: 1

=head2 due

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 start

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 complete

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 notes

  data_type: 'tinytext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "cat",
  {
    data_type => "varchar",
    default_value => "uncat",
    is_nullable => 0,
    size => 10,
  },
  "task",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
  "priority",
  { data_type => "tinyint", is_nullable => 1 },
  "due",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "start",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "complete",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "notes",
  { data_type => "tinytext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vLrJFxGJuOobZ0aMErVIoQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
