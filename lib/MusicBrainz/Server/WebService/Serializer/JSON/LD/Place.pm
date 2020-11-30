package MusicBrainz::Server::WebService::Serializer::JSON::LD::Place;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area' => { property => 'containedIn' };

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'Place';
    $ret->{geo} = {
        '@type'   => 'GeoCoordinates',
        latitude  => $entity->coordinates->latitude + 0.0,
        longitude => $entity->coordinates->longitude + 0.0,
    } if $entity->coordinates;

    return $ret;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

