package MusicBrainz::Server::WebService::Serializer::JSON::LD::Area;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );
use MusicBrainz::Server::Constants qw( $AREA_TYPE_COUNTRY $AREA_TYPE_CITY );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
# Role::LifeSpan is not included here because schema.org does not have
# properties for begin/end dates for areas, and since those fields are
# not highly used in MusicBrainz anyway.
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    if (defined $entity->type_id) {
        if ($entity->type_id == $AREA_TYPE_COUNTRY) {
            $ret->{'@type'} = 'Country';
        } elsif ($entity->type_id == $AREA_TYPE_CITY) {
            $ret->{'@type'} = 'City';
        } else {
            $ret->{'@type'} = 'AdministrativeArea';
        }
    }

    my $containment = $entity->containment;
    my $child_ret = $ret;
    for my $parent (@{$containment}) {
        my $parent_ret = serialize_entity($parent, $inc, $stash);
        $child_ret->{containedIn} = $parent_ret;
        $child_ret = $parent_ret;
    }

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

