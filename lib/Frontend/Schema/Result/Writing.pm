use utf8;
package Frontend::Schema::Result::Writing;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Frontend::Schema::Result::Writing

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

=head1 TABLE: C<writings>

=cut

__PACKAGE__->table("writings");

=head1 ACCESSORS

=head2 uid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 media

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 9

=head2 category

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 href

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 178

=head2 details

  data_type: 'mediumtext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "uid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "media",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 9 },
  "category",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 1,
  },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "href",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 178 },
  "details",
  { data_type => "mediumtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uid>

=back

=cut

__PACKAGE__->set_primary_key("uid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-08-25 16:58:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:giEp4PvYP9ORIeg5WWH0FA

__PACKAGE__->has_many('writing_tags', 'Frontend::Schema::Result::WritingTag', 'writing_id');
__PACKAGE__->many_to_many(tags => 'writing_tags', 'tag');
# TODO WritingComments
# __PACKAGE__->has_many('writing_comments', 'Frontend::Schema::Result::WritingComment', 'writing_id');
# __PACKAGE__->many_to_many(comments => 'writing_comments', 'comment');

sub link {
	my $self = shift; 
	return '/file/' . $self->id;
}
#TODO: strip html and stuff
sub auto_summary {
	my $self = shift;
	return substr($self->details, 0, 300);
}
sub updated_at {
	my $self=shift;
	$self->updated;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
