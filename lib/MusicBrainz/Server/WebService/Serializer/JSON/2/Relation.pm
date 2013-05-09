package MusicBrainz::Server::WebService::Serializer::JSON::2::Relation;
use Moose;
use Hash::Merge qw(merge);
use String::CamelCase qw(camelize);
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( date_period serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub element { 'relation'; }

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my $body;

    $body->{type} = $entity->link->type->name;
    $body->{"type-id"} = $entity->link->type->gid;
    $body->{direction} = $entity->direction == 2 ? "backward" : "forward";

    $body = merge ($body, date_period ($entity->link));
    $body->{attributes} = [ map { $_->name } $entity->link->all_attributes ];
    $body->{$entity->target_type} = serialize_entity ($entity->target);

    return $body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
