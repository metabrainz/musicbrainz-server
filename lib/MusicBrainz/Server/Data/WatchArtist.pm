package MusicBrainz::Server::Data::WatchArtist;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use Carp;
use DateTime::Duration;
use DateTime::Format::Pg;
use List::AllUtils qw( mesh );
use MusicBrainz::Server::Data::Utils qw( placeholders );
use Try::Tiny;

use aliased 'MusicBrainz::Server::Entity::EditorWatchPreferences';

with 'MusicBrainz::Server::Data::Role::Sql';

has 'date_formatter' => (
    is => 'ro',
    default => sub { DateTime::Format::Pg->new },
    handles => [qw( parse_duration format_duration )]
);

sub find_watched_artists {
    my ($self, $editor_id) = @_;
    my $query =
        'SELECT artist.name AS a_name, artist.id AS a_id,
                artist.gid AS a_gid
           FROM editor_watch_artist
           JOIN artist ON editor_watch_artist.artist = artist.id
          WHERE editor = ?';

    $self->c->model('Artist')->query_to_list($query, [$editor_id], sub {
        my ($model, $row) = @_;

        $model->_new_from_row($row, 'a_');
    });
}

sub watch_artist {
    my ($self, %params) = @_;
    my $artist_id = delete $params{artist_id}
        or confess q(Missing required parameter 'artist_id');
    my $editor_id = delete $params{editor_id}
        or confess q(Missing required parameter 'editor_id');

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
    my $artist_ids = delete $params{artist_ids}
        or confess q(Missing required parameter 'artist_ids');
    my $editor_id = delete $params{editor_id}
        or confess q(Missing required parameter 'editor_id');

    $self->sql->auto_commit(1);
    $self->sql->do(
        'DELETE FROM editor_watch_artist
          WHERE artist IN (' . placeholders(@$artist_ids) . ')
            AND editor = ?',
        @$artist_ids, $editor_id
    );
}

sub is_watching {
    my ($self, %params) = @_;
    my $artist_id = delete $params{artist_id}
        or confess q(Missing required parameter 'artist_id');
    my $editor_id = delete $params{editor_id}
        or confess q(Missing required parameter 'editor_id');

    return $self->sql->select_single_value(
        'SELECT 1 FROM editor_watch_artist
          WHERE editor = ? AND artist = ?',
        $editor_id, $artist_id);
}

sub find_new_releases {
    my ($self, $editor_id) = @_;

    my $past_threshold = DateTime::Duration->new( weeks => 1 );

    my $query =
        'SELECT DISTINCT ' . $self->c->model('Release')->_columns . '
           FROM ' . $self->c->model('Release')->_table . q(
           JOIN release_group rg ON release_group = rg.id
           JOIN artist_credit_name acn
               ON acn.artist_credit = release.artist_credit
           JOIN editor_watch_artist ewa ON ewa.artist = acn.artist
           JOIN editor_watch_preferences ewp ON ewp.editor = ewa.editor
           JOIN editor_watch_release_group_type watch_rgt
                ON watch_rgt.release_group_type = rg.type
           JOIN editor_watch_release_status watch_rs
                ON watch_rs.release_status = release.status
          WHERE release.date_year IS NOT NULL
            AND to_timestamp(
                    date_year || '-' ||
                    COALESCE(date_month, '01') || '-' ||
                    COALESCE(date_day, '01'), 'YYYY-MM-DD')
                  BETWEEN (NOW() - ?::INTERVAL) AND
                          (NOW() + ewp.notification_timeframe));

    $self->c->model('Release')->query_to_list(
        $query,
        [$self->format_duration($past_threshold)],
    );
}

sub find_editors_to_notify {
    my ($self) = @_;
    my $query =
        'SELECT DISTINCT editor.* FROM editor
           JOIN editor_watch_artist ewa ON ewa.editor = editor.id
           JOIN editor_watch_preferences ewp ON ewp.editor = ewa.editor
          WHERE ewp.notify_via_email = TRUE';

    $self->c->model('Editor')->query_to_list($query);
}

sub update_last_checked {
    my $self = shift;
    $self->sql->auto_commit(1);
    $self->sql->do( 'UPDATE editor_watch_preferences SET last_checked = NOW()');
}

sub save_preferences {
    my ($self, $editor_id, $preferences) = @_;
    $self->sql->begin;
    $self->sql->do(
        'DELETE FROM editor_watch_release_group_type WHERE editor = ?',
        $editor_id);
    $self->sql->do(
        'DELETE FROM editor_watch_release_status WHERE editor = ?',
        $editor_id);

    if (my @types = grep { $_ } @{ $preferences->{type_id} }) {
        my @type_editors = ($editor_id) x @types;
        $self->sql->do(
            'INSERT INTO editor_watch_release_group_type
            (editor, release_group_type) VALUES ' .
                join(', ', ('(?, ?)') x @types),
            mesh @type_editors, @types);
    }

    if (my @status = grep { $_ } @{ $preferences->{status_id} }) {
        my @status_editors = ($editor_id) x @status;
        $self->sql->do(
            'INSERT INTO editor_watch_release_status
                (editor, release_status) VALUES ' .
                    join(', ', ('(?, ?)') x @status),
            mesh @status_editors, @status);
    }

    $self->sql->do(
        'UPDATE editor_watch_preferences SET
            notify_via_email = ?,
            notification_timeframe = ?
          WHERE editor = ?',
          $preferences->{notify_via_email},
          $self->format_duration(
              DateTime::Duration->new(
                  days => $preferences->{notification_timeframe})),
            $editor_id);

    $self->sql->commit;
}

sub load_preferences {
    my ($self, $editor_id) = @_;

    my $prefs = $self->sql->select_single_row_hash(
        'SELECT * FROM editor_watch_preferences WHERE editor = ?', $editor_id);

    my @types = $self->c->model('ReleaseGroupType')->query_to_list(
        'SELECT id, name FROM release_group_type
           JOIN editor_watch_release_group_type wrgt
             ON wrgt.release_group_type = id
          WHERE editor = ?',
        [$editor_id],
    );

    my @statuses = $self->c->model('ReleaseStatus')->query_to_list(
        'SELECT id, name FROM release_status
           JOIN editor_watch_release_status wrs
             ON wrs.release_status = id
          WHERE editor = ?',
        [$editor_id],
    );

    return EditorWatchPreferences->new(
        notify_via_email => $prefs->{notify_via_email},
        notification_timeframe => $self->parse_duration(
            $prefs->{notification_timeframe}),
        types => \@types,
        statuses => \@statuses,
    );
}

sub delete_editor {
    my ($self, $editor_id) = @_;
    $self->sql->do('DELETE FROM editor_watch_preferences WHERE editor = ?', $editor_id);
    $self->sql->do('DELETE FROM editor_watch_artist WHERE editor = ?', $editor_id);
    $self->sql->do('DELETE FROM editor_watch_release_group_type WHERE editor = ?', $editor_id);
    $self->sql->do('DELETE FROM editor_watch_release_status WHERE editor = ?', $editor_id);
}

__PACKAGE__->meta->make_immutable;
1;
