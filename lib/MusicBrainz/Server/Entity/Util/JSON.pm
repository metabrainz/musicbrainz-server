package MusicBrainz::Server::Entity::Util::JSON;

use strict;
use warnings;

use base 'Exporter';
use feature 'state';
use Scalar::Util qw( blessed );

our @EXPORT_OK = qw(
    add_linked_entity
    encode_with_linked_entities
    to_json_object
);

sub to_json_object {
    my $obj = shift;
    if (blessed $obj) {
        my $to_json = $obj->can('TO_JSON');
        if ($to_json) {
            return $to_json->($obj);
        }
    }
    return $obj;
}

# Shadowed via local during serialization. Used by TO_JSON methods to store
# linked entities which might be duplicated many times in the output,
# allowing them to be serialized just once.
our $linked_entities;

sub add_linked_entity {
    my ($entity_type, $id, $entity) = @_;

    my $entities = ($linked_entities->{$entity_type} //= {});
    # schema fixup creates type instances without id
    unless (!defined $id || defined $entities->{$id}) {
        $entities->{$id} = to_json_object($entity);
    }
    return;
}

sub encode_with_linked_entities {
    my ($json_encoder, $data) = @_;

    die 'Expected a hash ref' unless ref($data) eq 'HASH';

    local $linked_entities = {};

    my $encoded = $json_encoder->encode($data);
    my $linked_entities = $json_encoder->encode($linked_entities);
    $encoded =~ s/}$/,"linked_entities":$linked_entities}/;

    return $encoded;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
