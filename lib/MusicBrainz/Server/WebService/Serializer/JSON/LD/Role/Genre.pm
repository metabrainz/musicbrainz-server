package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre;
use Moose::Role;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw(
    list_or_single
);

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my $store = $stash->store($entity);
    my $tags = $store->{top_tags};
    my $genre_map = $store->{genre_map};
    my @genres = map {
        my $genre = $genre_map->{ $_->{tag}{name} };
        $genre ? (DBDefs->JSON_LD_ID_BASE_URI . '/genre/' . $genre->{gid}) : ()
    } @$tags;

    if (@genres) {
        $ret->{genre} = list_or_single(@genres);
    }

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
