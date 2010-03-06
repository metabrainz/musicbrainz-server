#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::Context;
use Sql;
open LOG, ">release-merge.log";
open ERRLOG, ">release-merge-errors.log";

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->dbh);

$sql->begin;
eval {

	my $link_type = $sql->select_single_value("
		SELECT id FROM link_type WHERE
			entitytype0='release' AND
			entitytype1='release' AND
			name='part of set'");

	# Load all part-of-set ARs into a graph represented as id=>[id,id,id,..]
	print "Loading 'part of set' ARs\n";
	my %link_map;
	my %reverse_link_map;
	$sql->select("
		SELECT entity0, entity1
		FROM l_release_release
		WHERE link IN (SELECT id FROM link WHERE link_type=?)
		ORDER BY entity0, entity1", $link_type);
	while (1) {
		my $row = $sql->next_row_hash_ref or last;
		my $entity0 = $row->{entity0};
		my $entity1 = $row->{entity1};

		if (exists $link_map{$entity0}) {
			push @{$link_map{$entity0}}, $entity1;
		}
		else {
			$link_map{$entity0} = [ $entity1 ];
		}

		if (exists $reverse_link_map{$entity1}) {
			push @{$reverse_link_map{$entity1}}, $entity0;
		}
		else {
			$reverse_link_map{$entity1} = [ $entity0 ];
		}
	}
	$sql->finish;

	# Find all nodes in the graph that are not children of any other node
	# (these represent first discs of multi-disc releases)
	my %heads = map { $_ => 1 } keys %link_map;
	delete @heads{keys %reverse_link_map};
	my @heads = keys %heads;
	undef %heads;

	sub find_all_discs
	{
		my ($id) = @_;

		my %seen;
		my @discs = ($id);
		while (exists $link_map{$id}) {
			my @children = @{$link_map{$id}};
			# Stop if there is a cycle in the graph
			return () if exists $seen{$id};
			# Stop if it links to more than one release, we can't merge them
			# (ngs-ars.pl tries to avoid such situations if possible)
			return () if scalar(@children) > 1;
			# Move on the next disc
			$seen{$id} = 1;
			$id = $children[0];
			# Stop if more than one release link to the next disc, we can't merge them
			# (ngs-ars.pl tries to avoid such situations if possible)
			if (exists $reverse_link_map{$id}) {
				my @parents = @{$reverse_link_map{$id}};
				return () if scalar(@parents) > 1;
			}
			push @discs, $id;
		}

		die 'Something is wrong' if scalar @discs < 2;

		return @discs;
	}
	
	sub score_rinfo_similarity
	{
		my ($release1, $release2) = @_;
		
		my $m_sum = 0;
		my $m_cnt = 0;
		my @infos = qw(date_year date_month date_day barcode country label);
		foreach my $info (@infos) {
			$m_cnt += 1
				if (defined $release1->{$info} || defined $release2->{$info});
			$m_sum += 1
				if (defined $release1->{$info} && defined $release2->{$info} &&
					$release1->{$info} eq $release2->{$info});
		}
		my $score = $m_cnt > 0 ? 1.0 * $m_sum / $m_cnt : 1;
		if ($score < 1) {
			foreach my $info (@infos) {
				printf ERRLOG "  %s: %s vs %s\n", $info, $release1->{$info}, $release2->{$info} if (defined $release1->{$info} && defined $release2->{$info});
			}
			printf ERRLOG " Score: %s\n", $score;
		}
		return $score;
	}

	$sql->do("
		CREATE TEMPORARY TABLE tmp_release_merge (
			old_rel INTEGER NOT NULL,
			new_rel INTEGER NOT NULL
		);
		CREATE INDEX tmp_medium_idx_release ON medium (release);
		CREATE INDEX tmp_release_label_idx_release ON release_label (release);
		CREATE INDEX tmp_release_idx_id ON release (id);
		CREATE INDEX tmp_release_name_idx_id ON release_name (id);
	");

	my $j = 1;
	my $success = 0;
	foreach my $id (@heads) {
		my @discs = find_all_discs($id);
		if (@discs) {
			printf STDERR " %d/%d\r", $j, scalar(@heads);
			printf LOG "Merging %d/%d = %s\n", $j, scalar(@heads), join(',', @discs);
			my $releases = $sql->select_list_of_hashes("
				SELECT release.id, release_name.name, barcode, date_year, date_month, date_day, country, release_label.label, release.artist_credit
				FROM release 
					JOIN release_name ON release.name = release_name.id
					LEFT JOIN release_label ON release.id = release_label.release
				WHERE release.id IN (".join(',', @discs).")");
			my %releases = map { $_->{id} => $_ } @$releases;
			
			my @mediums;
			my $last_discno = 0;
			my %seen_position;
			my ($ref_name, $ref_artist);
			foreach my $id (@discs) {
				my $name = $releases{$id}->{name};
				my $origname = $name;
				my $discno = $last_discno + 1;
				my $disctitle = '';
				if ($name =~ /^(.*?)\s+\((?:bonus disc|disc (\d+))(?::\s+(.*?))?\)$/) {
					$name = $1;
					$discno = $2 if $2;
					$disctitle = $3 if $3;
				}
				if ($id eq $discs[0]) {
					$ref_name = $name;
					$ref_artist = $releases{$id}->{artist_credit};
				}

				# Stop if we have 2 mediums at the same position
				if (exists $seen_position{$discno}) {
					printf ERRLOG "Duplicate position for release: %s - %s\n\n", $id, $origname;
					@discs = ();
					last;
				}
				$seen_position{$discno} = 1;
				
				# Check that all discs have the same name, artist and release info (excepted cat# and format),
				# otherwise skip this discs group
				unless ($id eq $discs[0]) { 
					if (lc($ref_name) ne lc($name) || $releases{$id}->{artist_credit} ne $ref_artist
						|| score_rinfo_similarity($releases{$discs[0]}, $releases{$id}) < 1.0) {
						printf ERRLOG "Non matching discs group skipped: %s - %s | %s\n\n", join(',', @discs), $ref_name, $name;
						@discs = ();
						last;
					}
				}
						
				printf LOG " * %s => %s | %s | %s\n", $origname, $name, $discno, $disctitle;
				push @mediums, { position => $discno, title => $disctitle };
				$last_discno = $discno;
			}

			# Check if the current discs group is still eligible for merge 
			next if scalar(@discs) < 2;
			
			# Update mediums
			my $i = 0;
			foreach my $id (@discs) {
				my $medium = $mediums[$i++];
				printf LOG "Updating position to %d\n", $medium->{position};
				$sql->do("UPDATE medium SET release=?, position=?, name=? WHERE release=?",
						 $discs[0], $medium->{position}, $medium->{title} || undef, $id);
			}
			
			# Build the temporary merge mapping table
			my $new_id = $discs[0];
			shift @discs;
			$sql->do("
				INSERT INTO tmp_release_merge
				VALUES " . join(",", ("(?,?)") x scalar(@discs)),
				map { ($_, $new_id) } @discs);
			$success++;
		}
		$j += 1;
	}
	printf STDERR "Skipped: %s/%s\n", (scalar(@heads)-$success), scalar(@heads);
	$sql->do("
		DROP INDEX tmp_medium_idx_release;
		DROP INDEX tmp_release_label_idx_release;
		DROP INDEX tmp_release_idx_id;
		DROP INDEX tmp_release_name_idx_id;
	");
	undef %link_map;
	undef %reverse_link_map;
	undef @heads;

	my @entity_types = qw(artist label recording release_group url);
	foreach my $type (@entity_types) {
		my ($entity0, $entity1, $table);
		if ($type lt "release") {
			$entity0 = "entity0";
			$entity1 = "entity1";
			$table = "l_${type}_release";
		}
		else {
			$entity0 = "entity1";
			$entity1 = "entity0";
			$table = "l_release_${type}";
		}
		printf STDERR "Merging $table\n";
		$sql->do("
		SELECT
		    DISTINCT ON (link, $entity0, COALESCE(new_rel, $entity1))
		        id, link, $entity0, COALESCE(new_rel, $entity1) AS $entity1, editpending
		INTO TEMPORARY tmp_$table
		FROM $table
		    LEFT JOIN tmp_release_merge rm ON $table.$entity1=rm.old_rel;

		TRUNCATE $table;
		INSERT INTO $table SELECT id, link, entity0, entity1, editpending FROM tmp_$table;
		DROP TABLE tmp_$table;
		");
	}

	printf STDERR "Merging l_release_release\n";
	$sql->do("
	SELECT
		DISTINCT ON (link, COALESCE(rm0.new_rel, entity0), COALESCE(rm1.new_rel, entity1)) id, link, COALESCE(rm0.new_rel, entity0) AS entity0, COALESCE(rm1.new_rel, entity1) AS entity1, editpending
	INTO TEMPORARY tmp_l_release_release
	FROM l_release_release
		LEFT JOIN tmp_release_merge rm0 ON l_release_release.entity0=rm0.old_rel
		LEFT JOIN tmp_release_merge rm1 ON l_release_release.entity1=rm1.old_rel
	WHERE COALESCE(rm0.new_rel, entity0) != COALESCE(rm1.new_rel, entity1);

	TRUNCATE l_release_release;
	INSERT INTO l_release_release SELECT * FROM tmp_l_release_release;
	DROP TABLE tmp_l_release_release;
	");
	
	printf STDERR "Merging release_annotation\n";
	$sql->do("
	SELECT
		COALESCE(new_rel, release), annotation
	INTO TEMPORARY tmp_release_annotation
	FROM release_annotation
		LEFT JOIN tmp_release_merge rm ON release_annotation.release=rm.old_rel;

	TRUNCATE release_annotation;
	INSERT INTO release_annotation SELECT * FROM tmp_release_annotation;
	DROP TABLE tmp_release_annotation;
	");
	
	printf STDERR "Merging release_gid_redirect\n";
	$sql->do("
	SELECT
		gid, COALESCE(new_rel, newid)
	INTO TEMPORARY tmp_release_gid_redirect
	FROM release_gid_redirect
		LEFT JOIN tmp_release_merge rm ON release_gid_redirect.newid=rm.old_rel;

	TRUNCATE release_gid_redirect;
	INSERT INTO release_gid_redirect SELECT * FROM tmp_release_gid_redirect;
	DROP TABLE tmp_release_gid_redirect;

	INSERT INTO release_gid_redirect
		SELECT gid, new_rel
		FROM release
			JOIN tmp_release_merge rm ON release.id=rm.old_rel;
	");

	printf STDERR "Merging editor_collection_release\n";
	$sql->do("
	SELECT
		DISTINCT collection, COALESCE(new_rel, release)
	INTO TEMPORARY tmp_editor_collection_release
	FROM editor_collection_release
		LEFT JOIN tmp_release_merge rm ON editor_collection_release.release=rm.old_rel;

	TRUNCATE editor_collection_release;
	INSERT INTO editor_collection_release SELECT * FROM tmp_editor_collection_release;
	DROP TABLE tmp_editor_collection_release;
	");
	
	printf STDERR "Merging release_label\n";
	$sql->do("
	SELECT
		DISTINCT ON (COALESCE(new_rel, release), label, catno) id, COALESCE(new_rel, release), label, catno
	INTO TEMPORARY tmp_release_label
	FROM release_label
		LEFT JOIN tmp_release_merge rm ON release_label.release=rm.old_rel;

	TRUNCATE release_label;
	INSERT INTO release_label SELECT * FROM tmp_release_label;
	DROP TABLE tmp_release_label;
	");
	
	printf STDERR "Merging release_meta\n";
	$sql->do("
	SELECT COALESCE(new_rel, id) AS id, 
		CASE
			WHEN count(*) > 1 THEN now()
			ELSE max(lastupdate)
		END AS lastupdate,
		min(dateadded) AS dateadded
	INTO TEMPORARY tmp_release_meta
	FROM release_meta
		LEFT JOIN tmp_release_merge rm ON release_meta.id=rm.old_rel
	GROUP BY COALESCE(new_rel, id);

	TRUNCATE release_meta;
	INSERT INTO release_meta (id, lastupdate, dateadded) SELECT id, lastupdate, dateadded FROM tmp_release_meta;
	DROP TABLE tmp_release_meta;
	");
	
	printf STDERR "Merging release\n";
	# Only remove disc information in release name for releases we are merging
	$sql->do("
	CREATE INDEX tmp_release_name_idx_name ON release_name (name);
	SELECT release.id, gid,
		CASE 
			WHEN rm1.new_rel IS NOT NULL THEN regexp_replace(n.name, E'\\\\s+[(](disc [0-9]+(: .*?)?|bonus disc(: .*?)?)[)]\$', '')
			ELSE n.name
		END,
		artist_credit, release_group, status, packaging, country, language, script,
		date_year, date_month, date_day, barcode, comment, editpending, quality
	INTO TEMPORARY tmp_release
	FROM release
		INNER JOIN release_name n ON release.name=n.id
		LEFT JOIN tmp_release_merge rm0 ON release.id=rm0.old_rel
		LEFT JOIN (select distinct new_rel from tmp_release_merge) rm1 ON release.id=rm1.new_rel
	WHERE rm0.old_rel IS NULL;

	INSERT INTO release_name (name)
		SELECT DISTINCT t.name
		FROM tmp_release t
			LEFT JOIN release_name n ON t.name=n.name
		WHERE n.id IS NULL;

	TRUNCATE release;
	INSERT INTO release
		SELECT t.id, gid, n.id, artist_credit, release_group, status, packaging, country, language, script,
			date_year, date_month, date_day, barcode, comment, editpending, quality
		 FROM tmp_release t
			JOIN release_name n ON t.name = n.name;
	DROP TABLE tmp_release;
	DROP INDEX tmp_release_name_idx_name;
	");

	printf STDERR "Updating release_group_meta\n";
	$sql->do("
	SELECT id, lastupdate, COALESCE(t.releasecount, 0), firstreleasedate_year, firstreleasedate_month, firstreleasedate_day, rating, ratingcount
		INTO TEMPORARY tmp_release_group_meta
		FROM release_group_meta rgm 
			LEFT JOIN ( SELECT release_group, count(*) AS releasecount FROM release GROUP BY release_group ) t ON t.release_group = rgm.id;

	TRUNCATE release_group_meta;
	INSERT INTO release_group_meta SELECT * FROM tmp_release_group_meta;
	");

	# XXX:Remove or merge orphaned release-groups

	$sql->commit;
};
if ($@) {
	printf STDERR "ERROR: %s\n", $@;
	$sql->rollback;
}
