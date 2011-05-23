#!/usr/bin/env perl

use warnings;

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

my %album_type;
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

sub group_tracks_by_album_type
{
    my @result;
    foreach my $tracks (@_) {
        my %groups;
        foreach my $track (@$tracks) {
            my $type = ($album_type{$track->{album}} || 0) & 255;
            if ($type < 9 || $type > 10) { # not Live or Remix
                $type = 1;
            }
            unless (exists $groups{$type}) {
                $groups{$type} = [];
            }
            push @{$groups{$type}}, $track;
        }
        push @result, values %groups;
    }
    return @result;
}

sub group_tracks_by_artist
{
    my @result;
    foreach my $tracks (@_) {
        my %groups;
        foreach my $track (@$tracks) {
            my $artist = $track->{artist};
            unless (exists $groups{$artist}) {
                $groups{$artist} = [];
            }
            push @{$groups{$artist}}, $track;
        }
        push @result, values %groups;
    }
    return @result;
}

sub group_tracks_by_name
{
    my @result;
    foreach my $tracks (@_) {
        my %groups;
        foreach my $track (@$tracks) {
            my $name = lc $track->{name};
            $name =~ s/\s+\(feat\. .*?\)//g;
            $name =~ s/[ .()-:!?'"]+//g;
            unless (exists $groups{$name}) {
                $groups{$name} = [];
            }
            push @{$groups{$name}}, $track;
        }
        push @result, values %groups;
    }
    return @result;
}

sub group_tracks_by_length
{
    my @result;
    foreach my $tracks (@_) {
        my @tracks = sort { $a->{length} <=> $b->{length} } @$tracks;
        my @group;
        my $first_length = $tracks[0]->{length};
        my $i = 0;
        foreach my $track (@tracks) {
            if ($tracks[$i]->{length} - $first_length > 3000) {
                if (@group > 1) {
                    push @result, [ @group ];
                }
                @group = ();
                $first_length = $tracks[$i]->{length};
            }
            push @group, $track;
            $i += 1;
        }
        if (@group > 1) {
            push @result, [ @group ];
        }
    }
    return @result;
}

sub process_tracks
{
    my ($tracks) = @_;

    #printf STDERR " - All tracks %d:\n", $tracks->[0]->{puid};
    #foreach my $track (@$tracks) {
    #    printf STDERR "   - ID=%d, name='%s', artist='%s', length=%d\n", $track->{id}, $track->{name}, $track->{artist}, $track->{length};
    #}

	# Never merge tracks from Live/Bootleg albums
	$tracks = [ grep { $album_type{$_->{album}} != ((102 << 8) | 9) } @$tracks ];

    my @groups = $tracks;
    @groups = group_tracks_by_album_type(@groups);
    @groups = group_tracks_by_artist(@groups);
    @groups = group_tracks_by_name(@groups);
    @groups = group_tracks_by_length(@groups);
    #printf STDERR " - Merging:\n";
    foreach my $group (@groups) {
        next if @$group < 2;
        my $new_id;
        my @tracks = sort { $a->{id} <=> $b->{id} } @$group;

		# If there are two tracks from the same album, skip the group
		my %albums;
		my $duplicate_album = 0;
        foreach my $track (@tracks) {
			if (exists $albums{$track->{album}}) {
				$duplicate_album = 1;
				last;
			}
			$albums{$track->{album}} = 1;
		}
		next if $duplicate_album;

        # Try to find an official album
        foreach my $track (@tracks) {
            if ($track->{album} && $album_type{$track->{album}} && $album_type{$track->{album}} == ((100 << 8) | 1)) {
                $new_id = $track->{id};
                last;
            }
        }
        if (!$new_id) {
            # Or at least anything else that is official
            foreach my $track (@tracks) {
                if ($track->{album} && $album_type{$track->{album}} && ($album_type{$track->{album}} >> 8) == 100) {
                    $new_id = $track->{id};
                    last;
                }
            }
        }
        if (!$new_id) {
            # Pick track with the lowest ID
            $new_id = $tracks[0]->{id};
        }
        add_merge(map { $_->{id} } @tracks);
        $targets_sec{$new_id} = 1;
        #printf STDERR "\n";
    }
    #printf STDERR "-------------------------------\n";
}

Sql::run_in_transaction(sub {

    open LOG, ">upgrade-merge-recordings.log";

    # Use 'first track release' track-track ARs
    printf STDERR "Processing 'first track release' ARs\n";

    $sql->select("
        SELECT link0, link1
        FROM public.l_track_track l
            JOIN public.track r0 ON r0.id = l.link0
            JOIN public.track r1 ON r1.id = l.link1
        WHERE l.link_type = 2 AND
            abs(r0.length - r1.length) < 5000 AND
            r0.artist = r1.artist
        ");
    while (1) {
        my $link = $sql->next_row_ref or last;
        add_merge($link->[0], $link->[1]);
        $targets{$link->[0]} = 1;
        #printf LOG "Same track: $old_id => $new_id\n";
    }
    $sql->finish;

    # Use 'transliteration' album-album ARs
    printf STDERR "Processing 'transliteration' ARs\n";

    $sql->select("
        SELECT link0, link1
        FROM public.l_album_album l
            JOIN public.album a0 ON a0.id = l.link0
            JOIN public.albummeta am0 ON am0.id = a0.id
            JOIN public.album a1 ON a1.id = l.link1
            JOIN public.albummeta am1 ON am1.id = a1.id
        WHERE l.link_type = 15 AND am0.tracks = am1.tracks
        ");
    my $j = 0;
    while (1) {
        my $link = $sql->next_row_ref or last;
        my ($new_album_id, $old_album_id) = @$link;
        printf STDERR "$j\r";
        $j += 1;

        my $tracks = $sql2->select_list_of_lists("
            SELECT t.id, t.length, aj.album
            FROM public.albumjoin aj
                JOIN public.track t ON t.id = aj.track
            WHERE aj.album IN (?, ?) ORDER BY aj.sequence
            ", $old_album_id, $new_album_id);

        my @old_tracks;
        my @new_tracks;
        foreach my $track (@$tracks) {
            if ($track->[2] == $new_album_id) {
                push @new_tracks, $track;
            }
            else {
                push @old_tracks, $track;
            }
        }

        my $i = 0;
        while (1) {
            my $new_track = $new_tracks[$i] or last;
            my $old_track = $old_tracks[$i] or last;
            if (abs($new_track->[1] - $old_track->[1]) < 3000) {
                add_merge($new_track->[0], $old_track->[0]);
                $targets{$new_track->[0]} = 1;
                #printf LOG "Transl*tion: $old_id => $new_id\n";
            }
            $i += 1;
        }

    }
    $sql->finish;

    # Use PUIDs
    printf STDERR "Processing PUIDs\n";

    printf STDERR " - Loading album types\n";
    $sql->select("SELECT id, attributes FROM public.album");;
    while (1) {
        my $row = $sql->next_row_ref or last;
        my ($id, $attributes) = @$row;
        my $type = 0;
        my $status = 0;
        foreach my $i (1..2) {
            if ($attributes->[$i] && $attributes->[$i] < 100) {
                $type = $attributes->[$i];
            }
            elsif ($attributes->[$i]) {
                $status = $attributes->[$i];
            }
        }
        $album_type{$id} = ($status << 8) | $type;
    }
    $raw_sql->finish;

    printf STDERR " - Loading PUIDs with multiple tracks\n";
    $sql->select("
        SELECT p.puid, t.id, unaccent(t.name) as name, t.artist, t.length, a.album
        FROM public.track t
            JOIN public.albumjoin a ON a.track=t.id
            JOIN public.puidjoin ON t.id=puidjoin.track
            JOIN (
                SELECT puid FROM public.puidjoin
                GROUP BY puid HAVING count(*)>1
            ) p ON p.puid=puidjoin.puid
        ORDER BY p.puid, t.id
    ");
    my $i = 1;
    my @tracks;
    my $last_puid = 0;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        if ($row->{puid} != $last_puid) {
            process_tracks([ @tracks ]) if @tracks;
            $last_puid = $row->{puid};
            undef @tracks;
            printf STDERR "%d/%d\r", $i, $sql->row_count;
        }
        push @tracks, $row;
        $i += 1;
    }
    process_tracks([ @tracks ]) if @tracks;
    $sql->finish;

    printf STDERR "Processing ISRCs with multiple tracks\n";
    $sql->select("
        SELECT p.isrc, t.id, unaccent(t.name) as name, t.artist, t.length, a.album
        FROM public.track t
            JOIN public.albumjoin a ON a.track=t.id
            JOIN public.isrc i ON i.track=t.id
            JOIN (
                SELECT isrc FROM public.isrc
                GROUP BY isrc HAVING count(*)>1
            ) p ON p.isrc=i.isrc
        ORDER BY p.isrc, t.id
    ");
    $i = 1;
    my $last_isrc = '';
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        if ($row->{isrc} ne $last_isrc) {
            process_tracks([ @tracks ]) if @tracks;
            $last_isrc = $row->{isrc};
            undef @tracks;
            printf STDERR "%d/%d\r", $i, $sql->row_count;
        }
        push @tracks, $row;
        $i += 1;
    }
    process_tracks([ @tracks ]) if @tracks;
    $sql->finish;

    undef @tracks;
    undef %album_type;

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

	printf STDERR "Breaking up track groups with different ISRCs\n";

	# Generate a track_id -> [ pseudo_isrc_id ] map

	my %isrc_map;
	$i = 1;
	$last_isrc = '';
	my $isrc_group = 1;
	$sql->select("SELECT isrc, track AS id FROM public.isrc ORDER BY isrc");
	while (1) {
		my $row = $sql->next_row_hash_ref or last;
		if ($row->{isrc} ne $last_isrc) {
			$isrc_group++;
			$last_isrc = $row->{isrc};
			printf STDERR "%d/%d\r", $i, $sql->row_count;
		}
		if (exists $isrc_map{$row->{id}}) {
			push @{$isrc_map{$row->{id}}}, $isrc_group;
		}
		else {
			$isrc_map{$row->{id}} = [$isrc_group];
		}
		$i += 1;
	}
	$sql->finish;

	foreach my $group (keys %merge_map) {
		my @ids = @{$merge_map{$group}};
		my %counts;
		my %contains;
		foreach my $id (@ids) {
			if (exists $isrc_map{$id}) {
				foreach my $isrc_id (@{$isrc_map{$id}}) {
					$counts{$isrc_id}++;
				}
				$contains{$id} = { map { $_ => 1 } @{$isrc_map{$id}} };
			}
		}
		my @isrc_ids = sort { $counts{$a} <=> $counts{$b} } keys %counts;
		my $isrc_id = pop @isrc_ids;
		next unless defined $isrc_id;
		$merge_map{$group} = [ grep { !exists $contains{$_} || $contains{$_}->{$isrc_id} } @ids ];
		if (@{$merge_map{$group}} != @ids) {
			printf LOG "Multiple different ISRCs in a group " . join(', ', @ids) . "\n";
		}
		if (@{$merge_map{$group}} < 2) {
			delete $merge_map{$group};
		}
	}

	undef %isrc_map;

	$sql->do("CREATE TABLE tmp_recording_merge (
        old_rec INTEGER NOT NULL,
        new_rec INTEGER NOT NULL
    )");

    $raw_sql->do("CREATE TABLE tmp_recording_merge (
        old_rec INTEGER NOT NULL,
        new_rec INTEGER NOT NULL
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

        # Add them to the database
        printf LOG "Merging %s to %s\n", join(',', @old_ids), $new_id;
        $sql->do("
            INSERT INTO tmp_recording_merge
            VALUES " . join(",", ("(?,?)") x scalar(@old_ids)),
            map { ($_, $new_id) } @old_ids);
        $raw_sql->do("
            INSERT INTO tmp_recording_merge
            VALUES " . join(",", ("(?,?)") x scalar(@old_ids)),
            map { ($_, $new_id) } @old_ids);
    }

    undef %merge_map;
    undef %targets;
    undef %targets_sec;

    printf STDERR "Merging isrc\n";
    $sql->do("
SELECT
    DISTINCT ON (COALESCE(new_rec, recording), isrc) id, COALESCE(new_rec, recording), isrc, source, edits_pending
INTO TEMPORARY tmp_isrc
FROM isrc
    LEFT JOIN tmp_recording_merge rm ON isrc.recording=rm.old_rec;

TRUNCATE isrc;
INSERT INTO isrc SELECT * FROM tmp_isrc;
DROP TABLE tmp_isrc;
");

    my @entity_types = qw(artist label release release_group url work);
    foreach my $type (@entity_types) {
        my ($entity0, $entity1, $table);
        if ($type lt "recording") {
            $entity0 = "entity0";
            $entity1 = "entity1";
            $table = "l_${type}_recording";
        }
        else {
            $entity0 = "entity1";
            $entity1 = "entity0";
            $table = "l_recording_${type}";
        }
        printf STDERR "Merging $table\n";
        $sql->do("
SELECT
    DISTINCT ON (link, $entity0, COALESCE(new_rec, $entity1))
        id, link, $entity0, COALESCE(new_rec, $entity1) AS $entity1, edits_pending
INTO TEMPORARY tmp_$table
FROM $table
    LEFT JOIN tmp_recording_merge rm ON $table.$entity1=rm.old_rec;

TRUNCATE $table;
INSERT INTO $table SELECT id, link, entity0, entity1, edits_pending FROM tmp_$table;
DROP TABLE tmp_$table;
");
    }

    printf STDERR "Merging l_recording_recording\n";
    $sql->do("
SELECT
    DISTINCT ON (link, COALESCE(rm0.new_rec, entity0), COALESCE(rm1.new_rec, entity1)) id, link, COALESCE(rm0.new_rec, entity0) AS entity0, COALESCE(rm1.new_rec, entity1) AS entity1, edits_pending
INTO TEMPORARY tmp_l_recording_recording
FROM l_recording_recording
    LEFT JOIN tmp_recording_merge rm0 ON l_recording_recording.entity0=rm0.old_rec
    LEFT JOIN tmp_recording_merge rm1 ON l_recording_recording.entity1=rm1.old_rec
WHERE COALESCE(rm0.new_rec, entity0) != COALESCE(rm1.new_rec, entity1);

TRUNCATE l_recording_recording;
INSERT INTO l_recording_recording SELECT * FROM tmp_l_recording_recording;
DROP TABLE tmp_l_recording_recording;
");

    printf STDERR "Merging recording_annotation\n";
    $sql->do("
SELECT
    COALESCE(new_rec, recording), annotation
INTO TEMPORARY tmp_recording_annotation
FROM recording_annotation
    LEFT JOIN tmp_recording_merge rm ON recording_annotation.recording=rm.old_rec;

TRUNCATE recording_annotation;
INSERT INTO recording_annotation SELECT * FROM tmp_recording_annotation;
DROP TABLE tmp_recording_annotation;
");

    printf STDERR "Merging recording_gid_redirect\n";
    $sql->do("
SELECT
    gid, COALESCE(new_rec, new_id)
INTO TEMPORARY tmp_recording_gid_redirect
FROM recording_gid_redirect
    LEFT JOIN tmp_recording_merge rm ON recording_gid_redirect.new_id=rm.old_rec;

TRUNCATE recording_gid_redirect;
INSERT INTO recording_gid_redirect SELECT * FROM tmp_recording_gid_redirect;
DROP TABLE tmp_recording_gid_redirect;

INSERT INTO recording_gid_redirect
    SELECT gid, new_rec
    FROM recording
        JOIN tmp_recording_merge rm ON recording.id=rm.old_rec;
");

    printf STDERR "Merging recording_puid\n";
    $sql->do("
SELECT
    DISTINCT ON (puid, COALESCE(new_rec, recording)) id, puid, COALESCE(new_rec, recording), edits_pending
INTO TEMPORARY tmp_recording_puid
FROM recording_puid
    LEFT JOIN tmp_recording_merge rm ON recording_puid.recording=rm.old_rec;

TRUNCATE recording_puid;
INSERT INTO recording_puid SELECT * FROM tmp_recording_puid;
DROP TABLE tmp_recording_puid;
");

    printf STDERR "Merging recording\n";
    $sql->do("
SELECT recording.*
INTO TEMPORARY tmp_recording
FROM recording
    LEFT JOIN tmp_recording_merge rm ON recording.id=rm.old_rec
WHERE old_rec IS NULL;

TRUNCATE recording;
INSERT INTO recording SELECT * FROM tmp_recording;
DROP TABLE tmp_recording;
");

    printf STDERR "Merging track\n";
    $sql->do("
SELECT
    id, COALESCE(new_rec, recording), tracklist, position, name, artist_credit, length, edits_pending
INTO TEMPORARY tmp_track
FROM track
    LEFT JOIN tmp_recording_merge rm ON track.recording=rm.old_rec;

TRUNCATE track;
INSERT INTO track SELECT * FROM tmp_track;
DROP TABLE tmp_track;
");

    printf STDERR "Merging recording_tag_raw\n";
    $raw_sql->do("
SELECT
    DISTINCT COALESCE(new_rec, recording), editor, tag
INTO TEMPORARY tmp_recording_tag_raw
FROM recording_tag_raw
    LEFT JOIN tmp_recording_merge rm ON recording_tag_raw.recording=rm.old_rec;

TRUNCATE recording_tag_raw;
INSERT INTO recording_tag_raw SELECT * FROM tmp_recording_tag_raw;
DROP TABLE tmp_recording_tag_raw;
");

    printf STDERR "Merging recording_rating_raw\n";
    $raw_sql->do("
SELECT COALESCE(new_rec, recording), editor, avg(rating)
INTO TEMPORARY tmp_recording_rating_raw
FROM recording_rating_raw
    LEFT JOIN tmp_recording_merge rm ON recording_rating_raw.recording=rm.old_rec
GROUP BY COALESCE(new_rec, recording), editor;

TRUNCATE recording_rating_raw;
INSERT INTO recording_rating_raw SELECT * FROM tmp_recording_rating_raw;
DROP TABLE tmp_recording_rating_raw;
");

    printf STDERR "Merging recording_meta\n";
    $sql->do("TRUNCATE recording_meta");
    $sql->do("INSERT INTO recording_meta (id) SELECT id FROM recording");
    $raw_sql->select("
        SELECT recording, avg(rating)::INT, count(*)
        FROM recording_rating_raw
        GROUP BY recording");
    $sql->do("CREATE UNIQUE INDEX tmp_recording_meta_idx ON recording_meta (id)");
    while (1) {
        my $row = $raw_sql->next_row_ref or last;
        my ($id, $rating, $count) = @$row;
        $sql->do("UPDATE recording_meta SET rating=?, rating_count=? WHERE id=?", $rating, $count, $id);
    }
    $raw_sql->finish;
    $sql->do("DROP INDEX tmp_recording_meta_idx");

    printf STDERR "Merging recording_tag\n";
    $sql->do("TRUNCATE recording_tag");
    $raw_sql->select("
        SELECT recording, tag, count(*)
        FROM recording_tag_raw
        GROUP BY recording, tag");
    while (1) {
        my $row = $raw_sql->next_row_ref or last;
        my ($recording, $tag, $count) = @$row;
        $sql->do("INSERT INTO recording_tag (recording, tag, count) VALUES (?, ?, ?)", $recording, $tag, $count);
    }
    $raw_sql->finish;

}, $sql, $raw_sql);
