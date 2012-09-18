package MusicBrainz::Server::Entity::Artwork;

use Moose;
use DBDefs;
use MusicBrainz::Server::Entity::CoverArtType;
use MusicBrainz::Server::Constants qw( $COVERART_FRONT_TYPE $COVERART_BACK_TYPE );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

has comment => (
    is => 'rw',
    isa => 'Str'
);

has ordering => (
    is => 'rw',
    isa => 'Int',
);

has cover_art_types => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::CoverArtType]',
    trigger => sub {
        my ($self, $types, $old_types) = @_;

        $self->is_front (0);
        $self->is_back (0);

        foreach my $type (@$types) {
            $self->is_front (1) if $type->id == $COVERART_FRONT_TYPE;
            $self->is_back (1) if $type->id == $COVERART_BACK_TYPE;
        };
    }
);

sub types { return [ map { $_->name } @{ shift->cover_art_types } ]; }

has is_front => (
    is => 'rw',
    isa => 'Bool',
);

has is_back => (
    is => 'rw',
    isa => 'Bool',
);

# has approved => (
#     is => 'rw',
#     isa => 'Bool',
#     coerce => 1
# );

has release_id => (
    is => 'rw',
    isa => 'Int',
);

has release => (
    is => 'rw',
    isa => 'Release',
    trigger => sub {
        my ($self, $release, $old_release) = @_;

        my $urlprefix = DBDefs::COVER_ART_ARCHIVE_DOWNLOAD_PREFIX .
            "/release/" . $self->release->gid . "/" . $self->id;

        $self->image           ($urlprefix . ".jpg");
        $self->small_thumbnail ($urlprefix . "-250.jpg");
        $self->large_thumbnail ($urlprefix . "-500.jpg");
    }
);

has edit_id => (
    is => 'rw',
    isa => 'Int',
);

has image => (
    is => 'rw',
    isa => 'Str',
);

has small_thumbnail => (
    is => 'rw',
    isa => 'Str',
);

has large_thumbnail => (
    is => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
