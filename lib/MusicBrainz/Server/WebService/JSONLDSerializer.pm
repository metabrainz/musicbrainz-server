package MusicBrainz::Server::WebService::JSONLDSerializer;

use Moose;
use JSON;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );

sub mime_type { 'application/ld+json' }
sub fmt { 'jsonld' }

sub serialize
{
    my ($self, $type, $entity, $inc, $stash) = @_;

    my $ret = serialize_entity($entity, $inc, $stash, 1);
    return encode_json($ret);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
