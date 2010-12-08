package MusicBrainz::Server::Data::WatchArtist;
use Moose;
use namespace::autoclean;

use Carp;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use Try::Tiny;

with 'MusicBrainz::Server::Data::Role::Sql';

sub find_watched_artists {
    my ($self, $editor_id) = @_;
    my $query =
        'SELECT artist_name.name AS a_name, artist.id AS a_id,
                artist.gid AS a_gid
           FROM editor_watch_artist
           JOIN artist ON editor_watch_artist.artist = artist.id
           JOIN artist_name ON artist_name.id = artist.name
          WHERE editor = ?';

    return query_to_list(
        $self->c->dbh,
        sub { $self->c->model('Artist')->_new_from_row(shift, 'a_') },
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

sub find_new_releases {
    my ($self, $editor_id) = @_;

    use DateTime;
    use DateTime::Duration;
    use DateTime::Format::Pg;

    my $format = DateTime::Format::Pg->new;
    my $past_threshold = DateTime::Duration->new( weeks => 1 );

    my $query = 
        'SELECT DISTINCT ' . $self->c->model('Release')->_columns . '
           FROM ' . $self->c->model('Release')->_table . "
           JOIN release_meta rm ON rm.id = release.id
           JOIN artist_credit_name acn
               ON acn.artist_credit = release.artist_credit
           JOIN editor_watch_artist ewa ON ewa.artist = acn.artist
           JOIN editor_watch_preferences ewp ON ewp.editor = ewa.editor
          WHERE rm.date_added > ewp.last_checked
            AND release.date_year IS NOT NULL
            AND to_timestamp(
                date_year || '-' ||
                COALESCE(date_month, '01') || '-' ||
                COALESCE(date_day, '01'), 'YYYY-MM-DD') > (NOW() - ?::INTERVAL)";

    return query_to_list(
        $self->c->dbh, sub { $self->c->model('Release')->_new_from_row(shift) },
        $query, $format->format_duration($past_threshold),
    );
}

__PACKAGE__->meta->make_immutable;
1;
