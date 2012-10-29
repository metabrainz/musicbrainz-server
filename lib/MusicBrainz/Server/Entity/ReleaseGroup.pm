package MusicBrainz::Server::Entity::ReleaseGroup;

use Moose;

use List::AllUtils qw( any );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';

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
    is => 'ro',
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

has 'artist_credit_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'artist_credit' => (
    is => 'rw',
    isa => 'ArtistCredit',
    predicate => 'artist_credit_loaded',
);

has 'first_release_date' => (
    is => 'rw',
    isa => 'PartialDate',
);

has 'release_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'cover_art' => (
    isa       => 'MusicBrainz::Server::Entity::Artwork',
    is        => 'rw',
    predicate => 'has_cover_art',
);

# Cannot set cover art if none of the associated releases has cover art.
sub can_set_cover_art { return shift->has_cover_art; }

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
