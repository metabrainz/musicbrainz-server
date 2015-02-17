package MusicBrainz::Server::WebService::Serializer::JSON::2::CDTOC;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of number );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{id} = $entity->discid;
    $body{"offset-count"} = number($entity->track_count);
    $body{sectors} = number($entity->leadout_offset);

    my @list;
    foreach my $track (0 .. ($entity->track_count - 1)) {
        push @list, number($entity->track_offset->[$track]);
    }

    if (scalar @list) {
        $body{offsets} = \@list;
    }

    if ($toplevel)
    {
        $body{releases} = list_of($entity, $inc, $stash, "releases", $toplevel);
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# =head1 COPYRIGHT

# Copyright (C) 2013 MetaBrainz Foundation

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

