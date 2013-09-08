use utf8;
package Frontend::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Tag

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

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xcxL+mpDp+SCSEeq8xundQ

__PACKAGE__->might_have('page_tag', 'Frontend::Schema::Result::PageTag', 'tag_id');
__PACKAGE__->many_to_many(page => 'page_tag', 'page');
__PACKAGE__->might_have('writing_tag', 'Frontend::Schema::Result::WritingTag', 'tag_id');
__PACKAGE__->many_to_many(writing => 'writing_tag', 'writing');

sub link {
	my $self = shift; 
	return '/tag/' . $self->title;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
