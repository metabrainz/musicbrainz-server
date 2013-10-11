package MusicBrainz::Server::Entity::Recording;

use Moose;
use MusicBrainz::Server::Entity::Types;
use List::UtilsBy qw( uniq_by );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';

has 'artist_credit_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'artist_credit' => (
    is => 'rw',
    isa => 'ArtistCredit',
    clearer => 'clear_artist_credit',
);

has 'track_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'track' => (
    is => 'rw',
    isa => 'Track'
);

has 'length' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'video' => (
    is => 'rw',
    isa => 'Bool',
);

has 'isrcs' => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        add_isrc => 'push',
        all_isrcs => 'elements'
    }
);

sub related_works {
    my $self = shift;
    return uniq_by { $_->id }
    map {
        $_->entity1
    } grep {
        $_->link && $_->link->type && $_->link->type->entity1_type eq 'work'
    } $self->all_relationships;
}

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
