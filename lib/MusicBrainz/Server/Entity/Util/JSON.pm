package MusicBrainz::Server::Entity::Util::JSON;

use strict;
use warnings;

use base 'Exporter';
use feature 'state';
use Scalar::Util qw( blessed reftype );

our @EXPORT_OK = qw(
    add_linked_entity
    encode_with_linked_entities
    to_json_array
    to_json_object
);

sub to_json_array {
    my $arr = shift;
    my $reftype = reftype $arr;
    if (defined $reftype && $reftype eq 'ARRAY') {
        return [map { to_json_object($_) } @$arr]
    }
    return undef;
}

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

# Used by TO_JSON methods to store linked entities which might be
# duplicated many times in the output, allowing them to be serialized
# just once.
#
# This is set and unset per request. See the dispatch methods in
# MusicBrainz::Server.
our $linked_entities;

sub add_linked_entity {
    my ($entity_type, $id, $entity) = @_;

    my $entities = ($linked_entities->{$entity_type} //= {});
    unless (
        # schema fixup creates type instances without id
        !defined $id ||
        # Ignore cases where `$entity` is undef. There's no situation
        # where we'd want to store an undefined value; that would also
        # block defined additions for the same entity later.
        !defined $entity ||
        # We set this key to `undef` before calling to_json_object
        # below to avoid infinite recursion. With the key added, the
        # `exists` check will fail.
        exists $entities->{$id}
    ) {
        $entities->{$id} = undef;
        $entities->{$id} = to_json_object($entity);
    }
    return;
}

sub encode_with_linked_entities {
    my ($json_encoder, $data) = @_;

    die 'Expected a hash ref' unless ref($data) eq 'HASH';

    my $encoded = $json_encoder->encode($data);
    if (defined $linked_entities) {
        my $encoded_linked_entities = $json_encoder->encode($linked_entities);
        $encoded =~ s/}$/,"linked_entities":$encoded_linked_entities}/;
    }

    return $encoded;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
