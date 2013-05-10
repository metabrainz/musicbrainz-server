package MusicBrainz::Server::WebService::Serializer::JSON::2::Artist;
use Moose;
use List::UtilsBy 'sort_by';
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Annotation';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::IPIs';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{"sort-name"} = $entity->sort_name;
    $body{disambiguation} = $entity->comment // "";

    if ($toplevel)
    {
        $body{type} = $entity->type_name;

        $body{country} = $entity->area && $entity->area->country_code
            ? $entity->area->country_code : JSON::null;

        $body{area} = $entity->area ? serialize_entity($entity->area) : JSON::null;
        $body{begin_area} = $entity->begin_area ? serialize_entity($entity->begin_area) : JSON::null;
        $body{end_area} = $entity->end_area ? serialize_entity($entity->end_area) : JSON::null;

        $body{recordings} = list_of ($entity, $inc, $stash, "recordings")
            if ($inc && $inc->recordings);

        $body{releases} = list_of ($entity, $inc, $stash, "releases")
            if ($inc && $inc->releases);

        $body{"release-groups"} = list_of ($entity, $inc, $stash, "release_groups")
            if ($inc && $inc->release_groups);

        $body{works} = list_of ($entity, $inc, $stash, "works")
            if ($inc && $inc->works);
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011,2012 MetaBrainz Foundation

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

