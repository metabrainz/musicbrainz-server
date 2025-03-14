package MusicBrainz::Server::WebService::Serializer::JSON::2::Artist;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{'sort-name'} = $entity->sort_name;
    $body{disambiguation} = $entity->comment // '';

    if ($entity->has_loaded_country_code) {
        $body{country} = $entity->country_code // JSON::null;
    }

    if ($toplevel)
    {
        $body{gender} = $entity->gender ? $entity->gender_name : JSON::null;
        $body{'gender-id'} = $entity->gender ? $entity->gender->gid : JSON::null;

        $body{area} = $entity->area ? serialize_entity($entity->area) : JSON::null;
        $body{'begin-area'} = $entity->begin_area ? serialize_entity($entity->begin_area) : JSON::null;
        $body{'end-area'} = $entity->end_area ? serialize_entity($entity->end_area) : JSON::null;

        do {
            local $MusicBrainz::Server::WebService::Serializer::JSON::2::Utils::show_artist_credit_aliases = 0;
            local $MusicBrainz::Server::WebService::Serializer::JSON::2::Utils::show_artist_credit_tags_and_genres = 0;

            $body{recordings} = list_of($entity, $inc, $stash, 'recordings')
                if ($inc && $inc->recordings);

            $body{releases} = list_of($entity, $inc, $stash, 'releases')
                if ($inc && $inc->releases);

            $body{'release-groups'} = list_of($entity, $inc, $stash, 'release_groups')
                if ($inc && $inc->release_groups);
        };

        $body{works} = list_of($entity, $inc, $stash, 'works')
            if ($inc && $inc->works);
    }

    return \%body;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

