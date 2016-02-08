package MusicBrainz::Server::WebService::Serializer::JSON::2::Collection;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    count_of
    list_of
    number
    serialize_entity
);
use MusicBrainz::Server::Constants qw( %ENTITIES );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';

sub serialize {
    my ($self, $entity, $inc, $stash, $toplevel) = @_;

    my %body;
    my $entity_type = $entity->type->entity_type;

    $body{name} = $entity->name;
    $body{editor} = $entity->editor->name;
    $body{type} = $entity->type->name;
    $body{"entity-type"} = $entity_type;

    my $entity_properties = $ENTITIES{$entity_type};
    my $plural = $entity_properties->{plural};
    my $plural_url = $entity_properties->{plural_url};
    my $url = $entity_properties->{url};

    if ($toplevel) {
        my $items = $stash->store($entity)->{$plural}->{items} // [];

        if (@$items) {
            $body{$plural_url} = list_of($entity, $inc, $stash, $plural);
        }
    }

    $body{"$url-count"} = number($entity->entity_count);
    return \%body;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# =head1 COPYRIGHT

# Copyright (C) 2012 MetaBrainz Foundation

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

