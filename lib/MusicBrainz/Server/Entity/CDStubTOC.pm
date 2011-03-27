package MusicBrainz::Server::Entity::CDStubTOC;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'cdstub_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'cdstub' => (
    is => 'rw',
    isa => 'CDStub'
);

has 'discid' => (
    is => 'rw',
    isa => 'Str'
);

has 'track_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'leadout_offset' => (
    is => 'rw',
    isa => 'Int'
);

has 'track_offset' => (
    is => 'rw',
    isa => 'ArrayRef[Int]'
);

sub length
{
    my $self = shift;

    return int(($self->leadout_offset / 75) * 1000);
}

# XXX This should be called automatically when loading tracks
sub update_track_lengths
{
    my $self = shift;
    my $index = 0;
    my @offsets = @{$self->track_offset};
    push @offsets, $self->leadout_offset;
    foreach my $track (@{$self->cdstub->tracks}) {
        $track->length(int((($offsets[$index + 1] - $offsets[$index]) / 75) * 1000));
        $index++;
    }
}

with 'MusicBrainz::Server::Entity::Role::TOC';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Robert Kaye

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
