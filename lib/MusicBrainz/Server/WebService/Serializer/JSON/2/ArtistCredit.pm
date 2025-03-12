package MusicBrainz::Server::WebService::Serializer::JSON::2::ArtistCredit;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub element { 'artist-credit'; }

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;

    no strict 'refs';
    *Utils = *MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;
    local $Utils::show_aliases =
        $Utils::show_aliases &&
        $Utils::show_artist_credit_aliases;
    local $Utils::show_tags_and_genres =
        $Utils::show_tags_and_genres &&
        $Utils::show_artist_credit_tags_and_genres;

    my @body = map {
        {
            'name' => $_->name,
            'joinphrase' => $_->join_phrase,
            'artist' => serialize_entity($_->artist, $inc, $stash),
        }
    } @{ $entity->names };

    return \@body;
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

