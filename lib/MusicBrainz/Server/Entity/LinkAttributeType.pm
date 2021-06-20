package MusicBrainz::Server::Entity::LinkAttributeType;
use Moose;

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Translation::Relationships;
use MusicBrainz::Server::Translation::Instruments;
use MusicBrainz::Server::Translation::InstrumentDescriptions;

use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'LinkAttributeType',
};

sub entity_type { 'link_attribute_type' }

has 'root_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'root_gid' => (
    is => 'rw',
    isa => 'Str',
);

has 'root' => (
    is => 'rw',
    isa => 'LinkAttributeType',
);

has 'parent_gid' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

has 'parent_name' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

sub l_name {
    my $self = shift;
    my $rootid = defined $self->root ? $self->root->id : $self->root_id;
    if ($rootid == $INSTRUMENT_ROOT_ID) {
        return MusicBrainz::Server::Translation::Instruments::l($self->name);
    } else {
        return MusicBrainz::Server::Translation::Relationships::l($self->name);
    }
}

sub l_description {
    my $self = shift;
    my $rootid = defined $self->root ? $self->root->id : $self->root_id;
    if ($rootid == $INSTRUMENT_ROOT_ID) {
        return MusicBrainz::Server::Translation::InstrumentDescriptions::l($self->description);
    } else {
        return MusicBrainz::Server::Translation::Relationships::l($self->description);
    }
}

has 'free_text' => (
    is => 'rw',
    isa => 'Bool',
);

has 'creditable' => (
    is => 'rw',
    isa => 'Bool',
);

has 'instrument_comment' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

has 'instrument_type_id' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has 'instrument_type_name' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $root = $self->root;
    if ($root) {
        $self->link_entity('link_attribute_type', $root->id, $root);
    }

    my $parent = $self->parent;
    if ($parent) {
        $self->link_entity('link_attribute_type', $parent->id, $parent);
    }

    my $children = to_json_array($self->children);

    return {
        %{ $self->$orig },
        gid => $self->gid,
        root_id => $self->root_id + 0,
        root_gid => $self->root_gid,
        parent_id => defined $self->parent_id ? ($self->parent_id + 0) : undef,
        free_text => boolean_to_json($self->free_text),
        creditable => boolean_to_json($self->creditable),
        $self->instrument_comment ? (instrument_comment => $self->instrument_comment) : (),
        $self->instrument_type_id ? (instrument_type_id => $self->instrument_type_id) : (),
        $self->instrument_type_name ? (instrument_type_name => $self->instrument_type_name) : (),
        (defined $children && @$children) ? (children => $children) : (),
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
