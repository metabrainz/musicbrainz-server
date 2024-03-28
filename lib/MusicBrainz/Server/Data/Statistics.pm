package MusicBrainz::Server::Data::Statistics;
use Moose;
use namespace::autoclean;
use namespace::autoclean;
use warnings FATAL => 'all';

use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( get_area_containment_join placeholders );
use MusicBrainz::Server::Constants qw( :edit_status :vote );
use MusicBrainz::Server::Constants qw(
    $VARTIST_ID
    $EDITOR_MODBOT
    $EDITOR_FREEDB
    $SPAMMER_FLAG
    :quality
    %ENTITIES
    entities_with
);
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Translation::Statistics qw( l );
use MusicBrainz::Server::Replication qw( :replication_type );

use DBDefs;

use Fcntl qw(:flock SEEK_END);

with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistics.statistic' }

sub all_events {
    my ($self) = @_;

    return [
        map { $_->{title} = l($_->{title}); $_->{description} = l($_->{description}); $_; }
        @{$self->sql->select_list_of_hashes(
            'SELECT * FROM statistics.statistic_event ORDER BY date ASC',
        )},
    ];
}

sub fetch {
    my ($self, @names) = @_;

    my $query = 'SELECT name, value, row_number() OVER (PARTITION BY name ORDER BY date_collected DESC)'.
        ' FROM ' . $self->_table;
    $query .= ' WHERE name IN (' . placeholders(@names) . ')' if @names;

    $query = "SELECT name, value FROM ($query) s WHERE s.row_number = 1";

    my %stats =
        map { $_->{name} => $_->{value} }
        @{ $self->sql->select_list_of_hashes($query, @names) };

    if (@names) {
        if (wantarray) {
            return @stats{@names};
        }
        else {
            my $value = $stats{ $names[0] };
            return $value // 0;
        }
    }
    else {
        return \%stats;
    }
}

sub insert {
    my ($self, $output_file, %updates) = @_;
    $self->sql->do('LOCK TABLE ' . $self->_table . ' IN EXCLUSIVE MODE') unless $output_file;
    for my $key (keys %updates) {
        next unless defined $updates{$key};

        if ($output_file) {
                open(OUTPUTFILE, '>>'.$output_file);
                flock(OUTPUTFILE, LOCK_EX);
                seek(OUTPUTFILE, 0, SEEK_END);
                print OUTPUTFILE "$key\t$updates{$key}\n";
                close(OUTPUTFILE);
        } else {
            $self->sql->insert_row(
                $self->_table,
                { name => $key, value => $updates{$key} },
            );
        }
    }
}

sub last_refreshed {
    my $self = shift;
    return $self->sql->select_single_value(
        'SELECT min(date_collected) FROM ' . $self->_table);
}

my %stats = (
    'editor.top_recently_active' => {
        DESC => 'Top recently active editors',
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                q{SELECT editor, count(edit.id) FROM edit
                 JOIN editor ON edit.editor = editor.id
                 WHERE status IN (?, ?)
                   AND open_time >= now() - '1 week'::INTERVAL
                   AND cast(privs AS bit(2)) & B'10' = B'00'
                 GROUP BY edit.editor, editor.name
                 ORDER BY count(edit.id) DESC, editor.name COLLATE musicbrainz
                 LIMIT 25},
                $STATUS_OPEN, $STATUS_APPLIED,
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_recently_active.rank.$count"} = $editor->[0];
                $map{"count.edit.top_recently_active.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        },
    },
    'editor.top_active' => {
        DESC => 'Top active editors',
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                q{SELECT edit.editor, COUNT(edit.id)
                   FROM edit JOIN editor ON edit.editor = editor.id
                  WHERE status = ?
                    AND cast(editor.privs AS bit(2)) & B'10' = B'00'
                  GROUP BY edit.editor, editor.name
                  ORDER BY COUNT(edit.id) DESC, editor.name COLLATE musicbrainz
                  LIMIT 25},
                $STATUS_APPLIED,
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_active.rank.$count"} = $editor->[0];
                $map{"count.edit.top_active.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        },
    },
    'editor.top_recently_active_voters' => {
        DESC => 'Top recently active voters',
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                q{SELECT editor, count(vote.id) FROM vote
                 JOIN editor ON vote.editor = editor.id
                 WHERE NOT superseded AND vote != -1
                   AND vote_time >= now() - '1 week'::INTERVAL
                   AND cast(privs AS bit(10)) & 2::bit(10) = 0::bit(10)
                 GROUP BY vote.editor, editor.name
                 ORDER BY count(vote.id) DESC, editor.name COLLATE musicbrainz
                 LIMIT 25},
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_recently_active_voters.rank.$count"} = $editor->[0];
                $map{"count.vote.top_recently_active_voters.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        },
    },
    'editor.top_active_voters' => {
        DESC => 'Top active voters',
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                'SELECT editor, count(vote.id) FROM vote
                 JOIN editor ON vote.editor = editor.id
                 WHERE NOT superseded AND vote != -1
                   AND cast(privs AS bit(10)) & 2::bit(10) = 0::bit(10)
                 GROUP BY editor, editor.name
                 ORDER BY count(vote.id) DESC, editor.name COLLATE musicbrainz
                 LIMIT 25',
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_active_voters.rank.$count"} = $editor->[0];
                $map{"count.vote.top_active_voters.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        },
    },
    'count.mbid' => {
        DESC => 'Count of all MBIDs known/allocated',
        SQL => 'SELECT ' .
            join(' + ',
                 (map { "(SELECT COUNT(gid) FROM $_)" } entities_with('mbid', take => sub { my $type = shift; return shift->{table} // $type })),
                 (map { "(SELECT COUNT(gid) FROM ${_}_gid_redirect)" } entities_with(['mbid', 'multiple'], take => sub { my $type = shift; return shift->{table} // $type }))),
    },
    'count.release' => {
        DESC => 'Count of all releases',
        SQL => 'SELECT COUNT(*) FROM release',
    },
    'count.releasegroup' => {
        DESC => 'Count of all release groups',
        SQL => 'SELECT COUNT(*) FROM release_group',
    },
    'count.area' => {
        DESC => 'Count of all areas',
        SQL => 'SELECT COUNT(*) FROM area',
    },
    'count.country_area' => {
        DESC => 'Count of all areas eligible for release country use',
        SQL => 'SELECT COUNT(*) FROM country_area',
    },
    'count.area.type' => {
        DESC => 'Distribution of areas by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(area.id) AS count
                 FROM area_type type
                 FULL OUTER JOIN area ON area.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.area.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.artist' => {
        DESC => 'Count of all artists',
        SQL => 'SELECT COUNT(*) FROM artist',
    },
    'count.artist.type.person' => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type::text, 'null'), COUNT(*) AS count
                FROM artist
                GROUP BY type},
            );

            my %dist = map { @$_ } @$data;

            +{
                'count.artist.type.person' => $dist{1} || 0,
                'count.artist.type.group'  => $dist{2} || 0,
                'count.artist.type.other'  => $dist{3} || 0,
                'count.artist.type.character'  => $dist{4} || 0,
                'count.artist.type.orchestra'  => $dist{5} || 0,
                'count.artist.type.choir'  => $dist{6} || 0,
                'count.artist.type.null' => $dist{null} || 0,
            };
        },
    },
    'count.artist.type.group' => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.type.other' => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.type.null' => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.gender.male' => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(gender::text, 'null'), COUNT(*) AS count
                FROM artist
                WHERE (type NOT IN (2, 5, 6) OR type IS NULL)
                GROUP BY gender},
            );

            my %dist = map { @$_ } @$data;

            +{
                'count.artist.gender.male' => $dist{1} || 0,
                'count.artist.gender.female'  => $dist{2} || 0,
                'count.artist.gender.other' => $dist{3} || 0,
                'count.artist.gender.not_applicable' => $dist{4} || 0,
                'count.artist.gender.nonbinary' => $dist{5} || 0,
                'count.artist.gender.null' => $dist{null} || 0,
            };
        },
    },
    'count.artist.gender.female' => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.gender.other' => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.gender.not_applicable' => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.gender.nonbinary' => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.gender.null' => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    'count.artist.has_credits' => {
        DESC => 'Artists in at least one artist credit',
        SQL => 'SELECT COUNT(DISTINCT artist) FROM artist_credit_name',
    },
    'count.artist.0credits' => {
        DESC => 'Artists in no artist credits',
        SQL => 'SELECT COUNT(DISTINCT artist.id) FROM artist LEFT OUTER JOIN artist_credit_name ON artist.id = artist_credit_name.artist WHERE artist_credit_name.artist_credit IS NULL',
    },
    'count.event' => {
        DESC => 'Count of all events',
        SQL => 'SELECT COUNT(*) FROM event',
    },
    'count.event.country' => {
        DESC => 'Distribution of events per country',
        CALC => sub {
            my ($self, $sql) = @_;

            my $area_containment_join = get_area_containment_join($sql);

            my $data = $sql->select_list_of_lists(qq{
                SELECT COALESCE(iso.code::text, 'null'), COUNT(e.id)
                FROM event e
                JOIN (
                    SELECT lae.entity1 AS event, lae.entity0 AS area
                    FROM l_area_event lae
                    UNION
                    SELECT lep.entity0 AS event, p.area
                    FROM l_event_place lep
                    JOIN place p ON lep.entity1 = p.id
                ) event_area ON event_area.event = e.id
                LEFT JOIN $area_containment_join ac
                    ON event_area.area = ac.descendant
                    AND ac.parent IN (SELECT area FROM country_area)
                FULL OUTER JOIN iso_3166_1 iso
                    ON iso.area = COALESCE(
                        (SELECT area FROM country_area WHERE area = ac.descendant),
                        ac.parent,
                        event_area.area
                    )
                GROUP BY iso.code
            });

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.event.country.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.event.type' => {
        DESC => 'Distribution of events by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(event.id) AS count
                 FROM event_type type
                 FULL OUTER JOIN event ON event.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.event.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.event.has_art' => {
        DESC => 'Count of events with event art',
        SQL => 'SELECT COUNT(distinct event) FROM event_art_archive.event_art',
    },
    'count.event.has_front_art' => {
        DESC => 'Count of events with front event art',
        SQL => 'SELECT COUNT(distinct event) FROM event_art_archive.event_art ea
                  JOIN event_art_archive.event_art_type eat ON ea.id = eat.id
                WHERE eat.type_id = 1',
    },
    'count.event.art' => {
        DESC => 'Count of all event art',
        SQL => 'SELECT count(*) FROM event_art_archive.event_art',
    },
    'count.genre' => {
        DESC => 'Count of all genres',
        SQL => 'SELECT COUNT(*) FROM genre',
    },
    'count.instrument' => {
        DESC => 'Count of all instruments',
        SQL => 'SELECT COUNT(*) FROM instrument',
    },
    'count.instrument.type' => {
        DESC => 'Distribution of instruments by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(instrument.id) AS count
                 FROM instrument_type type
                 FULL OUTER JOIN instrument ON instrument.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.instrument.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.place' => {
        DESC => 'Count of all places',
        SQL => 'SELECT COUNT(*) FROM place',
    },
    'count.place.country' => {
        DESC => 'Distribution of places per country',
        CALC => sub {
            my ($self, $sql) = @_;

            my $area_containment_join = get_area_containment_join($sql);

            my $data = $sql->select_list_of_lists(qq{
                SELECT COALESCE(iso.code::text, 'null'), COUNT(p.id)
                FROM place p
                LEFT JOIN $area_containment_join ac
                    ON p.area = ac.descendant
                    AND ac.parent IN (SELECT area FROM country_area)
                FULL OUTER JOIN iso_3166_1 iso
                    ON iso.area = COALESCE(
                        (SELECT area FROM country_area WHERE area = ac.descendant),
                        ac.parent,
                        p.area
                    )
                GROUP BY iso.code
            });

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.place.country.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.place.type' => {
        DESC => 'Distribution of places by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(place.id) AS count
                 FROM place_type type
                 FULL OUTER JOIN place ON place.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.place.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.series' => {
        DESC => 'Count of all series',
        SQL => 'SELECT COUNT(*) FROM series',
    },
    'count.series.type' => {
        DESC => 'Distribution of series by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT type.id::text, COUNT(series.id) AS count
                 FROM series_type type
                 FULL OUTER JOIN series ON series.type = type.id
                 GROUP BY type.id',
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.series.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.url' => {
        DESC => 'Count of all URLs',
        SQL => 'SELECT count(*) FROM url',
    },
    'count.coverart' => {
        DESC => 'Count of all cover art images',
        SQL => 'SELECT count(*) FROM cover_art_archive.cover_art',
    },
    'count.coverart.type' => {
        DESC => 'Distribution of cover art by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT art_type.name, COUNT(cover_art_type.id) AS count
                 FROM cover_art_archive.cover_art_type
                 JOIN cover_art_archive.art_type ON art_type.id = cover_art_type.type_id
                 GROUP BY art_type.name',
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.coverart.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.coverart.caa' => {
        DESC => 'Releases whose cover art comes from the CAA',
        SQL => 'SELECT COUNT(distinct release) FROM cover_art_archive.cover_art ca
                  JOIN cover_art_archive.cover_art_type cat ON ca.id = cat.id
                WHERE cat.type_id = 1',
    },
    'count.release.coverart.none' => {
        PREREQ => [qw[ count.release count.release.coverart.caa ]],
        DESC => 'Releases with no cover art',
        CALC => sub {
            my ($self, $sql) = @_;

            return $self->fetch('count.release') - $self->fetch('count.release.coverart.caa');
        },
        NONREPLICATED => 1,
    },
    'count.release.status.statname.has_coverart' => {
        DESC => 'Count of releases with cover art, by status',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT
                   coalesce(release_status.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 FULL OUTER JOIN release_status
                   ON release_status.id = release.status
                 GROUP BY coalesce(release_status.name, 'null')},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.status.'.$_. '.has_coverart' => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.type.typename.has_coverart' => {
        DESC => 'Count of releases with cover art, by release group type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT
                   coalesce(release_group_primary_type.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 JOIN release_group
                   ON release.release_group = release_group.id
                 FULL OUTER JOIN release_group_primary_type
                   ON release_group_primary_type.id = release_group.type
                 GROUP BY coalesce(release_group_primary_type.name, 'null')},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.type.'.$_. '.has_coverart' => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.format.fname.has_coverart' => {
        DESC => 'Count of releases with cover art, by medium format',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT
                   coalesce(medium_format.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 JOIN medium ON medium.release = release.id
                 FULL OUTER JOIN medium_format
                   ON medium_format.id = medium.format
                 GROUP BY coalesce(medium_format.name, 'null')},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.format.'.$_. '.has_coverart' => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.coverart.per_release.Nimages' => {
        DESC => 'Distribution of cover art images per release',
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 30;

            my $data = $sql->select_list_of_lists(
                'SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT release, COUNT(*) AS c
                    FROM cover_art_archive.cover_art
                    GROUP BY release
                ) AS t
                GROUP BY c',
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            +{
                map {
                    'count.coverart.per_release.'.$_. 'images' => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.label' => {
        DESC => 'Count of all labels',
        SQL => 'SELECT COUNT(*) FROM label',
    },
    'count.label.type' => {
        DESC => 'Distribution of labels by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(label.id) AS count
                 FROM label_type type
                 FULL OUTER JOIN label ON label.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.label.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.discid' => {
        DESC => 'Count of all disc IDs',
        SQL => 'SELECT COUNT(*) FROM cdtoc',
    },
    'count.edit' => {
        DESC => 'Count of all edits',
        SQL => 'SELECT COUNT(*) FROM edit',
        NONREPLICATED => 1,
    },

    'count.editor' => {
        DESC => 'Count of all editors, and assorted sub-pieces',
        CALC => sub {
            my ($self, $sql) = @_;
            my $data = $sql->select_list_of_hashes('
                WITH tag_editors AS (
                  SELECT editor FROM artist_tag_raw
                  UNION SELECT editor FROM area_tag_raw
                  UNION SELECT editor FROM event_tag_raw
                  UNION SELECT editor FROM instrument_tag_raw
                  UNION SELECT editor FROM label_tag_raw
                  UNION SELECT editor FROM place_tag_raw
                  UNION SELECT editor FROM recording_tag_raw
                  UNION SELECT editor FROM series_tag_raw
                  UNION SELECT editor FROM work_tag_raw
                  UNION SELECT editor FROM release_tag_raw
                  UNION SELECT editor FROM release_group_tag_raw
                ),
                rating_editors AS (
                  SELECT editor FROM artist_rating_raw
                  UNION SELECT editor FROM event_rating_raw
                  UNION SELECT editor FROM label_rating_raw
                  UNION SELECT editor FROM recording_rating_raw
                  UNION SELECT editor FROM work_rating_raw
                  UNION SELECT editor FROM release_group_rating_raw
                ),
                subscribed_editors AS (
                  SELECT editor FROM editor_subscribe_editor
                  UNION SELECT editor FROM editor_subscribe_collection
                  UNION SELECT editor FROM editor_subscribe_artist
                  UNION SELECT editor FROM editor_subscribe_artist_deleted
                  UNION SELECT editor FROM editor_subscribe_label
                  UNION SELECT editor FROM editor_subscribe_label_deleted
                  UNION SELECT editor FROM editor_subscribe_series
                  UNION SELECT editor FROM editor_subscribe_series_deleted
                ),
                collection_editors AS (SELECT DISTINCT editor FROM editor_collection
                  WHERE ' . join(' OR ', map {
                    "EXISTS (SELECT TRUE FROM editor_collection_$_ WHERE collection=editor_collection.id LIMIT 1)"
                  } entities_with('collections')) . " ),
                voters AS (SELECT DISTINCT editor FROM vote),
                noters AS (SELECT DISTINCT editor FROM edit_note),
                application_editors AS (SELECT DISTINCT owner FROM application)
                SELECT count(id),
                       deleted AS deleted,
                       (NOT deleted AND (privs & $SPAMMER_FLAG) = 0) AS valid,
                       email_confirm_date IS NOT NULL AS validated,
                       EXISTS (SELECT 1 FROM edit WHERE edit.editor = editor.id) AS edits,
                       tag_editors.editor IS NOT NULL as tags,
                       rating_editors.editor IS NOT NULL AS ratings,
                       subscribed_editors.editor IS NOT NULL AS subscriptions,
                       collection_editors.editor IS NOT NULL AS collections,
                       voters.editor IS NOT NULL AS votes,
                       noters.editor IS NOT NULL as notes,
                       application_editors.owner IS NOT NULL as applications
                FROM editor
                LEFT JOIN tag_editors ON editor.id = tag_editors.editor
                LEFT JOIN rating_editors ON editor.id = rating_editors.editor
                LEFT JOIN subscribed_editors ON editor.id = subscribed_editors.editor
                LEFT JOIN collection_editors ON editor.id = collection_editors.editor
                LEFT JOIN voters ON editor.id = voters.editor
                LEFT JOIN noters ON editor.id = noters.editor
                LEFT JOIN application_editors ON editor.id = application_editors.owner
                GROUP BY deleted, valid, validated, edits, tags, ratings, subscriptions, collections, votes, notes, applications");

            my @active_markers = qw(edits tags ratings subscriptions collections votes notes applications);
            my $stats = {
                'count.editor' => sub { return 1 },
                'count.editor.deleted' => sub { return shift->{deleted}},
                'count.editor.valid' => sub { return shift->{valid} },
                'count.editor.valid.inactive' => sub {
                    my $row = shift;
                    return $row->{valid} && !$row->{validated} && !(grep { $row->{$_} } @active_markers);
                },
                'count.editor.valid.active' => sub {
                    my $row = shift;
                    return $row->{valid} && (grep { $row->{$_} } @active_markers);
                },
                'count.editor.valid.validated_only' => sub {
                    my $row = shift;
                    return $row->{valid} && $row->{validated} && !(grep { $row->{$_} } @active_markers);
                },
            };
            my %ret = map { $_ => 0 } (keys %$stats, map { 'count.editor.valid.active.'.$_ } @active_markers);
            for my $row (@$data) {
                for my $stat (keys %$stats) {
                    if ($stats->{$stat}->($row)) {
                        $ret{$stat} += $row->{count};
                    }
                }
                for my $marker (@active_markers) {
                    if ($row->{$marker} && $row->{valid}) {
                        $ret{'count.editor.valid.active.'.$marker} += $row->{count};
                    }
                }
            }
            return \%ret;
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },

    'count.barcode' => {
        DESC => 'Count of all unique barcodes',
        SQL => 'SELECT COUNT(distinct barcode) FROM release',
    },
    'count.medium' => {
        DESC => 'Count of all mediums',
        SQL => 'SELECT COUNT(*) FROM medium',
    },
    'count.track' => {
        DESC => 'Count of all tracks',
        SQL => 'SELECT COUNT(*) FROM track',
    },
    'count.recording' => {
        DESC => 'Count of all recordings',
        SQL => 'SELECT COUNT(*) FROM recording',
    },
    'count.recording.standalone' => {
        DESC => 'Count of all standalone recordings',
        SQL => 'SELECT COUNT(*) FROM recording WHERE NOT EXISTS (
                    SELECT 1 FROM track WHERE track.recording = recording.id
                )',
    },
    'count.video' => {
        DESC => 'Count of all video recordings',
        SQL => 'SELECT COUNT(*) FROM recording WHERE video',
    },
    'count.work' => {
        DESC => 'Count of all works',
        SQL => 'SELECT COUNT(*) FROM work',
    },
    'count.work.has_iswc' => {
        DESC => 'Count of all works with at least one ISWC',
        SQL => 'SELECT COUNT(DISTINCT work) FROM iswc',
    },
    'count.work.language' => {
        DESC => 'Distribution of works by lyrics language',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                         SELECT coalesce(l.iso_code_3::text, 'null'),
                                count(w.gid) AS count
                           FROM work w
                      LEFT JOIN work_language wl ON wl.work=w.id
                FULL OUTER JOIN language l ON wl.language=l.id
                          WHERE l.iso_code_2t IS NOT NULL
                             OR l.frequency > 0
                             OR l.id IS NULL
                       GROUP BY l.iso_code_3
                SQL

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.work.language.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.work.type' => {
        DESC => 'Distribution of works by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(type.id::text, 'null'), COUNT(work.id) AS count
                 FROM work_type type
                 FULL OUTER JOIN work ON work.type = type.id
                 GROUP BY type.id},
            );

            my %dist = map { @$_ } @$data;
            $dist{null} ||= 0;

            +{
                map {
                    'count.work.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.work.attribute' => {
        DESC => 'Distribution of works by attributes',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(work_attribute_type.id::text, 'null'),
                   COUNT(DISTINCT work.id) AS count
                 FROM work_attribute
                 FULL OUTER JOIN work_attribute_type ON work_attribute_type.id = work_attribute.work_attribute_type
                 FULL OUTER JOIN work ON work.id = work_attribute.work
                 GROUP BY work_attribute_type.id},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.work.attribute.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.artistcredit' => {
        DESC => 'Count of all artist credits',
        SQL => 'SELECT COUNT(*) FROM artist_credit',
    },
    'count.ipi' => {
        DESC => 'Count of IPI codes',
        PREREQ => [qw[ count.ipi.artist count.ipi.label ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.ipi.artist') + $self->fetch('count.ipi.label');
        },
    },
    'count.ipi.artist' => {
        DESC => 'Count of artists with an IPI code',
        SQL => 'SELECT COUNT(DISTINCT artist) FROM artist_ipi',
    },
    'count.ipi.label' => {
        DESC => 'Count of labels with an IPI code',
        SQL => 'SELECT COUNT(DISTINCT label) FROM label_ipi',
    },
    'count.isni' => {
        DESC => 'Count of ISNI codes',
        PREREQ => [qw[ count.isni.artist count.isni.label ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.isni.artist') + $self->fetch('count.isni.label');
        },
    },
    'count.isni.artist' => {
        DESC => 'Count of artists with an ISNI code',
        SQL => 'SELECT COUNT(DISTINCT artist) FROM artist_isni',
    },
    'count.isni.label' => {
        DESC => 'Count of labels with an ISNI code',
        SQL => 'SELECT COUNT(DISTINCT label) FROM label_isni',
    },
    'count.isrc.all' => {
        DESC => 'Count of all ISRCs joined to recordings',
        SQL => 'SELECT COUNT(*) FROM isrc',
    },
    'count.isrc' => {
        DESC => 'Count of unique ISRCs',
        SQL => 'SELECT COUNT(distinct isrc) FROM isrc',
    },
    'count.iswc.all' => {
        DESC => 'Count of all ISWCs',
        SQL => 'SELECT COUNT(*) FROM iswc',
    },
    'count.iswc' => {
        DESC => 'Count of unique ISWCs',
        SQL => 'SELECT COUNT(distinct iswc) FROM iswc',
    },
    'count.vote' => {
        DESC => 'Count of all votes',
        SQL => 'SELECT COUNT(*) FROM vote',
        NONREPLICATED => 1,
    },

    'count.label.country' => {
        DESC => 'Distribution of labels per country',
        CALC => sub {
            my ($self, $sql) = @_;

            my $area_containment_join = get_area_containment_join($sql);

            my $data = $sql->select_list_of_lists(qq{
                SELECT COALESCE(iso.code::text, 'null'), COUNT(l.id)
                FROM label l
                LEFT JOIN $area_containment_join ac
                    ON l.area = ac.descendant
                    AND ac.parent IN (SELECT area FROM country_area)
                FULL OUTER JOIN iso_3166_1 iso
                    ON iso.area = COALESCE(
                        (SELECT area FROM country_area WHERE area = ac.descendant),
                        ac.parent,
                        l.area
                    )
                GROUP BY iso.code
            });

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.label.country.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.release.country' => {
        DESC => 'Distribution of releases per country',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(iso.code::text, 'null'), COUNT(r.gid) AS count
                FROM release r
                LEFT JOIN release_country rc ON r.id = rc.release
                FULL OUTER JOIN country_area c ON rc.country = c.area
                FULL OUTER JOIN iso_3166_1 iso ON c.area = iso.area
                GROUP BY iso.code},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.country.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.format' => {
         DESC => 'Distribution of releases by format',
         CALC => sub {
             my ($self, $sql) = @_;
             my $data = $sql->select_list_of_lists(
                 q{SELECT COALESCE(medium_format.id::text, 'null'), count(DISTINCT medium.release) AS count
                 FROM medium FULL OUTER JOIN medium_format
                     ON medium.format = medium_format.id
                 GROUP BY medium_format.id},
             );

             my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.format.'.$_ => $dist{$_}
                } keys %dist,
            };
         },
    },
    'count.medium.format' => {
         DESC => 'Distribution of mediums by format',
         CALC => sub {
             my ($self, $sql) = @_;
             my $data = $sql->select_list_of_lists(
                 q{SELECT COALESCE(medium_format.id::text, 'null'), count(DISTINCT medium.id) AS count
                 FROM medium FULL OUTER JOIN medium_format
                     ON medium.format = medium_format.id
                 GROUP BY medium_format.id},
             );

             my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.medium.format.'.$_ => $dist{$_}
                } keys %dist,
            };
         },
    },
    'count.release.language' => {
        DESC => 'Distribution of releases by language',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                         SELECT coalesce(l.iso_code_3::text, 'null'),
                                count(r.gid) AS count
                           FROM release r
                FULL OUTER JOIN language l ON r.language=l.id
                          WHERE l.iso_code_2t IS NOT NULL
                             OR l.frequency > 0
                             OR l.id IS NULL
                       GROUP BY l.iso_code_3
                SQL

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.language.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.script' => {
        DESC => 'Distribution of releases by script',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(s.iso_code::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN script s
                    ON r.script=s.id
                GROUP BY s.iso_code},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.script.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.status' => {
        DESC => 'Distribution of releases by status',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(s.id::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN release_status s
                    ON r.status=s.id
                GROUP BY s.id},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.status.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.release.packaging' => {
        DESC => 'Distribution of releases by packaging',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                q{SELECT COALESCE(p.id::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN release_packaging p
                    ON r.packaging=p.id
                GROUP BY p.id},
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.release.packaging.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.releasegroup.Nreleases' => {
        DESC => 'Distribution of releases per releasegroup',
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                'SELECT release_count, COUNT(*) AS freq
                FROM release_group_meta
                GROUP BY release_count',
            );

            my %dist = map { $_ => 0 } 0 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            +{
                map {
                    'count.releasegroup.'.$_.'releases' => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.releasegroup.primary_type' => {
        DESC => 'Distribution of release groups by primary type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                         SELECT COALESCE(type.id::text, 'null'),
                                COUNT(rg.id) AS count
                           FROM release_group_primary_type type
                FULL OUTER JOIN release_group rg ON rg.type = type.id
                       GROUP BY type.id
                SQL

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.releasegroup.primary_type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.releasegroup.secondary_type' => {
        DESC => 'Distribution of release groups by secondary type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                         SELECT COALESCE(type.id::text, 'null'),
                                COUNT(rg.id) AS count
                           FROM release_group_secondary_type type
                      LEFT JOIN release_group_secondary_type_join type_join
                             ON type.id = type_join.secondary_type
                FULL OUTER JOIN release_group rg
                             ON rg.id = type_join.release_group
                       GROUP BY type.id
                SQL

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.releasegroup.secondary_type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },
    'count.releasegroup.caa' => {
        DESC => 'Count of release groups that have CAA artwork',
        SQL => q{
          SELECT count(DISTINCT release.release_group)
          FROM cover_art_archive.index_listing
          JOIN musicbrainz.release
            ON musicbrainz.release.id = cover_art_archive.index_listing.release
         WHERE is_front = true
        },
    },
    'count.releasegroup.caa.manually_selected' => {
        DESC => 'Count of release groups that have CAA artwork manually selected',
        SQL => 'SELECT count(DISTINCT release_group)
                FROM cover_art_archive.release_group_cover_art',
    },
    'count.releasegroup.caa.inferred' => {
        PREREQ => [qw[ count.releasegroup.caa count.releasegroup.caa.manually_selected ]],
        DESC => 'Releases groups with CAA artwork inferred from release artwork',
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.releasegroup.caa') -
                $self->fetch('count.releasegroup.caa.manually_selected');
        },
    },
    'count.release.various' => {
        DESC => q(Count of all 'Various Artists' releases),
        SQL => 'SELECT COUNT(*) FROM release
                  JOIN artist_credit ac ON ac.id = artist_credit
                  JOIN artist_credit_name acn ON acn.artist_credit = ac.id
                 WHERE artist_count = 1 AND artist = ' . $VARTIST_ID,
    },
    'count.release.nonvarious' => {
        DESC => q(Count of all releases, other than 'Various Artists'),
        PREREQ => [qw[ count.release count.release.various ]],
        CALC => sub {
            my ($self, $sql) = @_;

            $self->fetch('count.release')
                - $self->fetch('count.release.various');
        },
    },
    'count.medium.has_discid' => {
        DESC => 'Count of media with at least one disc ID',
        SQL => 'SELECT COUNT(DISTINCT medium) FROM medium_cdtoc',
    },
    'count.release.has_discid' => {
        DESC => 'Count of releases with at least one disc ID',
        SQL => 'SELECT COUNT(DISTINCT medium.release)
                  FROM medium_cdtoc
                  JOIN medium ON medium_cdtoc.medium = medium.id',
    },
    'count.release.has_caa' => {
        DESC => 'Count of releases that have cover art at the Cover Art Archive',
        SQL => 'SELECT count(DISTINCT release) FROM cover_art_archive.cover_art',
        PRIVATE => 1,
    },

    'count.recording.has_isrc' => {
        DESC => 'Count of recordings with at least one ISRC',
        SQL => 'SELECT COUNT(DISTINCT recording) FROM isrc',
    },

    'count.edit.open' => {
        DESC => 'Count of open edits',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT status, COUNT(*) FROM edit GROUP BY status',
            );

            my %dist = map { @$_ } @$data;

            +{
                'count.edit.open'           => $dist{$STATUS_OPEN}          || 0,
                'count.edit.applied'        => $dist{$STATUS_APPLIED}       || 0,
                'count.edit.failedvote'     => $dist{$STATUS_FAILEDVOTE}    || 0,
                'count.edit.faileddep'      => $dist{$STATUS_FAILEDDEP}     || 0,
                'count.edit.error'          => $dist{$STATUS_ERROR}         || 0,
                'count.edit.failedprereq'   => $dist{$STATUS_FAILEDPREREQ}  || 0,
                'count.edit.deleted'        => $dist{$STATUS_DELETED}       || 0,
            };
        },
        NONREPLICATED => 1,
    },
    'count.edit.applied' => {
        DESC => 'Count of applied edits',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.failedvote' => {
        DESC => 'Count of edits which were voted down',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.faileddep' => {
        DESC => 'Count of edits which failed their dependency check',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.error' => {
        DESC => 'Count of edits which failed because of an internal error',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.failedprereq' => {
        DESC => 'Count of edits which failed because a prerequisitite moderation failed',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.deleted' => {
        DESC => 'Count of deleted edits',
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.edit.perday' => {
        DESC => 'Count of edits per day',
        SQL => q{SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '1 day')
                  AND editor NOT IN (}. $EDITOR_FREEDB .', '. $EDITOR_MODBOT .')',
        NONREPLICATED => 1,
    },
    'count.edit.perweek' => {
        DESC => 'Count of edits per week',
        SQL => q{SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '7 days')
                  AND editor NOT IN (}. $EDITOR_FREEDB .', '. $EDITOR_MODBOT .')',
        NONREPLICATED => 1,
    },
    'count.edit.type' => {
        DESC => 'Count of edits by type',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT type, count(id) AS count
                FROM edit GROUP BY type',
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.edit.type.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.cdstub' => {
        DESC => 'Count of all existing CD Stubs',
        SQL => 'SELECT COUNT(*) FROM release_raw',
        NONREPLICATED => 1,
    },
    'count.cdstub.submitted' => {
        DESC => 'Count of all submitted CD Stubs',
        SQL => 'SELECT MAX(id) FROM release_raw',
        NONREPLICATED => 1,
    },
    'count.cdstub.track' => {
        DESC => 'Count of all CD Stub tracks',
        SQL => 'SELECT COUNT(*) FROM track_raw',
        NONREPLICATED => 1,
    },

    'count.artist.country' => {
        DESC => 'Distribution of artists per country',
        CALC => sub {
            my ($self, $sql) = @_;

            my $area_containment_join = get_area_containment_join($sql);

            my $data = $sql->select_list_of_lists(qq{
                SELECT COALESCE(iso.code::text, 'null'), COUNT(a.id)
                FROM artist a
                LEFT JOIN $area_containment_join ac
                    ON a.area = ac.descendant
                    AND ac.parent IN (SELECT area FROM country_area)
                FULL OUTER JOIN iso_3166_1 iso
                    ON iso.area = COALESCE(
                        (SELECT area FROM country_area WHERE area = ac.descendant),
                        ac.parent,
                        a.area
                    )
                GROUP BY iso.code
            });

            my %dist = map { @$_ } @$data;

            +{
                map {
                    'count.artist.country.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.vote.yes' => {
        DESC => q(Count of 'yes' votes),
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT vote, COUNT(*) FROM vote GROUP BY vote',
            );

            my %dist = map { @$_ } @$data;

            +{
                'count.vote.yes'        => $dist{$VOTE_YES} || 0,
                'count.vote.no'         => $dist{$VOTE_NO}  || 0,
                'count.vote.abstain'    => $dist{$VOTE_ABSTAIN} || 0,
                'count.vote.approve'    => $dist{$VOTE_APPROVE} || 0,
            };
        },
        NONREPLICATED => 1,
    },
    'count.vote.no' => {
        DESC => q(Count of 'no' votes),
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.vote.abstain' => {
        DESC => q(Count of 'abstain' votes),
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.vote.approve' => {
        DESC => 'Count of auto-editor approvals',
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.vote.perday' => {
        DESC => 'Count of votes per day',
        SQL => q{SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '1 day')
                  AND vote <> } . $VOTE_ABSTAIN,
        NONREPLICATED => 1,
    },
    'count.vote.perweek' => {
        DESC => 'Count of votes per week',
        SQL => q{SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '7 days')
                  AND vote <> } . $VOTE_ABSTAIN,
        NONREPLICATED => 1,
    },

    # count active moderators in last week(?)
    # editing / voting / overall

    'count.editor.editlastweek' => {
        DESC => 'Count of editors who have submitted edits during the last week',
        CALC => sub {
            my ($self, $sql) = @_;

            my $threshold_id = $sql->select_single_value(
                q{SELECT MAX(id) FROM edit
                WHERE open_time <= (now() - interval '7 days')},
            );

            # Active voters
            my $voters = $sql->select_single_value(
                'SELECT COUNT(DISTINCT editor)
                FROM vote
                WHERE edit > ?
                AND editor != ?',
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Editors
            my $editors = $sql->select_single_value(
                'SELECT COUNT(DISTINCT editor)
                FROM edit
                WHERE id > ?
                AND editor != ?',
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Either
            my $both = $sql->select_single_value(
                'SELECT COUNT(DISTINCT m) FROM (
                    SELECT editor AS m
                    FROM edit
                    WHERE id > ?
                    UNION
                    SELECT editor AS m
                    FROM vote
                    WHERE edit > ?
                ) t WHERE m != ?',
                $threshold_id,
                $threshold_id,
                $EDITOR_FREEDB,
            );

            +{
                'count.editor.editlastweek' => $editors,
                'count.editor.votelastweek' => $voters,
                'count.editor.activelastweek'=> $both,
            };
        },
        NONREPLICATED => 1,
    },
    'count.editor.votelastweek' => {
        DESC => 'Count of editors who have voted on edits during the last week',
        PREREQ => [qw[ count.editor.editlastweek ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    'count.editor.activelastweek' => {
        DESC => 'Count of active editors (editing or voting) during the last week',
        PREREQ => [qw[ count.editor.editlastweek ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },

    # To add?
    # - top 10 moderators
    #   - open and accepted last week
    #   - accepted all time
    # Top 10 voters all time

    # Tags
    'count.tag' => {
        DESC => 'Count of all tags',
        SQL => 'SELECT COUNT(*) FROM tag',
    },

    (map {
        my $name = $_;
        $name =~ s/_//; # release_group -> releasegroup

        my $entity_properties = $ENTITIES{$_};
        my $url = $entity_properties->{url};

        ("count.tag.raw.$name" => {
            DESC => "Count of all $url raw tags",
            SQL => "SELECT COUNT(*) FROM ${_}_tag_raw",
            NONREPLICATED => 1,
            PRIVATE => 1,
        })
    } entities_with(['tags'])),

    'count.tag.raw' => {
        DESC => 'Count of all raw tags',
        PREREQ => [ map { $_ =~ s/_//; "count.tag.raw.$_" } entities_with(['tags']) ],
        CALC => sub {
            my ($self, $sql) = @_;

            my $count = 0;
            for (entities_with(['tags'])) {
                $_ =~ s/_//;
                $count += $self->fetch("count.tag.raw.$_");
            }
            return $count;
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },

    # Ratings
    'count.rating.artist' => {
        DESC => 'Count of artist ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM artist_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.artist'       => $data->[0]   || 0,
                'count.rating.raw.artist'   => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.artist' => {
        DESC => 'Count of all artist raw ratings',
        PREREQ => [qw[ count.rating.artist ]],
        PREREQ_ONLY => 1,
    },
    'count.rating.releasegroup' => {
        DESC => 'Count of release group ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM release_group_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.releasegroup'     => $data->[0]   || 0,
                'count.rating.raw.releasegroup' => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.releasegroup' => {
        DESC => 'Count of all release group raw ratings',
        PREREQ => [qw[ count.rating.releasegroup ]],
        PREREQ_ONLY => 1,
    },
    'count.rating.recording' => {
        DESC => 'Count of recording ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM recording_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.recording'        => $data->[0]   || 0,
                'count.rating.raw.recording'    => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.recording' => {
        DESC => 'Count of all recording raw ratings',
        PREREQ => [qw[ count.rating.recording ]],
        PREREQ_ONLY => 1,
    },
    'count.rating.label' => {
        DESC => 'Count of label ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM label_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.label'        => $data->[0]   || 0,
                'count.rating.raw.label'    => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.label' => {
        DESC => 'Count of all label raw ratings',
        PREREQ => [qw[ count.rating.label ]],
        PREREQ_ONLY => 1,
    },
    'count.rating.place' => {
        DESC => 'Count of place ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM place_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.place'        => $data->[0]   || 0,
                'count.rating.raw.place'    => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.place' => {
        DESC => 'Count of all place raw ratings',
        PREREQ => [qw[ count.rating.place ]],
        PREREQ_ONLY => 1,
    },
    'count.rating.work' => {
        DESC => 'Count of work ratings',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                'SELECT COUNT(*), SUM(rating_count) FROM work_meta WHERE rating_count > 0',
            );

            +{
                'count.rating.work'        => $data->[0]   || 0,
                'count.rating.raw.work'    => $data->[1]   || 0,
            };
        },
    },
    'count.rating.raw.work' => {
        DESC => 'Count of all work raw ratings',
        PREREQ => [qw[ count.rating.work ]],
        PREREQ_ONLY => 1,
    },
    'count.rating' => {
        DESC => 'Count of all ratings',
        PREREQ => [qw[ count.rating.artist count.rating.label count.rating.place count.rating.releasegroup count.rating.recording count.rating.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.artist') +
                   $self->fetch('count.rating.label') +
                   $self->fetch('count.rating.place') +
                   $self->fetch('count.rating.releasegroup') +
                   $self->fetch('count.rating.work') +
                   $self->fetch('count.rating.recording');
        },
    },
    'count.rating.raw' => {
        DESC => 'Count of all raw ratings',
        PREREQ => [qw[ count.rating.raw.artist count.rating.raw.label count.rating.raw.place count.rating.raw.releasegroup count.rating.raw.recording count.rating.raw.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.raw.artist') +
                   $self->fetch('count.rating.raw.label') +
                   $self->fetch('count.rating.raw.place') +
                   $self->fetch('count.rating.raw.releasegroup') +
                   $self->fetch('count.rating.raw.work') +
                   $self->fetch('count.rating.raw.recording');
        },
    },

    'count.release.Ndiscids' => {
        DESC => 'Distribution of disc IDs per release (varying disc IDs)',
        PREREQ => [qw[ count.release count.release.has_discid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                'SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT medium.release, COUNT(*) AS c
                    FROM medium_cdtoc
                    JOIN medium ON medium_cdtoc.medium = medium.id
                    GROUP BY medium.release
                ) AS t
                GROUP BY c',
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch('count.release')
                - $self->fetch('count.release.has_discid');

            +{
                map {
                    'count.release.'.$_.'discids' => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.medium.Ndiscids' => {
        DESC => 'Distribution of disc IDs per medium (varying disc IDs)',
        PREREQ => [qw[ count.medium count.medium.has_discid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                'SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT medium, COUNT(*) AS c
                    FROM medium_cdtoc
                    GROUP BY medium
                ) AS t
                GROUP BY c',
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch('count.medium')
                - $self->fetch('count.medium.has_discid');

            +{
                map {
                    'count.medium.'.$_.'discids' => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.quality.release.high' => {
        DESC => 'Count of high quality releases',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                'SELECT quality, COUNT(*) FROM release GROUP BY quality',
            );


            my %dist = map { @$_ } @$data;
            +{
                'count.quality.release.high'    => $dist{$QUALITY_HIGH} || 0,
                'count.quality.release.low'     => $dist{$QUALITY_LOW}      || 0,
                'count.quality.release.normal'  => $dist{$QUALITY_NORMAL}   || 0,
                'count.quality.release.unknown' => $dist{$QUALITY_UNKNOWN}  || 0,
                'count.quality.release.default' => ($dist{$QUALITY_UNKNOWN} || 0) + ($dist{$QUALITY_NORMAL} || 0),
            };
        },
    },
    'count.quality.release.low' => {
        DESC => 'Count of low quality releases',
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    'count.quality.release.normal' => {
        DESC => 'Count of normal quality releases',
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    'count.quality.release.unknown' => {
        DESC => 'Count of unknow quality releases',
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    'count.quality.release.default' => {
        DESC => 'Count of default quality releases',
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },

    'count.recording.Nreleases' => {
        DESC => 'Distribution of appearances on releases per recording',
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                'SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT r.id, count(distinct release.id) AS c
                        FROM recording r
                        LEFT JOIN track t ON t.recording = r.id
                        LEFT JOIN medium m ON t.medium = m.id
                        LEFT JOIN release ON m.release = release.id
                    GROUP BY r.id
                ) AS t
                GROUP BY c',
            );

            my %dist = map { $_ => 0 } 0 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            +{
                map {
                    'count.recording.'.$_.'releases' => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.ar.links.table.type_name' => {
        DESC => 'Count of advanced relationship links by type, inclusive of child counts and exclusive',
        CALC => sub {
            my ($self, $sql) = @_;
            my %dist;
            for my $t ($self->c->model('Relationship')->all_pairs) {
                my $table = join('_', 'l', @$t);
                my $data = $sql->select_list_of_hashes(
                    "SELECT lt.id, lt.name, lt.parent, count(l_table.id)
                     FROM $table l_table
                         RIGHT JOIN link ON l_table.link = link.id
                         RIGHT JOIN
                             (SELECT * FROM link_type WHERE entity_type0 = ? AND entity_type1 = ?)
                         AS lt ON link.link_type = lt.id
                     GROUP BY lt.name, lt.id, lt.parent", @$t,
                );

                for (@$data) {
                    $dist{ $table . q(.) . $_->{name} } = $_->{count};
                    $dist{ $table . q(.) . $_->{name} . '.inclusive' } = $_->{count};
                }
                for (@$data) {
                    my $parent = $_->{parent};
                    my $count = $_->{count};
                    while (defined $parent) {
                        my @parent_obj = grep { $_->{id} == $parent } @$data;
                        my $parent_obj;

                        if (scalar(@parent_obj) == 1) {
                            $parent_obj = $parent_obj[0];
                        }

                        die unless $parent_obj;

                        $dist{ $table . q(.) . $parent_obj->{name} . '.inclusive' } += $count;

                        $parent = $parent_obj->{parent};
                    }
                }
            }

            +{
                map {
                    'count.ar.links.'.$_ => $dist{$_}
                } keys %dist,
            };
        },
    },

    'count.ar.links' => {
        DESC => 'Count of all advanced relationships links',
        CALC => sub {
            my ($self, $sql) = @_;
            my %r;
            $r{'count.ar.links'} = 0;

            for my $t ($self->c->model('Relationship')->all_pairs) {
                my $table = join('_', 'l', @$t);
                my $n = $sql->select_single_value("SELECT count(*) FROM $table");
                $r{"count.ar.links.$table"} = $n;
                $r{'count.ar.links'} += $n;
            }

            return \%r;
        },
    },

    (
        map {
            my ($l0, $l1) = @$_;
            "count.ar.links.l_${l0}_${l1}" => {
                DESC => "Count of $l0-$l1 advanced relationship links",
                PREREQ => [qw( count.ar.links )],
                PREREQ_ONLY => 1,
            }
        } MusicBrainz::Server::Data::Relationship->all_pairs
    ),

    'count.collection' => {
        DESC => 'Count of all collections',
        SQL => 'SELECT COUNT(*) FROM editor_collection',
    },

    'count.collection.type.release' => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                SELECT type, COUNT(*) AS count
                FROM editor_collection
                GROUP BY type
                SQL

            my %dist = map { @$_ } @$data;

            +{
                'count.collection.type.release' => $dist{1} || 0,
                'count.collection.type.owned'  => $dist{2} || 0,
                'count.collection.type.wishlist'  => $dist{3} || 0,
                'count.collection.type.release.all' => ($dist{1} || 0) + ($dist{2} || 0) + ($dist{3} || 0),
                'count.collection.type.event'  => $dist{4} || 0,
                'count.collection.type.attending'  => $dist{5} || 0,
                'count.collection.type.maybe_attending'  => $dist{6} || 0,
                'count.collection.type.event.all' => ($dist{4} || 0) + ($dist{5} || 0) + ($dist{6} || 0),
                'count.collection.type.area' => $dist{7} || 0,
                'count.collection.type.artist' => $dist{8} || 0,
                'count.collection.type.instrument' => $dist{9} || 0,
                'count.collection.type.label' => $dist{10} || 0,
                'count.collection.type.place' => $dist{11} || 0,
                'count.collection.type.recording' => $dist{12} || 0,
                'count.collection.type.release_group' => $dist{13} || 0,
                'count.collection.type.series' => $dist{14} || 0,
                'count.collection.type.work' => $dist{15} || 0,
            };
        },
    },

    'count.collection.public' => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(<<~'SQL');
                SELECT public, COUNT(*) AS count
                FROM editor_collection
                GROUP BY public
                SQL

            my %dist = map { @$_ } @$data;

            +{
                'count.collection.public' => $dist{1} || 0,
                'count.collection.private'  => $dist{0} || 0,
            };
        },
    },

    'count.collection.has_collaborators' => {
        DESC => 'Count of collections with at least one collaborator',
        SQL => 'SELECT COUNT(DISTINCT collection) FROM editor_collection_collaborator',
    },
);

sub recalculate {
    my ($self, $statistic, $output_file) = @_;

    my $definition = $stats{$statistic}
        or warn("Unknown statistic '$statistic'"), return;

    return if $definition->{PREREQ_ONLY};
    return if $definition->{NONREPLICATED} && DBDefs->REPLICATION_TYPE == RT_MIRROR;
    return if $definition->{PRIVATE} && DBDefs->REPLICATION_TYPE != RT_MASTER;

    my $db = $definition->{DB} || 'READWRITE';
    my $sql = $db eq 'READWRITE' ? $self->sql
            : die "Unknown database: $db";

    if (my $query = $definition->{SQL}) {
        my $value = $sql->select_single_value($query);
                $self->insert($output_file, $statistic => $value);
        return;
    }

    if (my $calculate = $definition->{CALC}) {
        my $output = $calculate->($self, $sql);
        if (ref($output) eq 'HASH')
        {
            $self->insert($output_file, %$output);
        } else {
            $self->insert($output_file, $statistic => $output);
        }
    }
}

sub recalculate_all
{
    my $self = shift;
    my $output_file = shift;

    my %unsatisfiable_prereqs;
    for my $stat (keys %stats) {
        my @errors = grep { !exists $stats{$_} } @{ $stats{$stat}->{PREREQ} // [] }
          or next;

        $unsatisfiable_prereqs{$stat} = \@errors;
    }

    if (%unsatisfiable_prereqs) {
        printf "Statistics cannot be computed due to missing dependencies\n";
        printf "$_ depends on " . join(', ', @{$unsatisfiable_prereqs{$_}}) . ", but these dependencies do not exist\n"
            for keys %unsatisfiable_prereqs;
        exit(1);
    }

    my %notdone = %stats;
    my %done;

    while (1) {
        last unless %notdone;

        my $count = 0;

        # Work out which stats from %notdone we can do this time around
        for my $name (sort keys %notdone) {
            my $d = $stats{$name}{PREREQ} || [];
            next if any { !exists $done{$_} } @$d;

            # $name has no unsatisfied dependencies.  Let's do it!
            $self->recalculate($name, $output_file);

            $done{$name} = delete $notdone{$name};
            ++$count;
        }

        next if $count;

        my $s = join q(, ), keys %notdone;
        die "Failed to solve stats dependencies: circular dependency? ($s)";
    }
}

1;
