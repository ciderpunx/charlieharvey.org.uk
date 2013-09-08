use utf8;
package Frontend::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Comment

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

=head1 TABLE: C<comments>

=cut

__PACKAGE__->table("comments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 nick

  data_type: 'varchar'
  default_value: 'Anonymous Coward'
  is_nullable: 1
  size: 155

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 145

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 145

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 body

  data_type: 'text'
  is_nullable: 0

=head2 updated_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "nick",
  {
    data_type => "varchar",
    default_value => "Anonymous Coward",
    is_nullable => 1,
    size => 155,
  },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 145 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 145 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "body",
  { data_type => "text", is_nullable => 0 },
  "updated_at",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");
# TODO: writing comments, maybe pictures too?
__PACKAGE__->might_have('page_comment', 'Frontend::Schema::Result::PageComment', 'comment_id');
__PACKAGE__->many_to_many(page => 'page_comment', 'page');


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KZSb/Q+APJwkm8IlUl3GrQ

sub nice_updated {
	my $self = shift;
	my $date = $self->updated_at;
	$date =~ s/T.*//;
	return $date;
}
sub link {
	my $self = shift; 
	return '/comment/' . $self->id;
}
1;
