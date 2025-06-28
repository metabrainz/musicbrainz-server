#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use open ':std', ':encoding(UTF-8)';

use Getopt::Long;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( entities_with );

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

my $query = $c->model('Editor')->_build_unused_editor_query() . <<~"SQL";
    AND e.email IS NULL
    AND (   member_since < NOW() - INTERVAL '12 months'
         OR member_since IS NULL)
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
