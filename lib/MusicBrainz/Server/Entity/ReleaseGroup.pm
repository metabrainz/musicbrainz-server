package MusicBrainz::Server::Entity::ReleaseGroup;

use Moose;

use DBDefs;
use List::AllUtils qw( any );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

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
    predicate => 'has_cover_art',
);

# Cannot set cover art if none of the associated releases has cover art.
sub can_set_cover_art { return shift->has_cover_art; }

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
        $self->has_cover_art ? (cover_art => $self->cover_art) : (),
        firstReleaseDate    => $self->first_release_date ? $self->first_release_date->format : undef,
        # TODO: remove this once Autocomplete.js can use $c and releaseGroupType.js
        l_type_name         => $self->l_type_name,
        review_count        => $self->review_count,
        secondaryTypeIDs    => [map { $_->id } $self->all_secondary_types],
        typeID              => $self->primary_type_id,
        typeName            => $self->type_name,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
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
