package MusicBrainz::Server::Entity::Medium;
use Moose;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

has 'position' => (
    is => 'rw',
    isa => 'Int'
);

has 'track_count' => (
    is => 'rw',
    isa => 'Int',
);

has 'tracks' => (
    is => 'rw',
    isa => 'ArrayRef[Track]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_tracks => 'elements',
        add_track => 'push',
        clear_tracks => 'clear',
    }
);

has 'release_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'release' => (
    is => 'rw',
    isa => 'Release'
);

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'format_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'format' => (
    is => 'rw',
    isa => 'MediumFormat',
);

sub format_name
{
    my ($self) = @_;
    return $self->format ? $self->format->name : undef;
}

sub l_format_name
{
    my ($self) = @_;
    return $self->format ? $self->format->l_name : undef;
}

has 'cdtocs' => (
    is => 'rw',
    isa => 'ArrayRef[MediumCDTOC]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_cdtocs => 'elements',
        add_cdtoc => 'push'
    }
);

sub may_have_discids {
    my $self = shift;
    return !$self->format || $self->format->has_discids;
}


=head2 length

Attempt to return the duration of the medium in microseconds.  This
will return the length of the disc, by looking at the associated
discids or tracklists.

This will not load any data from the database, so make sure you load
either the associated tracklists + tracks, the MediumCDTOC +
CDTOC, or both.

=cut

sub length {
    my $self = shift;

    if (scalar $self->all_tracks > 0)
    {
        my $length = 0;

        for my $trk ($self->all_tracks)
        {
            return undef unless defined $trk->length;

            $length += $trk->length;
        }

        return $length;
    }
    elsif ($self->cdtocs->[0] && $self->cdtocs->[0]->cdtoc)
    {
        return $self->cdtocs->[0]->cdtoc->length;
    }
    else
    {
        return undef;
    }
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
