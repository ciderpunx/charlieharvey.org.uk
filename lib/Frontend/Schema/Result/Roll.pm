use utf8;
package Frontend::Schema::Result::Roll;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Roll

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

=head1 TABLE: C<Rolls>

=cut

__PACKAGE__->table("Rolls");

=head1 ACCESSORS

=head2 RollID

  accessor: 'roll_id'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 64

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
);

=head1 PRIMARY KEY

=over 4

=item * L</RollID>

=back

=cut

__PACKAGE__->set_primary_key("RollID");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YjocRS0LVw133tEuEtgePQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
