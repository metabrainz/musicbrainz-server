package MusicBrainz::Server::Data::WatchArtist;
use Moose;
use namespace::autoclean;

use Carp;
use MusicBrainz::Server::Data::Utils qw( query_to_list );
use Try::Tiny;

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

sub watch_artist {
    my ($self, %params) = @_;
    my $artist_id = delete $params{artist_id}
        or confess "Missing required parameter 'artist_id'";
    my $editor_id = delete $params{editor_id}
        or confess "Missing required parameter 'editor_id'";

    try {
        $self->sql->auto_commit(1);
        $self->sql->insert_row('editor_watch_artist', {
            editor => $editor_id,
            artist => $artist_id
        })
    }
    catch {
        my $err = $_;
        # XXX We need a real solution to detect these exceptions and throw
        # structured exceptions, maybe from Sql.pm -- ocharles
        unless ($err =~ /duplicate/) {
            # Duplicate row errors are fine, but rethrow any other errors
            die $err;
        }
    }
}

sub stop_watching_artist {
    my ($self, %params) = @_;
    my $artist_id = delete $params{artist_id}
        or confess "Missing required parameter 'artist_id'";
    my $editor_id = delete $params{editor_id}
        or confess "Missing required parameter 'editor_id'";

    $self->sql->auto_commit(1);
    $self->sql->do(
        'DELETE FROM editor_watch_artist WHERE artist = ? AND editor = ?',
        $artist_id, $editor_id
    );
}

sub is_watching {
    my ($self, %params) = @_;
    my $artist_id = delete $params{artist_id}
        or confess "Missing required parameter 'artist_id'";
    my $editor_id = delete $params{editor_id}
        or confess "Missing required parameter 'editor_id'";

    return $self->sql->select_single_value(
        'SELECT 1 FROM editor_watch_artist
          WHERE editor = ? AND artist = ?',
        $editor_id, $artist_id);
}

__PACKAGE__->meta->make_immutable;
1;
