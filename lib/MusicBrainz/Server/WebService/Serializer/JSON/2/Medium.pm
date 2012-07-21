package MusicBrainz::Server::WebService::Serializer::JSON::2::Medium;
use Moose;
use JSON;
use List::UtilsBy qw( sort_by );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{format} = $entity->format ? $entity->format->name : JSON::null;

    $body{discids} = [ map +{
        id => $_->cdtoc->discid,
        sectors => $_->cdtoc->leadout_offset
    }, sort_by { $_->cdtoc->discid } $entity->all_cdtocs ]
        if defined $inc && $inc->discids;

    $body{"track-count"} = $entity->tracklist->track_count;

    return \%body;
};

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

