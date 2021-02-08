package MusicBrainz::Server::WebService::Serializer::JSON::2::Event;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( boolean serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{time} = $entity->formatted_time // "";
    $body{setlist} = $entity->setlist // "";
    $body{cancelled} = boolean($entity->cancelled);

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
