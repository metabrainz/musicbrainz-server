#!/usr/bin/env perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$FindBin::Bin/../../lib";

use Getopt::Long;

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );

my $remove = 1;

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->conn);

GetOptions(
    "remove!"           => \$remove,
    "help|h|?"          => sub { usage(); exit },
) or exit 2;

usage(), exit 2 if @ARGV;

sub usage
{
    print <<EOF;
Usage: UnusedNames.pl [OPTIONS]

Remove names that are no longer in use

Allowed options are:
        --[no]remove      [don't] remove unused names
                          (default is --remove)
    -h, --help            show this help (also "-?")

EOF
}

print localtime() . " : Finding unused names\n";
my %unused = (
    artist_name => $sql->select_single_column_array(q{
        SELECT id FROM artist_name a
        LEFT JOIN (
            SELECT name AS name FROM artist UNION ALL
            SELECT sortname AS name FROM artist UNION ALL
            SELECT name AS name FROM artist_alias UNION ALL
            SELECT name AS name FROM artist_credit UNION ALL
            SELECT name AS name FROM artist_credit_name
        ) s ON a.id = s.name
        WHERE s.name IS NULL
    }),
    label_name => $sql->select_single_column_array(q{
        SELECT id FROM label_name a
        LEFT JOIN (
            SELECT name AS name FROM label UNION ALL
            SELECT sortname AS name FROM label UNION ALL
            SELECT name AS name FROM label_alias
        ) s ON a.id = s.name
        WHERE s.name IS NULL
    }),
    release_name => $sql->select_single_column_array(q{
        SELECT id FROM release_name a
        LEFT JOIN (
            SELECT name AS name FROM release UNION ALL
            SELECT name AS name FROM release_group
        ) s ON a.id = s.name
        WHERE s.name IS NULL
    }),
    track_name => $sql->select_single_column_array(q{
        SELECT id FROM track_name a
        LEFT JOIN (
            SELECT name AS name FROM recording UNION ALL
            SELECT name AS name FROM track
        ) s ON a.id = s.name
        WHERE s.name IS NULL
    }),
    work_name => $sql->select_single_column_array(q{
        SELECT id FROM work_name a
        LEFT JOIN (
            SELECT name AS name FROM work UNION ALL
            SELECT name AS name FROM work_alias
        ) s ON a.id = s.name
        WHERE s.name IS NULL
    }),
);

$sql->begin;

while (my ($table, $ids) = each %unused) {
    unless (@$ids) {
        printf "%s : There are no unused entries in %s\n",
            scalar localtime, $table;
        next;
    }
    if($remove) {
        $sql->do("DELETE FROM $table WHERE id IN (" . placeholders(@$ids) . ")", @$ids);
        printf "%s : Removed %d from %s\n",
            scalar localtime, scalar @$ids, $table;
    }
    else {
        printf "%s : Would remove %d from %s\n",
            scalar localtime, scalar @$ids, $table;
    }
}

$sql->commit;
