#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use Sql;

my $c = MusicBrainz::Server::Context->new();

my $sql = Sql->new($c->dbh);
my $sql2 = Sql->new($c->dbh);
my $raw_sql = Sql->new($c->raw_dbh);

my %targets;
my %targets_sec;
my %link_map;
my %link_map_update;
my $link_map_counter = 0;

sub resolve_link_group
{
    my $new_group = $_[0];
    my @update;
    while (exists $link_map_update{$new_group}) {
        push @update, $new_group;
        $new_group = $link_map_update{$new_group};
    }
    foreach (@update) { $link_map_update{$_} = $new_group }
    return $new_group;
}

sub add_merge
{
    my @ids = @_;

    #printf STDERR "Adding %s\n", join(',',@ids);

    my @groups =
        uniq sort { $a <=> $b }        # sort by group no.
        map { resolve_link_group($_) } # apply updates
        uniq grep { $_ }               # filter out empty ones
        map { $link_map{$_} } @ids;    # select groups for IDs

    #printf STDERR " - Found groups %s\n", join(',', @groups);

    my $group;
    if (scalar(@groups) == 1) {
        # found an existing group, add new IDs to the same group
        $group = $groups[0];
    }
    elsif (scalar(@groups) > 1) {
        # found multiple existing groups, merge them
        $group = pop @groups;
        foreach (@groups) { $link_map_update{$_} = $group }
    }
    else {
        # make a new group
        $group = ++$link_map_counter;
    }

    #printf STDERR " - Using group %d\n", $group;

    foreach (@ids) { $link_map{$_} = $group }
}

sub group_works_by_artist
{
    my @result;
    foreach my $works (@_) {
        my %groups;
        foreach my $work (@$works) {
            my $artist = $work->{artist};
            unless (exists $groups{$artist}) {
                $groups{$artist} = [];
            }
            push @{$groups{$artist}}, $work;
        }
        push @result, values %groups;
    }
    return @result;
}

sub group_works_by_name
{
    my @result;
    foreach my $works (@_) {
        my %groups;
        foreach my $work (@$works) {
            my $name = lc $work->{name};
			#XXX: move the first regex to the end?
            $name =~ s/[ .()-:]+//g;
            $name =~ s/\s+\(feat\. .*?\)//g;
			$name =~ s/\s+\(live\)//g;
            unless (exists $groups{$name}) {
                $groups{$name} = [];
            }
            push @{$groups{$name}}, $work;
        }
        push @result, values %groups;
    }
    return @result;
}

sub process_works
{
    my ($works) = @_;

    #foreach my $work (@$works) {
    #    printf STDERR "   - ID=%d, name='%s', artist='%s'\n", $work->{id}, $work->{name}, $work->{artist};
    #}
    my @groups = $works;
    @groups = group_works_by_artist(@groups);
    @groups = group_works_by_name(@groups);
    #printf STDERR " - Merging:\n";
    foreach my $group (@groups) {
        next if @$group < 2;

        my @works = sort { $a->{id} <=> $b->{id} } @$group;
        # Pick work with the lowest ID
        my $new_id = $works[0]->{id};
        add_merge(map { $_->{id} } @works);
        $targets_sec{$new_id} = 1;
        #printf STDERR "\n";
    }
    #printf STDERR "-------------------------------\n";
}

Sql::run_in_transaction(sub {

    open LOG, ">upgrade-merge-works.log";

	# Use remastered recordings
    printf STDERR "Processing remastered and karaoke recordings\n";
	
    $sql->select("
        SELECT link0, link1
        FROM public.l_track_track l
            JOIN public.track r0 ON r0.id = l.link0
            JOIN public.track r1 ON r1.id = l.link1
        WHERE l.link_type in (3, 16) 
            AND r0.artist = r1.artist
        ");
    while (1) {
        my $link = $sql->next_row_ref or last;
        add_merge($link->[0], $link->[1]);
        $targets{$link->[0]} = 1;
        printf LOG "Same work: $link->[0] => $link->[1]\n";
    }
    $sql->finish;

	# Use recordings linked to multiple works with the default AR
    printf STDERR "Processing recordings linked to multiple works\n";

    $sql->select("
        SELECT lrw.entity0 AS recording, w.id, n.name, w.artist_credit as artist
        FROM l_recording_work lrw
			JOIN link l ON l.id = lrw.link
			JOIN link_type lt ON lt.id = l.link_type
            JOIN work w ON w.id=lrw.entity1
            JOIN work_name n ON n.id = w.name
            JOIN (
                SELECT entity0 FROM l_recording_work
                GROUP BY entity0 HAVING count(*)>1
            ) r ON r.entity0=lrw.entity0
		WHERE lt.name = 'performance'
        ORDER BY r.entity0, w.id
    ");
    my $i = 1;
    my @works;
    my $last_recording = 0;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        if ($row->{recording} != $last_recording) {
            process_works([ @works ]) if @works;
            $last_recording = $row->{recording};
            undef @works;
            #printf STDERR "%d/%d\r", $i, $sql->row_count;
        }
        push @works, $row;
        $i += 1;
    }
    process_works([ @works ]) if @works;
    $sql->finish;

	# Use URL: lyrics.wikia, score, ...
    printf STDERR "Processing work URLs (lyrics, score, ...)\n";

    $sql->select("
        SELECT lrw.entity0 AS url, w.id, n.name, w.artist_credit as artist
        FROM l_url_work lrw
			JOIN link l ON l.id = lrw.link
			JOIN link_type lt ON lt.id = l.link_type
            JOIN work w ON w.id=lrw.entity1
            JOIN work_name n ON n.id = w.name
            JOIN (
                SELECT entity0 FROM l_url_work
                GROUP BY entity0 HAVING count(*)>1
            ) u ON u.entity0=lrw.entity0
		WHERE lt.name in ('score', 'lyrics', 'ibdb', 'iobdb')
        ORDER BY u.entity0, w.id
    ");
    $i = 1;
    my $last_url = 0;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        if ($row->{url} != $last_url) {
            process_works([ @works ]) if @works;
            $last_url = $row->{url};
            undef @works;
            #printf STDERR "%d/%d\r", $i, $sql->row_count;
        }
        push @works, $row;
        $i += 1;
    }
    process_works([ @works ]) if @works;
    $sql->finish;
	
    # Generate a "new_id -> [ old_id ]" map from "old_id -> new_id"

    my %merge_map;
    foreach my $id (keys %link_map) {
        my $group = resolve_link_group($link_map{$id});
        unless (exists $merge_map{$group}) {
            $merge_map{$group} = [$id];
        }
        else {
            push @{$merge_map{$group}}, $id;
        }
    }

    undef %link_map;
    undef %link_map_update;

    $sql->do("CREATE TABLE tmp_work_merge (
        old_work INTEGER NOT NULL,
        new_work INTEGER NOT NULL
    )");

    $raw_sql->do("CREATE TEMPORARY TABLE tmp_work_merge (
        old_work INTEGER NOT NULL,
        new_work INTEGER NOT NULL
    )");

    printf STDERR "Generating merge table\n";
    foreach my $group (keys %merge_map) {

        # Get a list of recording IDs in this group
        my @ids = sort { $a <=> $b } @{$merge_map{$group}};

        # Determine the target recording
        my $new_id;
        foreach my $id (@ids) {
            if (exists $targets{$id}) {
                $new_id = $id;
                last;
            }
        }
        if (!$new_id) {
            foreach my $id (@ids) {
                if (exists $targets_sec{$id}) {
                    $new_id = $id;
                    last;
                }
            }
            if (!$new_id) {
                $new_id = $ids[0];
            }
        }

        # Get a list of IDs to merge
        my @old_ids = grep { $_ != $new_id } @ids;
        unless(@old_ids) {
            printf STDERR "Skipping work $new_id\n";
            next;
        }

        # Add them to the database
        printf LOG "Merging %s to %s\n", join(',', @old_ids), $new_id;
        $sql->do("
            INSERT INTO tmp_work_merge
            VALUES " . join(",", ("(?,?)") x scalar(@old_ids)),
            map { ($_, $new_id) } @old_ids);
        $raw_sql->do("
            INSERT INTO tmp_work_merge
            VALUES " . join(",", ("(?,?)") x scalar(@old_ids)),
            map { ($_, $new_id) } @old_ids);
    }

    undef %merge_map;
    undef %targets;
    undef %targets_sec;

    my @entity_types = qw(artist label recording release release_group url);
    foreach my $type (@entity_types) {
        my $table = "l_${type}_work";
        printf STDERR "Merging $table\n";
        $sql->do("
SELECT
    DISTINCT ON (link, entity0, COALESCE(new_work, entity1))
        id, link, entity0, COALESCE(new_work, entity1) AS entity1, edits_pending
INTO TEMPORARY tmp_$table
FROM $table
    LEFT JOIN tmp_work_merge rm ON $table.entity1=rm.old_work;

TRUNCATE $table;
INSERT INTO $table SELECT id, link, entity0, entity1, edits_pending FROM tmp_$table;
DROP TABLE tmp_$table;
");
    }

    printf STDERR "Merging l_work_work\n";
    $sql->do("
SELECT
    DISTINCT ON (link, COALESCE(rm0.new_work, entity0), COALESCE(rm1.new_work, entity1)) id, link, COALESCE(rm0.new_work, entity0) AS entity0, COALESCE(rm1.new_work, entity1) AS entity1, edits_pending
INTO TEMPORARY tmp_l_work_work
FROM l_work_work
    LEFT JOIN tmp_work_merge rm0 ON l_work_work.entity0=rm0.old_work
    LEFT JOIN tmp_work_merge rm1 ON l_work_work.entity1=rm1.old_work
WHERE COALESCE(rm0.new_work, entity0) != COALESCE(rm1.new_work, entity1);

TRUNCATE l_work_work;
INSERT INTO l_work_work SELECT * FROM tmp_l_work_work;
DROP TABLE tmp_l_work_work;
");

    printf STDERR "Merging work_annotation\n";
    $sql->do("
SELECT
    COALESCE(new_work, work), annotation
INTO TEMPORARY tmp_work_annotation
FROM work_annotation
    LEFT JOIN tmp_work_merge rm ON work_annotation.work=rm.old_work;

TRUNCATE work_annotation;
INSERT INTO work_annotation SELECT * FROM tmp_work_annotation;
DROP TABLE tmp_work_annotation;
");

    printf STDERR "Merging work_gid_redirect\n";
    $sql->do("
SELECT
    gid, COALESCE(new_work, new_id)
INTO TEMPORARY tmp_work_gid_redirect
FROM work_gid_redirect
    LEFT JOIN tmp_work_merge rm ON work_gid_redirect.new_id=rm.old_work;

TRUNCATE work_gid_redirect;
INSERT INTO work_gid_redirect SELECT * FROM tmp_work_gid_redirect;
DROP TABLE tmp_work_gid_redirect;

INSERT INTO work_gid_redirect
    SELECT gid, new_work
    FROM work
        JOIN tmp_work_merge rm ON work.id=rm.old_work;
");

    printf STDERR "Merging work\n";
    $sql->do("
SELECT work.*
INTO TEMPORARY tmp_work
FROM work
    LEFT JOIN tmp_work_merge rm ON work.id=rm.old_work
WHERE old_work IS NULL;

TRUNCATE work;
INSERT INTO work SELECT * FROM tmp_work;
DROP TABLE tmp_work;
");

    printf STDERR "Merging work_meta\n";
    $sql->do("TRUNCATE work_meta");
    $sql->do("INSERT INTO work_meta (id) SELECT id FROM work");
    $raw_sql->select("
        SELECT work, avg(rating)::INT, count(*)
        FROM work_rating_raw
        GROUP BY work");
    $sql->do("CREATE UNIQUE INDEX tmp_work_meta_idx ON work_meta (id)");
    while (1) {
        my $row = $raw_sql->next_row_ref or last;
        my ($id, $rating, $count) = @$row;
        $sql->do("UPDATE work_meta SET rating=?, rating_count=? WHERE id=?", $rating, $count, $id);
    }
    $raw_sql->finish;
    $sql->do("DROP INDEX tmp_work_meta_idx");

    printf STDERR "Unlinking work artist credits\n";
    $sql->do('UPDATE work SET artist_credit = NULL');
}, $sql, $raw_sql);
