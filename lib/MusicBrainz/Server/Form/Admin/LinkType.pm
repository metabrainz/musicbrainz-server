package MusicBrainz::Server::Form::Admin::LinkType;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names {
    qw( parent_id child_order name link_phrase reverse_link_phrase
        long_link_phrase description priority attributes documentation
        is_deprecated has_dates entity0_cardinality entity1_cardinality
  ) }

has '+name' => ( default => 'linktype' );

has_field 'parent_id' => (
    type => 'Select',
);

has_field 'child_order' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    default => 0
);

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'reverse_link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'long_link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'description' => (
    type => 'Text',
    not_nullable => 1
);

has_field 'priority' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    default => 0
);

has_field 'attributes' => (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field 'attributes.type' => (
    type => 'PrimaryKey'
);

has_field 'attributes.active' => (
    type => 'Boolean'
);

has_field 'attributes.min' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

has_field 'attributes.max' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

has_field 'documentation' => (
    type => 'TextArea',
    not_nullable => 1
);

has root => (
    is => 'ro',
    required => 1
);

has_field is_deprecated => (
    type => 'Boolean'
);

has_field has_dates => (
    type => 'Boolean'
);

has_field 'entity0_cardinality' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    default => 0
);

has_field 'entity1_cardinality' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    default => 0
);

sub options_parent_id
{
    my ($self) = @_;
    return select_options_tree($self->ctx, $self->root, accessor => 'name');
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
