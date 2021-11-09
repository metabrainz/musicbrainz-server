package MusicBrainz::Server::Entity::ReleaseGroup;

use Moose;

use DBDefs;
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::ArtistCredit';

sub entity_type { 'release_group' }

has 'primary_type_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'primary_type' => (
    is => 'rw',
    isa => 'ReleaseGroupType'
);

has 'secondary_types' => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_secondary_type => 'push',
        all_secondary_types => 'elements'
    }
);

sub type_name
{
    my ($self) = @_;
    return undef unless any { defined } ($self->primary_type, $self->all_secondary_types);
    return join(' + ',
                ($self->primary_type ? $self->primary_type->name : ()),
                map { $_->name } $self->all_secondary_types
            );
}

sub l_type_name
{
    my ($self) = @_;
    return undef unless any { defined } ($self->primary_type, $self->all_secondary_types);
    return join(' + ',
                ($self->primary_type ? $self->primary_type->l_name() : ()),
                map { $_->l_name() } $self->all_secondary_types
            );
}

has 'first_release_date' => (
    is => 'rw',
    isa => 'PartialDate',
);

has 'release_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'cover_art' => (
    isa       => 'MusicBrainz::Server::Entity::Artwork::ReleaseGroup',
    is        => 'rw',
    predicate => 'has_loaded_cover_art',
);

has 'has_cover_art' => (
    is  => 'rw',
    isa => 'Bool',
);

# Cannot set cover art if none of the associated releases has cover art.
sub can_set_cover_art { return shift->has_loaded_cover_art; }

has 'review_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'most_recent_review' => (
    is => 'rw',
    isa => 'Maybe[CritiqueBrainz::Review]'
);

has 'most_popular_review' => (
    is => 'rw',
    isa => 'Maybe[CritiqueBrainz::Review]'
);

sub see_reviews_href {
    my ($self) = @_;
    return DBDefs->CRITIQUEBRAINZ_SERVER . '/release-group/' . $self->gid;
}

sub write_review_href {
    my ($self) = @_;
    return DBDefs->CRITIQUEBRAINZ_SERVER . '/review/write?release_group=' . $self->gid;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    if (my $primary_type = $self->primary_type) {
        $self->link_entity(
            'release_group_primary_type',
            $primary_type->id,
            $primary_type,
        );
    }

    for my $secondary_type ($self->all_secondary_types) {
        $self->link_entity(
            'release_group_secondary_type',
            $secondary_type->id,
            $secondary_type,
        );
    }

    return {
        %{ $self->$orig },
        $self->has_cover_art ? (cover_art => to_json_object($self->cover_art)) : (),
        firstReleaseDate    => $self->first_release_date ? $self->first_release_date->format : undef,
        hasCoverArt         => boolean_to_json($self->has_cover_art),
        # TODO: remove this once Autocomplete.js can use $c and releaseGroupType.js
        l_type_name         => $self->l_type_name,
        release_count       => $self->release_count,
        review_count        => $self->review_count,
        secondaryTypeIDs    => [map { $_->id } $self->all_secondary_types],
        typeID              => $self->primary_type_id,
        typeName            => $self->type_name,
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
