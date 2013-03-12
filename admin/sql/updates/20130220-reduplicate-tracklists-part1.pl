#!/usr/bin/perl
use strict;
use warnings;

use MusicBrainz::Server::Context;
use Log::Dispatch;
use DBI qw(:sql_types);

my $min_level = 'info';
my $log = Log::Dispatch->new( outputs => [ [ 'Screen', min_level => $min_level ] ] );
my $c = MusicBrainz::Server::Context->create_script_context;

sub reduplicate_tracklist {
    my ($tracklist_id, $medium_ids) = @_;

    $log->info ("Reduplicate tracklist $tracklist_id ".
                "(making ".$#$medium_ids." copies)\n");

    # If a tracklist is attached to e.g. 8 media, we need to go
    # through these steps:
    #
    #   1. Take the first medium in the list of linked media
    #      and attach all the tracks on the tracklist to it.
    #   2. For each of the 7 remaining media, make 7 copies
    #      of each track and attach those copies to all the
    #      remaining media.
    #
    # When those steps are done, the track is connected directly
    # to the medium, and the tracklist column and table can be
    # deleted.

    my $first_medium = shift @$medium_ids;

    $c->sql->do ("UPDATE track SET medium = ? WHERE tracklist = ?",
                 $first_medium, $tracklist_id);

    return unless $#$medium_ids >= 0;

    $c->sql->do (
        "INSERT INTO track (recording,tracklist,position,name," .
        "           artist_credit,length,edits_pending,last_updated," .
        "           number,medium) " .
        "    SELECT recording,tracklist,position,name,artist_credit, " .
        "           length,edits_pending,last_updated,number, " .
        "           new_medium " .
        "    FROM track, UNNEST(?::integer[]) new_medium " .
        "    WHERE tracklist=?; ",
        $medium_ids, $tracklist_id);
}

sub main {

    Sql::run_in_transaction(sub {
        $c->sql->do("ALTER TABLE track ADD COLUMN medium integer");
        $c->sql->do("ALTER TABLE track ".
                "ADD CONSTRAINT track_fk_medium ".
                "FOREIGN KEY (medium) REFERENCES medium(id);");
    }, $c->sql);

    Sql::run_in_transaction(sub {
        my $tracklists = $c->sql->select_list_of_hashes (
            "SELECT tracklist, array_agg(id) AS media ".
            "FROM medium GROUP BY tracklist;");

        for my $row (@$tracklists)
        {
            reduplicate_tracklist ($row->{tracklist}, $row->{media});
        }
    }, $c->sql);

    return 1;
}

main;
