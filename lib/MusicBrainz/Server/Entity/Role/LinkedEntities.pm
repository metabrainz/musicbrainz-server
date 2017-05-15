package MusicBrainz::Server::Entity::Role::LinkedEntities;

use Moose::Role;

requires 'TO_JSON';

# Shadowed via local during serialization. Used by TO_JSON methods to store
# linked entities which might be duplicated many times in the output,
# allowing them to be serialized just once.
our $_linked_entities;

sub add_linked_entity {
    my ($self, $entity_type, $id, $entity) = @_;

    my $entities = ($_linked_entities->{$entity_type} //= {});
    unless (defined $entities->{$id}) {
        $entities->{$id} = $entity->TO_JSON;
    }
    return;
}

sub serialize_with_linked_entities {
    my ($self, $target) = @_;

    $target //= {};
    local $_linked_entities = {};
    $target->{entity} = $self->TO_JSON;
    $target->{linked_entities} = $_linked_entities;
    return $target;
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
