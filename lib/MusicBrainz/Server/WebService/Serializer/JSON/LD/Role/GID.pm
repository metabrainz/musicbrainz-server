package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID;
use Moose::Role;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use DBDefs;

with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::SameAs';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my $entity_type = ref_to_type($entity);
    my $entity_url = $ENTITIES{$entity_type}{url} // $entity_type;

    $ret->{'@id'} = DBDefs->CANONICAL_SERVER . '/' . $entity_url . '/' . $entity->gid;

    return $ret;
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

