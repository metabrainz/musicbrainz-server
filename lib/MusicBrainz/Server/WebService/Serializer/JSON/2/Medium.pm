package MusicBrainz::Server::WebService::Serializer::JSON::2::Medium;
use Moose;
use JSON;
use List::UtilsBy qw( nsort_by sort_by );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( number serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{format} = $entity->format ? $entity->format->name : JSON::null;
    $body{position} = $entity->position;

    if (defined $inc && $inc->discids)
    {
        $body{discs} = [ map {
            serialize_entity($_->cdtoc, $inc, $stash)
        } sort_by { $_->cdtoc->discid } $entity->all_cdtocs ];
    }

    $body{"track-count"} = $entity->cdtoc_track_count;

    # Not all tracks in the tracklists may have been loaded.  If not all
    # tracks have been loaded, only one them will have been loaded which
    # therefore can be represented as if a query had been performed with
    # limit = 1 and offset = track->position.

    my @tracks = nsort_by { $_->position } $entity->all_tracks;
    my $min = scalar @tracks ? $tracks[0]->position : 0;

    if (@tracks && $entity->has_pregap) {
        $body{pregap} = $self->serialize_track($tracks[0], $inc, $stash);
    }

    my @list;
    foreach my $track_entity ($entity->cdtoc_tracks) {
        push @list, $self->serialize_track($track_entity, $inc, $stash);
    }

    if (scalar @list) {
        $body{tracks} = \@list ;
        $body{"track-offset"} = number($entity->has_pregap ? 0 : $min - 1);
    }

    return \%body;
};

sub serialize_track {
    my ($self, $entity, $inc, $stash) = @_;

    my %track_output = (
        id => $entity->gid,
        length => $entity->length,
        number => $entity->number,
        title => $entity->name
    );

    $track_output{recording} = serialize_entity($entity->recording, $inc, $stash)
        if $inc->recordings;

    $track_output{"artist-credit"} = serialize_entity($entity->artist_credit, $inc, $stash)
        if $inc->artist_credits;

    return \%track_output;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# =head1 COPYRIGHT

# Copyright (C) 2011,2012 MetaBrainz Foundation

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# =cut

