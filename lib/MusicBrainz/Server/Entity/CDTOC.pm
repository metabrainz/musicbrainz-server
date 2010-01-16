package MusicBrainz::Server::Entity::CDTOC;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'discid' => (
    is => 'rw',
    isa => 'Str'
);

has 'freedbid' => (
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

has 'degraded' => (
    is => 'rw',
    isa => 'Boolean'
);

sub first_track
{
    return 1;
}

sub last_track
{
    my ($self) = @_;

    return $self->track_count;
}

sub sectors_to_ms
{
    return $_[0] / 75 * 1000;
}

sub length
{
    my ($self) = @_;

    return sectors_to_ms($self->leadout_offset);
}

sub track_details
{
    my ($self) = @_;

    my @track_info;
    foreach my $track (0 .. ($self->track_count - 1)) {
        my %info;
        $info{start_sectors} = $self->track_offset->[$track];
        $info{start_time} = sectors_to_ms($info{start_sectors});
        $info{end_sectors} = ($track == $self->track_count - 1)
            ? $self->leadout_offset
            : $self->track_offset->[$track + 1];
        $info{end_time} = sectors_to_ms($info{end_sectors});
        $info{length_sectors} = $info{end_sectors} - $info{start_sectors};
        $info{length_time} = sectors_to_ms($info{length_sectors});
        push @track_info, \%info;
    }
    return @track_info;
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
