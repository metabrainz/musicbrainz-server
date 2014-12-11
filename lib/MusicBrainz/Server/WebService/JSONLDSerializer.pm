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
