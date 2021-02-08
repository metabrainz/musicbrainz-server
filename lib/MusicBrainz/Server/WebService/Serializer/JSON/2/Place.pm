package MusicBrainz::Server::WebService::Serializer::JSON::2::Place;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{address} = $entity->address;
    $body{area} = $entity->area ? serialize_entity($entity->area) : JSON::null;
    $body{coordinates} = $entity->coordinates ?
            {
                latitude => $entity->coordinates->latitude + 0.0,
                longitude => $entity->coordinates->longitude + 0.0,
            }
        : JSON::null;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

