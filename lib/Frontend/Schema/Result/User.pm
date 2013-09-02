use utf8;
package Frontend::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 password

  data_type: 'char'
  is_nullable: 1
  size: 40

=head2 email_address

  data_type: 'char'
  is_nullable: 1
  size: 80

=head2 first_name

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 last_name

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 active

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "char", is_nullable => 1, size => 20 },
  "password",
  { data_type => "char", is_nullable => 1, size => 40 },
  "email_address",
  { data_type => "char", is_nullable => 1, size => 80 },
  "first_name",
  { data_type => "char", is_nullable => 1, size => 20 },
  "last_name",
  { data_type => "char", is_nullable => 1, size => 20 },
  "active",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fVkfrFcl84vr41NPacvVLQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
