package MusicBrainz::Server::Data::WatchArtist;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( query_to_list );

with 'MusicBrainz::Server::Data::Role::Sql';

use aliased 'MusicBrainz::Server::Entity::EditorWatchArtist';

sub find_watched_artists {
    my ($self, $editor_id) = @_;
    my $query =
        'SELECT artist_name.name AS a_name, artist.id AS a_id,
                artist.gid AS a_gid, editor
           FROM editor_watch_artist
           JOIN artist ON editor_watch_artist.artist = artist.id
           JOIN artist_name ON artist_name.id = artist.name
          WHERE editor = ?';

    return query_to_list(
        $self->c->dbh,
        sub {
            my $row = shift;
            EditorWatchArtist->new(
                artist => $self->c->model('Artist')->_new_from_row($row, 'a_'),
                artist_id => $row->{a_id},
                editor_id => $row->{editor},
            );
        },
        $query, $editor_id
    );
}

__PACKAGE__->meta->make_immutable;
1;
