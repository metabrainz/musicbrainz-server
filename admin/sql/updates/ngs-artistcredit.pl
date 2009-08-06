#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use Sql;

my $mb = MusicBrainz->new;
$mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->dbh);
my $sql2 = Sql->new($mb->dbh);

$sql->Begin;
eval {

$sql->Do("

CREATE TABLE tmp_artist_credit_repl
(
    old_ac INTEGER,
    new_ac INTEGER
);

SELECT a.id, a.name
    INTO TEMPORARY tmp_collabs
    FROM public.l_artist_artist l
        JOIN public.artist a ON l.link1=a.id
    WHERE link_type=11
    GROUP BY a.id, a.name HAVING count(*) > 1;

");

$sql->Select("
    SELECT a.id, link1 AS collab_id, a.name AS name_id, an.name
    FROM public.l_artist_artist l
        JOIN artist a ON l.link0=a.id
        JOIN artist_name an ON a.name=an.id
    WHERE link_type=11 AND link1 IN (SELECT id FROM tmp_collabs)");
my %members;
while (1) {
    my $row = $sql->NextRowHashRef or last;
    if (!exists $members{$row->{collab_id}}) {
        $members{$row->{collab_id}} = [];
    }
    push @{$members{$row->{collab_id}}}, $row;
}

open LOG, ">upgrade-artistcredit.log";

$sql->Select("SELECT id, name FROM tmp_collabs");
my $checked = 0;
my $total = $sql->Rows;
while (1) {
    my $row = $sql->NextRowRef or last;
    my ($collab_id, $collab_name) = @$row;

    $checked += 1;

    # Select all members of the collaboration
    my $members = $members{$collab_id} || [];

    # Try to find all member names in the collaboration name
    my $not_found = 0;
    my @indexes;
    my %indexes;
    foreach my $member (@$members) {
        my $index = index($collab_name, $member->{name});
        if ($index == -1) {
            $not_found = 1;
            last;
        }
        push @indexes, $index;
        $indexes{$index} = $member;
    }

    next if $not_found;

    # There must be no other ARs
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_artist_artist l
                                      WHERE link_type!=11 AND link1=? LIMIT 1",
                                      $collab_id);
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_artist_artist l
                                      WHERE link0=? LIMIT 1", $collab_id);
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_artist_label l
                                      WHERE link0=? LIMIT 1", $collab_id);
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_artist_track l
                                      WHERE link0=? LIMIT 1", $collab_id);
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_album_artist l
                                      WHERE link1=? LIMIT 1", $collab_id);
    next if $sql2->SelectSingleValue("SELECT 1 FROM public.l_artist_url l
                                      WHERE link0=? LIMIT 1", $collab_id);

    if ($checked % 100 == 1) {
        print STDERR "$checked/$total\r";
    }

    my $i = 0;
    my @artists;
    my $last_pos = 0;

    @indexes = sort { $a <=> $b } @indexes;
    foreach my $index (@indexes) {
        my $member = $indexes{$index};
        print LOG "  Found ", $member->{name}, " at ", $index, "\n";
        push @artists, {
            position => $i,
            artist => $member->{id},
            name => $member->{name_id},
            joinphrase => '',
        };
        if ($i > 0) {
            $artists[$i-1]->{joinphrase} = substr($collab_name, $last_pos, $index - $last_pos);
        }
        $last_pos = $index + length($member->{name});
        $i += 1;
    }
    if ($i > 0) {
        $artists[$i-1]->{joinphrase} = substr($collab_name, $last_pos);
    }

    # If there is a too long joinphrase, we are probably missing some artist(s)
    my $has_long_joinphrase = 0;
    foreach my $artist (@artists) {
        if (length($artist->{joinphrase}) > 5) {
            $has_long_joinphrase = 1;
            last;
        }
    }
    next if $has_long_joinphrase;

    print LOG "Collaboration: ($collab_id) $collab_name\n";

    my $ac_id = $sql2->SelectSingleValue("
        INSERT INTO artist_credit (artistcount) VALUES (?)
        RETURNING id", scalar(@artists));
    foreach my $artist (@artists) {
        print LOG "  * Artist '", $artist->{position}, "' '", $artist->{joinphrase}, "' \n";
        $sql2->Do("INSERT INTO artist_credit_name (artist_credit, position,
                   artist, name, joinphrase) VALUES (?, ?, ?, ?, ?)",
                   $ac_id, $artist->{position}, $artist->{artist},
                   $artist->{name}, $artist->{joinphrase} || undef);
    }

    $sql2->Do("INSERT INTO tmp_artist_credit_repl VALUES (?, ?)", $collab_id, $ac_id);

    #$sql2->Do("UPDATE recording SET artist_credit=? WHERE artist_credit=?", $ac_id, $collab_id);
    #$sql2->Do("UPDATE release SET artist_credit=? WHERE artist_credit=?", $ac_id, $collab_id);
    #$sql2->Do("UPDATE release_group SET artist_credit=? WHERE artist_credit=?", $ac_id, $collab_id);
    #$sql2->Do("UPDATE track SET artist_credit=? WHERE artist_credit=?", $ac_id, $collab_id);
    #$sql2->Do("UPDATE work SET artist_credit=? WHERE artist_credit=?", $ac_id, $collab_id);

    #$sql2->Do("DELETE FROM artist_credit WHERE id=?", $collab_id);
    #$sql2->Do("DELETE FROM artist WHERE id=?", $collab_id);
}
$sql->Finish;

    $sql->Commit;
};
if ($@) {
    printf STDERR "ERROR: %s\n", $@;
    $sql->Rollback;
}
