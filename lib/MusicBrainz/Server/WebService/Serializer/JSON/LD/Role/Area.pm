package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );

parameter 'property' => (
    isa => 'Str',
    required => 0,
    default => sub { 'location' }
);

parameter 'include_birth_death' => (
    isa => 'CodeRef',
    required => 0,
    default => sub { sub { 0 } }
);

role {
    my $params = shift;
    my $property = $params->property;
    my $include = $params->include_birth_death;

    requires 'serialize';
    around serialize => sub {
        my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
        my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

        $ret->{$property} = serialize_entity($entity->area, $inc, $stash) if $entity->area;
        if ($include->($entity)) {
            $ret->{birthPlace} = serialize_entity($entity->begin_area, $inc, $stash) if $entity->can('begin_area') && $entity->begin_area;
            $ret->{deathPlace} = serialize_entity($entity->end_area, $inc, $stash) if $entity->can('end_area') && $entity->end_area;
        }

        return $ret;
    };
};

no Moose::Role;
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

