package MusicBrainz::Server::WebService::Serializer::JSON::2::ReleaseGroup;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity list_of );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{"primary-type"} = $entity->primary_type
        ? $entity->primary_type->name : JSON::null;
    $body{"primary-type-id"} = $entity->primary_type
        ? $entity->primary_type->gid : JSON::null;
    $body{"secondary-types"} = [ map {
        $_->name } $entity->all_secondary_types ];
    $body{"secondary-type-ids"} = [ map {
        $_->gid } $entity->all_secondary_types ];
    $body{"first-release-date"} = $entity->first_release_date->format;
    $body{disambiguation} = $entity->comment // "";

    $body{"artist-credit"} = serialize_entity($entity->artist_credit, $inc, $stash)
        if $inc && ($inc->artist_credits || $inc->artists);

    $body{releases} = list_of($entity, $inc, $stash, "releases")
        if $inc && $inc->releases;

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

