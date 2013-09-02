use utf8;
package Frontend::Schema::Result::WritingTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::WritingTag

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

=head1 TABLE: C<writing_tags>

=cut

__PACKAGE__->table("writing_tags");

=head1 ACCESSORS

=head2 tag_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 writing_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tag_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "writing_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag_id>

=item * L</writing_id>

=back

=cut

__PACKAGE__->set_primary_key("tag_id", "writing_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MXQu0wrhDSQURyFPpnTQiA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
