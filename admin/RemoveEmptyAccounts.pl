#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use open ':std', ':encoding(UTF-8)';

use Getopt::Long;
use MusicBrainz::Server::Context;

my $dry_run = 0;
my $limit = 500;

GetOptions(
    'dry-run|d'    => \$dry_run,
) or usage();

sub usage {
    warn <<EOF;
Usage: $0 [options]

OPTIONS
    -d, --dry-run       Perform a trial run without removing any account

EOF
    exit(2);
};

my $c = MusicBrainz::Server::Context->create_script_context(
    database => 'MAINTENANCE',
);
my $c_cursor = MusicBrainz::Server::Context->create_script_context(
    database => 'MAINTENANCE',
    fresh_connector => 1,
);

my $query = <<~'SQL';
          SELECT e.id,
                 e.name
            FROM editor e
           WHERE e.email IS NULL
             AND deleted IS false
             AND privs = 0
             AND (   member_since < NOW() - INTERVAL '12 months'
                  OR member_since IS NULL)
  AND NOT EXISTS (SELECT 1
                    FROM application
                   WHERE application.owner = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_oauth_token
                   WHERE editor_oauth_token.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM vote
                   WHERE vote.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM edit
                   WHERE edit.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM edit_note
                   WHERE edit_note.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_artist
                   WHERE editor_subscribe_artist.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_artist_deleted
                   WHERE editor_subscribe_artist_deleted.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_collection
                   WHERE editor_subscribe_collection.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_label
                   WHERE editor_subscribe_label.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_label_deleted
                   WHERE editor_subscribe_label_deleted.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_editor
                   WHERE editor_subscribe_editor.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_series
                   WHERE editor_subscribe_series.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM editor_subscribe_series_deleted
                   WHERE editor_subscribe_series_deleted.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM area_tag_raw
                   WHERE area_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM artist_tag_raw
                   WHERE artist_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM event_tag_raw
                   WHERE event_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM instrument_tag_raw
                   WHERE instrument_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM label_tag_raw
                   WHERE label_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM place_tag_raw
                   WHERE place_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM recording_tag_raw
                   WHERE recording_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM release_tag_raw
                   WHERE release_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM release_group_tag_raw
                   WHERE release_group_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM series_tag_raw
                   WHERE series_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM work_tag_raw
                   WHERE work_tag_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM artist_rating_raw
                   WHERE artist_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM event_rating_raw
                   WHERE event_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM label_rating_raw
                   WHERE label_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM place_rating_raw
                   WHERE place_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM recording_rating_raw
                   WHERE recording_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM release_group_rating_raw
                   WHERE release_group_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM work_rating_raw
                   WHERE work_rating_raw.editor = e.id)
  AND NOT EXISTS (SELECT 1
                    FROM annotation
                   WHERE annotation.editor = e.id)
  AND NOT EXISTS (   SELECT 1
                       FROM editor_collection ec
                      WHERE ec.editor = e.id
                        AND ((
                                  (type != 5 OR name != 'Attending')
                                  AND
                                  (type != 6 OR name != 'Maybe attending')
                            )
                            OR EXISTS (SELECT 1
                                         FROM editor_collection_event ece
                                        WHERE ece.collection = ec.id)))
  AND NOT EXISTS (   SELECT 1
                       FROM editor_collection ec
                       JOIN editor_collection_collaborator ecc
                         ON ecc.collection = ec.id
                      WHERE ec.editor = e.id)
  AND NOT EXISTS (   SELECT 1
                       FROM editor_collection_collaborator ecc
                      WHERE ecc.editor = e.id)
             AND (   last_login_date IS NULL
                  OR last_login_date < NOW() - INTERVAL '12 months')
  SQL

$c_cursor->sql->begin;
$c_cursor->sql->do("DECLARE cursor NO SCROLL CURSOR FOR $query");

my $pull = sub {
    $c_cursor->sql->select("FETCH FORWARD $limit FROM cursor");
};
while ($pull->()) {
    $c->sql->begin;
    my @row;
    while (@row = $c_cursor->sql->next_row) {
        my ($editor_id, $editor_name) = @row;

        if ($dry_run) {
            print 'Removing account ' . $editor_name . " (dry run)\n";
        } else {
            print 'Removing account ' . $editor_name . "\n";
            # Remove preferences
            $c->sql->do(
                'DELETE FROM editor_preference WHERE editor = ?',
                $editor_id
            );
            # Remove languages
            $c->sql->do(
                'DELETE FROM editor_language WHERE editor = ?',
                $editor_id
            );
            # Remove any subscriptions *to* this editor
            $c->sql->do(<<~'SQL', $editor_id);
                DELETE FROM editor_subscribe_editor
                      WHERE subscribed_editor = ?
                SQL
            # Remove any collections by the editor (they should be all empty)
            $c->sql->do(
                'DELETE FROM editor_collection WHERE editor = ?',
                $editor_id
            );
            # Remove from the watch artist tables (unused since NGS or so)
            $c->sql->do(
                'DELETE FROM editor_watch_preferences WHERE editor = ?',
                $editor_id
            );
            $c->sql->do(
                'DELETE FROM editor_watch_artist WHERE editor = ?',
                $editor_id
            );
            $c->sql->do(
                'DELETE FROM editor_watch_release_group_type WHERE editor = ?',
                $editor_id
            );
            $c->sql->do(
                'DELETE FROM editor_watch_release_status WHERE editor = ?',
                $editor_id
            );
            # Actually delete the editor, which should not trigger any FKs now
            $c->sql->do('DELETE FROM editor WHERE id = ?', $editor_id);
        }
    }
    $c->sql->commit;
}

$c_cursor->sql->do('CLOSE cursor');
$c_cursor->sql->rollback;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
