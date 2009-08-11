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

# Generate a table with all member artists
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

# Generate a table with all aliases for member artists
$sql->Select("
    SELECT a.artist AS id, a.name AS name_id, an.name
    FROM public.l_artist_artist l
        JOIN artist_alias a ON l.link0=a.artist
        JOIN artist_name an ON a.name=an.id
    WHERE link_type=11 AND link1 IN (SELECT id FROM tmp_collabs)");
my %aliases;
while (1) {
    my $row = $sql->NextRowHashRef or last;
    if (!exists $aliases{$row->{id}}) {
        $aliases{$row->{id}} = [];
    }
    push @{$aliases{$row->{id}}}, $row;
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
        my $index;

        # Add the primary name
        my @names = ($member);
        # Add aliases
        if (exists $aliases{$member->{id}}) {
            push @names, @{$aliases{$member->{id}}};
        }
        # Add "F. Bar", "Foo" and "Bar" from names like "Foo Bar"
        if ($member->{name} =~ /^\w+ \w+$/) {
            my $abbr = $member->{name};
            my $first = $member->{name};
            my $last = $member->{name};
            $abbr =~ s/^(.)[^ ]+ /$1. /;
            $first =~ s/ .*//;
            $last =~ s/.*? (((van|von|de) )?[^ ]+)$/$1/i;
            push @names, { name_id => undef, name => $abbr };
            push @names, { name_id => undef, name => $first };
            push @names, { name_id => undef, name => $last };
        }

        # Sort names by length so longest matches first
        @names = sort { length $b->{name} <=> length $a->{name} } @names;

        for my $name (@names) {
            $index = index(lc($collab_name), lc($name->{name}));
            if ($index != -1) {
                # Remember which name matched
                $member->{'creditname'} = $name;
                last;
            }
        }
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
    next if $indexes[0] != 0;

    my $ambiguous = 0;
    foreach my $index (@indexes) {
        # Two or more artists matched the same part of the name
        if ($index < $last_pos) {
            $ambiguous = 1;
            last;
        }
        my $member = $indexes{$index};
        #print LOG "  Found ", $member->{name}, " at ", $index, "\n";
        push @artists, {
            position => $i,
            artist => $member->{id},
            artist_name => $member->{name},
            name_id => $member->{creditname}->{name_id},
            name => $member->{creditname}->{name},
            joinphrase => '',
        };
        if ($i > 0) {
            $artists[$i-1]->{joinphrase} = substr($collab_name, $last_pos, $index - $last_pos);
        }
        $last_pos = $index + length($member->{creditname}->{name});
        $i += 1;
    }
    if ($i > 0) {
        $artists[$i-1]->{joinphrase} = substr($collab_name, $last_pos);
    }
    next if $ambiguous;

    # If there is a too long joinphrase, we are probably missing some artist(s)
    my $has_long_joinphrase = 0;
    foreach my $artist (@artists) {
        # The two here as bytes should be \x{0442}\x{0430} and \x{0A05}\x{00A24}\x{0A47} if the joinphrase is a proper Perl Unicode string
        if (length($artist->{joinphrase}) > 5 && $artist->{joinphrase} !~ /^( (avec|feat\.|featuring|introducing|joins|loved|meets?|pres\.|presents|starring|thanx|versus|with|\xd1\x82\xd0\xb0|\xe0\xa8\x85\xe0\xa8\xa4\xe0\xa9\x87) |, (and|with) )?$/i) {
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
        print LOG "  * Artist ", $artist->{position}, ". '", $artist->{artist_name}, "'=>'", $artist->{name}, "' '", $artist->{joinphrase}, "' \n";
        my $name_id = $artist->{name_id};
        unless ($name_id) {
            print LOG "    * Looking up name_id\n";
            $name_id = $sql2->SelectSingleValue("
                SELECT id FROM artist_name WHERE name = ?",
                $artist->{name});
            unless ($name_id) {
                print LOG "    * Missing name_id\n";
                $name_id = $sql2->SelectSingleValue("
                    INSERT INTO artist_name (name) VALUES (?)
                    RETURNING id", $artist->{name});
            }
        }
        $sql2->Do("INSERT INTO artist_credit_name (artist_credit, position,
                   artist, name, joinphrase) VALUES (?, ?, ?, ?, ?)",
                   $ac_id, $artist->{position}, $artist->{artist},
                   $name_id, $artist->{joinphrase} || undef);
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

$sql2->Do("DROP INDEX tmp_artist_name_name");

    $sql->Commit;
};
if ($@) {
    printf STDERR "ERROR: %s\n", $@;
    $sql->Rollback;
}
