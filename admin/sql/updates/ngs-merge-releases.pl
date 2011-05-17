#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::Context;
use OSSP::uuid;
use Sql;
open LOG, ">:utf8", "release-merge.log";
open ERRLOG, ">:utf8", "release-merge-errors.log";

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my $UUID_NS_URL = OSSP::uuid->new;
$UUID_NS_URL->load("ns:URL");

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->dbh);

$sql->begin;
$c->raw_sql->begin;
eval {

    my $link_type = $sql->select_single_value("
        SELECT id FROM link_type WHERE
                entity_type0='release' AND
                entity_type1='release' AND
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

    my %medium_position_attributes;
    my %links;
    my $uuid = OSSP::uuid->new;
    $uuid->make("v3", $UUID_NS_URL, "http://musicbrainz.org/link-attribute-type/medium/");

    my $medium_position_root = $sql->select_single_value(
        "SELECT nextval('link_attribute_type_id_seq')"
    );
    $sql->do(
        'INSERT INTO link_attribute_type (id, root, gid, name)
              VALUES (?, ?, ?, ?)',
        $medium_position_root,
        $medium_position_root,
        $uuid->export('str'),
        'medium');
    $sql->do(
        'INSERT INTO link_type_attribute_type (link_type, attribute_type, min)
             SELECT id, ?, ? FROM link_type WHERE gid = ?',
        $medium_position_root, 0, '9162dedd-790c-446c-838e-240f877dbfe2'); # dj-mixed AR

    $sql->do("
        CREATE TABLE tmp_release_merge (
                old_rel INTEGER NOT NULL,
                new_rel INTEGER NOT NULL
        );
        CREATE INDEX tmp_medium_idx_release ON medium (release);
        CREATE INDEX tmp_release_label_idx_release ON release_label (release);
        CREATE INDEX tmp_release_idx_id ON release (id);
        CREATE INDEX tmp_release_name_idx_id ON release_name (id);
        CREATE INDEX tmp_link_type_gid ON link_type (gid);
        CREATE INDEX tmp_l_artist_release ON l_artist_release (entity1);
        CREATE INDEX tmp_link_type_id ON link_type (id);
        CREATE INDEX tmp_link_lt ON link (link_type);
        ANALYZE release;
        ANALYZE release_name;
        ANALYZE release_label;
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

                # Merge medium-level ARs
                my $medium_level_ars = $sql->select_list_of_hashes(
                            "SELECT entity0,entity1,link_type,begin_date_year,
                                    begin_date_month,begin_date_day
                                    end_date_year,end_date_month,end_date_day,
                                    link_type, l.id
                               FROM l_artist_release l
                               JOIN link link ON link.id = l.link
                               JOIN link_type lt ON lt.id = link.link_type
                              WHERE lt.gid = '9162dedd-790c-446c-838e-240f877dbfe2'
                                AND l.entity1 IN (" .
                                    join(',', ('?') x @discs) . ')', @discs);

                # Map a link key (begin/end date) to a link definition:
                # begin/end date fields, a list of attributes, and the artist
                my %release_links;

                # A list of all medium level ARs. Each element contains the ID of
                # the artist end point, and a reference to the link definition
                my @release_ars;

                # Map a release ID to it's medium
                my %release_mediums = map {
                    $discs[$_] => $mediums[$_]
                } ( 0..$#discs );

                for my $medium_ar (@$medium_level_ars) {
                    my $medium = $release_mediums{ $medium_ar->{entity1} };

                    $medium_position_attributes{ $medium->{position} } ||=
                        $sql->select_single_value(
                        'INSERT INTO link_attribute_type (root, parent, gid, name, child_order)
                             VALUES (?, ?, ?, ?, ?) RETURNING id',
                        ($medium_position_root) x 2,
                        do {
                            $uuid->make("v3", $UUID_NS_URL,
                                        "http://musicbrainz.org/link-attribute-type/medium/" .
                                            $medium->{position});
                            $uuid->export('str')
                        },
                        'Medium ' . $medium->{position},
                        $medium->{position}
                    );

                    my $key = join(
                        "_",
                        join('-', map {
                            $medium_ar->{"begin_date_$_"} || 0
                        } qw( year month day )),
                        join('-', map {
                            $medium_ar->{"end_date_$_"} || 0
                        } qw( year month day )),
                        $medium_ar->{entity0}
                    );

                    $release_links{$key} ||= {
                        %$medium_ar,
                        attrs => []
                    };

                    push @{ $release_links{$key}->{attrs} },
                        $medium_position_attributes{ $medium->{position} };

                    push @release_ars, {
                        entity0 => $medium_ar->{entity0},
                        link => $release_links{$key}
                    };

                    $sql->do('DELETE FROM l_artist_release WHERE id = ?',
                             $medium_ar->{id});
                }

                for my $release_link (values %release_links) {
                    my @attrs = @{ $release_link->{attrs} };
                    my $key = join(
                        "_",
                        join('-', map {
                            $release_link->{"begin_date_$_"} || 0
                        } qw( year month day )),
                        join('-', map {
                            $release_link->{"end_date_$_"} || 0
                        } qw( year month day )),
                        @attrs
                    );
                    my $link_id;
                    if (!exists($links{$key})) {
                        $link_id = $sql->select_single_value("SELECT nextval('link_id_seq')");
                        $links{$key} = $link_id;
                        $sql->do(
                            "INSERT INTO link
                                 (id, link_type, begin_date_year, begin_date_month, begin_date_day,
                                  end_date_year, end_date_month, end_date_day, attribute_count)
                                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            $link_id,
                            $release_link->{link_type},
                            (map { $release_link->{"begin_date_$_"} } qw( year month day )),
                            (map { $release_link->{"end_date_$_"} } qw( year month day )),
                            scalar(@attrs));
                        foreach my $attr (@attrs) {
                            $sql->do("INSERT INTO link_attribute (link, attribute_type) VALUES (?, ?)",
                                     $link_id, $attr);
                        }
                    }
                    else {
                        $link_id = $links{$key};
                    }

                    $release_link->{link_id} = $link_id;
                }

                for my $release_ar (@release_ars) {
                    $sql->do('INSERT INTO l_artist_release (entity0,entity1,link) VALUES (?,?,?)',
                             $release_ar->{entity0}, $discs[0], $release_ar->{link}{link_id});
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
        DROP INDEX tmp_link_type_gid;
        DROP INDEX tmp_l_artist_release;
        DROP INDEX tmp_link_type_id;
        DROP INDEX tmp_link_lt;
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
                id, link, $entity0, COALESCE(new_rel, $entity1) AS $entity1, edits_pending
        INTO TEMPORARY tmp_$table
        FROM $table
            LEFT JOIN tmp_release_merge rm ON $table.$entity1=rm.old_rel;

        TRUNCATE $table;
        INSERT INTO $table SELECT id, link, entity0, entity1, edits_pending FROM tmp_$table;
        DROP TABLE tmp_$table;
        ");
    }

    printf STDERR "Merging l_release_release\n";
    $sql->do("
    SELECT
        DISTINCT ON (link, COALESCE(rm0.new_rel, entity0), COALESCE(rm1.new_rel, entity1)) id, link, COALESCE(rm0.new_rel, entity0) AS entity0, COALESCE(rm1.new_rel, entity1) AS entity1, edits_pending
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

    $sql->do(q!
        CREATE FUNCTION annotation_concat (text, text) RETURNS text AS $$
        BEGIN
            RETURN $1 || $2 || E'\n\n';
        END;
        $$ LANGUAGE plpgsql;

        CREATE AGGREGATE annotation_append (text)
        (
            sfunc = annotation_concat,
            stype = text,
            initcond = ''
        );
    !);

    # Give us all annotations with releases joined, save a tiny bit of time
    $sql->do(q{
        SELECT a.*, ra.release
        INTO TEMPORARY tmp_annotation
        FROM annotation a
        JOIN release_annotation ra ON ra.annotation = a.id;
        CREATE INDEX tmp_annotation_idx ON tmp_annotation (id);
    });

    # All annotations that span multiple discs
    $sql->do(q!
        SELECT an.*, ra.release
        INTO TEMPORARY multi_disc_annotations
        FROM annotation an
        JOIN release_annotation ra ON ra.annotation = an.id
        WHERE ra.release IN (
            SELECT old_rel FROM tmp_release_merge
            UNION ALL
            SELECT new_rel FROM tmp_release_merge
        );
    !);

    # Now that we have the annotations we want to work with we remove the existing
    # annotations, which allows us to restart the annotation_id_seq
    $sql->do(q!
        DELETE FROM annotation an USING multi_disc_annotations ta
            WHERE an.id = ta.id;
        DELETE FROM release_annotation ra USING multi_disc_annotations ta
            WHERE ra.release = ta.release;
        SELECT SETVAL('annotation_id_seq', (SELECT MAX(id) FROM annotation))
    !);

    # We will store our work in progress merging into here
    $sql->do(q!
        CREATE TEMPORARY TABLE tmp_merged_annotation (
            id INT,
            release INT,
            editor INT,
            text TEXT,
            changelog TEXT,
            created TIMESTAMP WITH TIME ZONE
        );
    !);

    # Gives us a set of <{array}> rows, where the array is all release ids for all
    # discs in the set
    my @disc_sets = @{ $sql->select_single_column_array(
        'SELECT array_prepend(new_rel, array_accum(old_rel)) AS discs
           FROM tmp_release_merge
          WHERE new_rel IN (SELECT release FROM tmp_annotation)
       GROUP BY new_rel') };

    my $i = 0;
    # Loop over all disc sets and do the merging
    for my $disc_set (@disc_sets) {
        printf STDERR "%d/%d\r", $i++, scalar @disc_sets;

        # FIXME merge in medium order
        $sql->do("
            INSERT INTO tmp_merged_annotation (text, id, changelog, editor, created, release)
            WITH merge_ann AS (
                 SELECT *
                   FROM multi_disc_annotations an
                  WHERE release IN (" . placeholders(@$disc_set) . ")
            )
            SELECT annotation_append(annotations.text) AS text,
                   nextval('annotation_id_seq') AS id, changelog, editor,
                   created, ?::int
              FROM (
                     SELECT DISTINCT ON (created.created, annotation.release)
                            created.id, annotation.text, created.created,
                            created.editor, created.changelog
                       FROM merge_ann annotation, merge_ann created
                      WHERE annotation.created <= created.created
                   ORDER BY created.created, annotation.release, annotation.created DESC
                   ) annotations
            GROUP BY id, created, changelog, editor
            ORDER BY created;
        ", @$disc_set, $disc_set->[0]);
    }

    # FIXME Also seems to insert twice?
    # Insert the new merged annotations for multiple disc sets
    $sql->do("
        INSERT INTO release_annotation (release, annotation)
            SELECT release, id
            FROM tmp_merged_annotation;

        INSERT INTO annotation (id, text, editor, changelog, created)
            SELECT id, text, editor, changelog, created
            FROM tmp_merged_annotation;
    ");

    # Cleanup
    $sql->do("
        DROP AGGREGATE annotation_append (text);
        DROP FUNCTION annotation_concat (text, text);
    ");

    printf STDERR "Merging release_gid_redirect\n";
    $sql->do("
    SELECT
        gid, COALESCE(new_rel, new_id)
    INTO TEMPORARY tmp_release_gid_redirect
    FROM release_gid_redirect
        LEFT JOIN tmp_release_merge rm ON release_gid_redirect.new_id=rm.old_rel;

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
        DISTINCT ON (COALESCE(new_rel, release), label, catalog_number) id, COALESCE(new_rel, release), label, catalog_number
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
        min(date_added) AS date_added
    INTO TEMPORARY tmp_release_meta
    FROM release_meta
        LEFT JOIN tmp_release_merge rm ON release_meta.id=rm.old_rel
    GROUP BY COALESCE(new_rel, id);

    TRUNCATE release_meta;
    TRUNCATE release_coverart;

    INSERT INTO release_coverart (id)
        SELECT id FROM tmp_release_meta;

    INSERT INTO release_meta (id, date_added)
        SELECT id, date_added FROM tmp_release_meta;

    DROP TABLE tmp_release_meta;
    ");

    printf STDERR "Merging release\n";
    # Only remove disc information in release name for releases we are merging
    $sql->do("
    CREATE INDEX tmp_release_name_idx_name ON release_name (name);
    
    SELECT COALESCE(new_rel, id) AS id,
        min(quality) AS quality
    INTO TEMPORARY tmp_release_quality
    FROM release
        LEFT JOIN tmp_release_merge rm ON release.id=rm.old_rel
    GROUP BY COALESCE(new_rel, id);

    SELECT release.id, gid,
        CASE
                WHEN rm1.new_rel IS NOT NULL THEN regexp_replace(n.name, E'\\\\s+[(](disc [0-9]+(: .*?)?|bonus disc(: .*?)?)[)]\$', '')
                ELSE n.name
        END,
        artist_credit, release_group, status, packaging, country, language, script,
        date_year, date_month, date_day, barcode, comment, edits_pending, q.quality,
        CASE
                WHEN count(*) > 1 THEN now()
                ELSE max(last_updated)
        END AS last_updated
    INTO TEMPORARY tmp_release
    FROM release
        INNER JOIN release_name n ON release.name=n.id
        LEFT JOIN tmp_release_merge rm0 ON release.id=rm0.old_rel
        LEFT JOIN (select distinct new_rel from tmp_release_merge) rm1 ON release.id=rm1.new_rel
        JOIN tmp_release_quality q ON q.id = release.id
    WHERE rm0.old_rel IS NULL
    GROUP BY release.id, release.gid, rm1.new_rel, regexp_replace(n.name, E'\\\\s+[(](disc [0-9]+(: .*?)?|bonus disc(: .*?)?)[)]\$', ''), 
             n.name, artist_credit, release_group, status, packaging, country, language, script,
             date_year, date_month, date_day, barcode, comment, edits_pending, q.quality;

    INSERT INTO release_name (name)
        SELECT DISTINCT t.name
        FROM tmp_release t
                LEFT JOIN release_name n ON t.name=n.name
        WHERE n.id IS NULL;

    TRUNCATE release;
    INSERT INTO release
        SELECT t.id, gid, n.id, artist_credit, release_group, status, packaging, country, language, script,
                date_year, date_month, date_day, barcode, comment, edits_pending, quality, last_updated
         FROM tmp_release t
                JOIN release_name n ON t.name = n.name;
    DROP TABLE tmp_release;
    DROP INDEX tmp_release_name_idx_name;
    ");

    printf STDERR "Updating release_group_meta\n";
    $sql->do("
    SELECT id, COALESCE(t.release_count, 0), first_release_date_year, first_release_date_month, first_release_date_day, rating, rating_count
        INTO TEMPORARY tmp_release_group_meta
        FROM release_group_meta rgm
                LEFT JOIN ( SELECT release_group, count(*) AS release_count FROM release GROUP BY release_group ) t ON t.release_group = rgm.id;

    TRUNCATE release_group_meta;
    INSERT INTO release_group_meta SELECT * FROM tmp_release_group_meta;
    ");

    # Remove or merge orphaned release-groups
    printf STDERR "Removing empty release groups\n";
    my $ids = $sql->select_single_column_array('
    SELECT rg.id
      FROM release_group rg
      JOIN release_group_meta rgm ON rgm.id = rg.id
     WHERE rgm.release_count = 0
       AND rg.id NOT IN (
           SELECT entity1 FROM l_artist_release_group
        UNION ALL
           SELECT entity1 FROM l_label_release_group
        UNION ALL
           SELECT entity1 FROM l_recording_release_group
        UNION ALL
           SELECT entity1 FROM l_release_release_group
        UNION ALL
           SELECT entity1 FROM l_release_group_release_group
        UNION ALL
           SELECT entity0 FROM l_release_group_release_group
        UNION ALL
           SELECT entity0 FROM l_release_group_url
        UNION ALL
           SELECT entity0 FROM l_release_group_work
       )
    ');

    $sql->do('DELETE FROM release_group_gid_redirect WHERE new_id = any(?)', $ids);
    $sql->do('DELETE FROM release_group_tag WHERE release_group = any(?)', $ids);
    $sql->do('DELETE FROM release_group WHERE id = any(?)', $ids);
    $sql->do('DELETE FROM release_group_meta WHERE id = any(?)', $ids);

    $c->raw_sql->do('DELETE FROM release_group_rating_raw WHERE release_group = any(?)', $ids);
    $c->raw_sql->do('DELETE FROM release_group_tag_raw WHERE release_group = any(?)', $ids);

    $sql->commit;
    $c->raw_sql->commit;
};
if ($@) {
    printf STDERR "ERROR: %s\n", $@;
    $sql->rollback;
    $c->raw_sql->rollback;
}
