package MusicBrainz::Server::WebService::Serializer::JSON::2::Recording;
use DBDefs;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    boolean
    number
    serialize_entity
    list_of
);
use List::UtilsBy 'sort_by';

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{length} = number($entity->length);
    $body{video} = boolean($entity->video);

    if ($entity->artist_credit && ($toplevel || ($inc && $inc->artist_credits))) {
        $body{"artist-credit"} = serialize_entity($entity->artist_credit, $inc, $stash);
    }

    $body{releases} = list_of($entity, $inc, $stash, "releases")
        if ($toplevel && $inc && $inc->releases);

    if ($inc && $inc->isrcs) {
        my $opts = $stash->store($entity);
        $body{isrcs} = [
            map { $_->isrc } sort_by { $_->isrc } @{ $opts->{isrcs} }
        ];
    }

    if (
        $toplevel &&
        DBDefs->ACTIVE_SCHEMA_SEQUENCE == 26 &&
        defined $entity->first_release_date
    ) {
        $body{'first-release-date'} = $entity->first_release_date->format;
    }

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

