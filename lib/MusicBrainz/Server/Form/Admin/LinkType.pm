package MusicBrainz::Server::Form::Admin::LinkType;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names {
    qw( parent_id child_order name link_phrase reverse_link_phrase
        long_link_phrase description priority attributes documentation
        is_deprecated has_dates entity0_cardinality entity1_cardinality
        orderable_direction )
}

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

has_field orderable_direction => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    default => 0,
    range_start => 0,
    range_end => 2
);

sub options_parent_id
{
    my ($self) = @_;
    return select_options_tree($self->ctx, $self->root, accessor => 'name');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
