package MusicBrainz::Server::Data::Statistics;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use MusicBrainz::Server::Constants qw( :edit_status :vote );
use MusicBrainz::Server::Constants qw( $VARTIST_ID $EDITOR_MODBOT $EDITOR_FREEDB :quality );
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Translation::Statistics qw( l );
use MusicBrainz::Server::Replication ':replication_type';

use DBDefs;

use Fcntl qw(:flock SEEK_END);

with 'MusicBrainz::Server::Data::Role::Sql';

sub _id_cache_prefix { 'stats' }

sub _table { 'statistics.statistic' }

sub all_events {
    my ($self) = @_;

    return [
        map { $_->{title} = l($_->{title}); $_->{description} = l($_->{description}); $_; }
        query_to_list(
            $self->sql,
            sub { shift },
            'SELECT * FROM statistics.statistic_event ORDER BY date ASC',
        )
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
        if(wantarray) {
            return @stats{@names};
        }
        else {
            my $value = $stats{ $names[0] };
            return $value;
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
                { name => $key, value => $updates{$key} }
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
    "editor.top_recently_active" => {
        DESC => "Top recently active editors",
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                "SELECT editor, count(edit.id) FROM edit
                 JOIN editor ON edit.editor = editor.id
                 WHERE status IN (?, ?)
                   AND open_time >= now() - '1 week'::INTERVAL
                   AND cast(privs AS bit(2)) & B'10' = B'00'
                 GROUP BY edit.editor, editor.name
                 ORDER BY count(edit.id) DESC, musicbrainz_collate(editor.name)
                 LIMIT 25",
                $STATUS_OPEN, $STATUS_APPLIED
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_recently_active.rank.$count"} = $editor->[0];
                $map{"count.edit.top_recently_active.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        }
    },
    "editor.top_active" => {
        DESC => "Top active editors",
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                "SELECT id, (edits_accepted + auto_edits_accepted) AS count FROM editor
                 WHERE (edits_accepted + auto_edits_accepted) > 0
                   AND cast(privs AS bit(2)) & B'10' = B'00'
                 ORDER BY (edits_accepted + auto_edits_accepted) DESC, musicbrainz_collate(editor.name)
                 LIMIT 25"
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_active.rank.$count"} = $editor->[0];
                $map{"count.edit.top_active.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        }
    },
    "editor.top_recently_active_voters" => {
        DESC => "Top recently active voters",
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                "SELECT editor, count(vote.id) FROM vote
                 JOIN editor ON vote.editor = editor.id
                 WHERE NOT superseded AND vote != -1
                   AND vote_time >= now() - '1 week'::INTERVAL
                   AND cast(privs AS bit(10)) & 2::bit(10) = 0::bit(10)
                 GROUP BY vote.editor, editor.name
                 ORDER BY count(vote.id) DESC, musicbrainz_collate(editor.name)
                 LIMIT 25"
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_recently_active_voters.rank.$count"} = $editor->[0];
                $map{"count.vote.top_recently_active_voters.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        }
    },
    "editor.top_active_voters" => {
        DESC => "Top active voters",
        CALC => sub {
            my ($self, $sql) = @_;
            my $id_edits = $sql->select_list_of_lists(
                "SELECT editor, count(vote.id) FROM vote
                 JOIN editor ON vote.editor = editor.id
                 WHERE NOT superseded AND vote != -1
                   AND cast(privs AS bit(10)) & 2::bit(10) = 0::bit(10)
                 GROUP BY editor, editor.name
                 ORDER BY count(vote.id) DESC, musicbrainz_collate(editor.name)
                 LIMIT 25"
            );

            my %map;
            my $count = 1;
            foreach my $editor (@$id_edits) {
                $map{"editor.top_active_voters.rank.$count"} = $editor->[0];
                $map{"count.vote.top_active_voters.rank.$count"} = $editor->[1];
                $count++;
            }

            return \%map;
        }
    },
    "count.release" => {
        DESC => "Count of all releases",
        SQL => "SELECT COUNT(*) FROM release",
    },
    "count.releasegroup" => {
        DESC => "Count of all release groups",
        SQL => "SELECT COUNT(*) FROM release_group",
    },
    "count.artist" => {
        DESC => "Count of all artists",
        SQL => "SELECT COUNT(*) FROM artist",
    },
    "count.artist.type.person" => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(type::text, 'null'), COUNT(*) AS count
                FROM artist
                GROUP BY type
                ",
            );

            my %dist = map { @$_ } @$data;
            
            +{
                "count.artist.type.person" => $dist{1} || 0,
                "count.artist.type.group"  => $dist{2} || 0,
                "count.artist.type.other"  => $dist{3} || 0,
                "count.artist.type.null" => $dist{null} || 0
            };
        },
    },
    "count.artist.type.group" => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.type.other" => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.type.null" => {
        PREREQ => [qw[ count.artist.type.person ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.gender.male" => {
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(gender::text, 'null'), COUNT(*) AS count
                FROM artist
                WHERE type IS DISTINCT FROM 2
                GROUP BY gender
                ",
            );

            my %dist = map { @$_ } @$data;
            
            +{
                "count.artist.gender.male" => $dist{1} || 0,
                "count.artist.gender.female"  => $dist{2} || 0,
                "count.artist.gender.other" => $dist{3} || 0,
                "count.artist.gender.null" => $dist{null} || 0
            };
        },
    },
    "count.artist.gender.female" => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.gender.other" => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.gender.null" => {
        PREREQ => [qw[ count.artist.gender.male ]],
        PREREQ_ONLY => 1,
    },
    "count.artist.has_credits" => {
        DESC => "Artists in at least one artist credit",
        SQL => "SELECT COUNT(DISTINCT artist) FROM artist_credit_name",
    },
    "count.artist.0credits" => {
        DESC => "Artists in no artist credits",
        SQL => "SELECT COUNT(DISTINCT artist.id) FROM artist LEFT OUTER JOIN artist_credit_name ON artist.id = artist_credit_name.artist WHERE artist_credit_name.artist_credit IS NULL",
    },
    "count.url" => {
        DESC => 'Count of all URLs',
        SQL => 'SELECT count(*) FROM url',
    },
    "count.coverart" => {
        DESC => 'Count of all cover art images',
        SQL => 'SELECT count(*) FROM cover_art_archive.cover_art',
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.coverart.type" => {
        DESC => "Distribution of cover art by type",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT art_type.name, COUNT(cover_art_type.id) AS count
                 FROM cover_art_archive.cover_art_type
                 JOIN cover_art_archive.art_type ON art_type.id = cover_art_type.type_id
                 GROUP BY art_type.name",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.coverart.type.".$_ => $dist{$_}
                } keys %dist
            };
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.release.status.statname.has_coverart" => {
        DESC => "Count of releases with cover art, by status",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT
                   coalesce(release_status.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 FULL OUTER JOIN release_status
                   ON release_status.id = release.status
                 GROUP BY coalesce(release_status.name, 'null')",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.status.".$_.".has_coverart" => $dist{$_}
                } keys %dist
            };
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.release.type.typename.has_coverart" => {
        DESC => "Count of releases with cover art, by release group type",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT
                   coalesce(release_group_primary_type.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 JOIN release_group
                   ON release.release_group = release_group.id
                 FULL OUTER JOIN release_group_primary_type
                   ON release_group_primary_type.id = release_group.type
                 GROUP BY coalesce(release_group_primary_type.name, 'null')"
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.type.".$_.".has_coverart" => $dist{$_}
                } keys %dist
            };
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.release.format.fname.has_coverart" => {
        DESC => "Count of releases with cover art, by medium format",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT
                   coalesce(medium_format.name, 'null'),
                   count(DISTINCT cover_art.release)
                 FROM cover_art_archive.cover_art
                 JOIN release ON release.id = cover_art.release
                 JOIN medium ON medium.release = release.id
                 FULL OUTER JOIN medium_format
                   ON medium_format.id = medium.format
                 GROUP BY coalesce(medium_format.name, 'null')",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.format.".$_.".has_coverart" => $dist{$_}
                } keys %dist
            };
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.coverart.per_release.Nimages" => {
        DESC => "Distribution of cover art images per release",
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 30;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT release, COUNT(*) AS c
                    FROM cover_art_archive.cover_art
                    GROUP BY release
                ) AS t
                GROUP BY c
                ",
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
                    "count.coverart.per_release.".$_."images" => $dist{$_}
                } keys %dist
            };
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },

    "count.label" => {
        DESC => "Count of all labels",
        SQL => "SELECT COUNT(*) FROM label",
    },
    "count.discid" => {
        DESC => "Count of all disc IDs",
        SQL => "SELECT COUNT(*) FROM cdtoc",
    },
    "count.edit" => {
        DESC => "Count of all edits",
        SQL => "SELECT COUNT(*) FROM edit",
        NONREPLICATED => 1,
    },
    "count.editor" => {
        DESC => "Count of all editors",
        SQL => "SELECT COUNT(*) FROM editor",
        NONREPLICATED => 1,
    },
    "count.barcode" => {
        DESC => "Count of all unique Barcodes",
        SQL => "SELECT COUNT(distinct barcode) FROM release",
    },
    "count.medium" => {
        DESC => "Count of all mediums",
        SQL => "SELECT COUNT(*) FROM medium",
    },
    "count.puid" => {
        DESC => "Count of all PUIDs joined to recordings",
        SQL => "SELECT COUNT(*) FROM recording_puid",
    },
    "count.puid.ids" => {
        DESC => "Count of unique PUIDs",
        SQL => "SELECT COUNT(DISTINCT puid) FROM recording_puid",
    },
    "count.track" => {
        DESC => "Count of all tracks",
        SQL => "SELECT COUNT(*) FROM track",
    },
    "count.recording" => {
        DESC => "Count of all recordings",
        SQL => "SELECT COUNT(*) FROM recording",
    },
    "count.work" => {
        DESC => "Count of all works",
        SQL => "SELECT COUNT(*) FROM work",
    },
    "count.work.has_iswc" => {
        DESC => "Count of all works with at least one ISWC",
        SQL => "SELECT COUNT(DISTINCT work) FROM iswc",
    },
    "count.work.language" => {
        DESC => "Distribution of works by lyrics language",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(l.iso_code_3::text, 'null'), COUNT(w.gid) AS count
                FROM work w FULL OUTER JOIN language l
                    ON w.language=l.id
                WHERE l.iso_code_2t IS NOT NULL OR l.frequency > 0
                GROUP BY l.iso_code_3
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.work.language.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.work.type" => {
        DESC => "Distribution of works by type",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(type.id::text, 'null'), COUNT(work.id) AS count
                 FROM work_type type
                 FULL OUTER JOIN work ON work.type = type.id
                 GROUP BY type.id",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.work.type.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.artistcredit" => {
        DESC => "Count of all artist credits",
        SQL => "SELECT COUNT(*) FROM artist_credit",
    },
    "count.ipi" => {
        DESC => "Count of IPI codes",
        PREREQ => [qw[ count.ipi.artist count.ipi.label ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch("count.ipi.artist") + $self->fetch("count.ipi.label");
        },
    },
    "count.ipi.artist" => {
        DESC => "Count of artists with an IPI code",
        SQL => "SELECT COUNT(DISTINCT artist) FROM artist_ipi",
    },
    "count.ipi.label" => {
        DESC => "Count of labels with an IPI code",
        SQL => "SELECT COUNT(DISTINCT label) FROM label_ipi",
    },
    "count.isrc.all" => {
        DESC => "Count of all ISRCs joined to recordings",
        SQL => "SELECT COUNT(*) FROM isrc",
    },
    "count.isrc" => {
        DESC => "Count of unique ISRCs",
        SQL => "SELECT COUNT(distinct isrc) FROM isrc",
    },
    "count.iswc.all" => {
        DESC => "Count of all ISWCs",
        SQL => "SELECT COUNT(*) FROM iswc",
    },
    "count.iswc" => {
        DESC => "Count of unique ISWCs",
        SQL => "SELECT COUNT(distinct iswc) FROM iswc",
    },
    "count.vote" => {
        DESC => "Count of all votes",
        SQL => "SELECT COUNT(*) FROM vote",
        NONREPLICATED => 1,
    },

    "count.label.country" => {
        DESC => "Distribution of labels per country",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(c.iso_code::text, 'null'), COUNT(l.gid) AS count
                FROM label l FULL OUTER JOIN country c
                    ON l.country=c.id
                GROUP BY c.iso_code
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.label.country.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.release.country" => {
        DESC => "Distribution of releases per country",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(c.iso_code::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN country c
                    ON r.country=c.id
                GROUP BY c.iso_code
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.country.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.release.format" => {
         DESC => "Distribution of releases by format",
         CALC => sub { 
             my ($self, $sql) = @_;
             my $data = $sql->select_list_of_lists(
                 "SELECT COALESCE(medium_format.id::text, 'null'), count(DISTINCT medium.release) AS count
                 FROM medium FULL OUTER JOIN medium_format 
                     ON medium.format = medium_format.id 
                 GROUP BY medium_format.id
                 ",
             );

             my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.format.".$_ => $dist{$_}
                } keys %dist
            };
         },
    },
    "count.medium.format" => {
         DESC => "Distribution of mediums by format",
         CALC => sub { 
             my ($self, $sql) = @_;
             my $data = $sql->select_list_of_lists(
                 "SELECT COALESCE(medium_format.id::text, 'null'), count(DISTINCT medium.id) AS count
                 FROM medium FULL OUTER JOIN medium_format 
                     ON medium.format = medium_format.id 
                 GROUP BY medium_format.id
                 ",
             );

             my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.medium.format.".$_ => $dist{$_}
                } keys %dist
            };
         },
    },
    "count.release.language" => {
        DESC => "Distribution of releases by language",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(l.iso_code_3::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN language l
                    ON r.language=l.id
                WHERE l.iso_code_2t IS NOT NULL OR l.frequency > 0
                GROUP BY l.iso_code_3
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.language.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.release.script" => {
        DESC => "Distribution of releases by script",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(s.iso_code::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN script s
                    ON r.script=s.id
                GROUP BY s.iso_code
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.script.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.release.status" => {
        DESC => "Distribution of releases by status",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(s.id::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN release_status s
                    ON r.status=s.id
                GROUP BY s.id
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.status.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.release.packaging" => {
        DESC => "Distribution of releases by packaging",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(p.id::text, 'null'), COUNT(r.gid) AS count
                FROM release r FULL OUTER JOIN release_packaging p
                    ON r.packaging=p.id
                GROUP BY p.id
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.release.packaging.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.releasegroup.Nreleases" => {
        DESC => "Distribution of releases per releasegroup",
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT release_count, COUNT(*) AS freq
                FROM release_group_meta
                GROUP BY release_count
                ",
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
                    "count.releasegroup.".$_."releases" => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.releasegroup.primary_type" => {
        DESC => "Distribution of release groups by primary type",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT type.id, COUNT(rg.id) AS count
                 FROM release_group_primary_type type
                 LEFT JOIN release_group rg on rg.type = type.id
                 GROUP BY type.id",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.releasegroup.primary_type.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.releasegroup.secondary_type" => {
        DESC => "Distribution of release groups by secondary type",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT type.id, COUNT(rg.id) AS count
                 FROM release_group_secondary_type type
                 LEFT JOIN release_group_secondary_type_join type_join 
                     ON type.id = type_join.secondary_type
                 JOIN release_group rg on rg.id = type_join.release_group
                 GROUP BY type.id",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.releasegroup.secondary_type.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },
    "count.release.various" => {
        DESC => "Count of all 'Various Artists' releases",
        SQL => 'SELECT COUNT(*) FROM release
                  JOIN artist_credit ac ON ac.id = artist_credit
                  JOIN artist_credit_name acn ON acn.artist_credit = ac.id
                 WHERE artist_count = 1 AND artist = ' . $VARTIST_ID,
    },
    "count.release.nonvarious" => {
        DESC => "Count of all releases, other than 'Various Artists'",
        PREREQ => [qw[ count.release count.release.various ]],
        CALC => sub {
            my ($self, $sql) = @_;

            $self->fetch("count.release")
                - $self->fetch("count.release.various")
        },
    },
    "count.medium.has_discid" => {
        DESC => "Count of media with at least one disc ID",
        SQL => "SELECT COUNT(DISTINCT medium)
                  FROM medium_cdtoc",
    },
    "count.release.has_discid" => {
        DESC => "Count of releases with at least one disc ID",
        SQL => "SELECT COUNT(DISTINCT medium.release)
                  FROM medium_cdtoc
                  JOIN medium ON medium_cdtoc.medium = medium.id",
    },
    "count.release.has_caa" => {
        DESC => 'Count of releases that have cover art at the Cover Art Archive',
        SQL => 'SELECT count(DISTINCT release) FROM cover_art_archive.cover_art',
        NONREPLICATED => 1,
        PRIVATE => 1,
    },

    "count.recording.has_isrc" => {
        DESC => "Count of recordings with at least one ISRC",
        SQL => "SELECT COUNT(DISTINCT recording) FROM isrc",
    },
    "count.recording.has_puid" => {
        DESC => "Count of recordings with at least one PUID",
        SQL => "SELECT COUNT(DISTINCT recording) FROM recording_puid",
    },

    "count.edit.open" => {
        DESC => "Count of open edits",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT status, COUNT(*) FROM edit GROUP BY status",
            );

            my %dist = map { @$_ } @$data;

            +{
                "count.edit.open"           => $dist{$STATUS_OPEN}          || 0,
                "count.edit.applied"        => $dist{$STATUS_APPLIED}       || 0,
                "count.edit.failedvote" => $dist{$STATUS_FAILEDVOTE}    || 0,
                "count.edit.faileddep"  => $dist{$STATUS_FAILEDDEP}     || 0,
                "count.edit.error"      => $dist{$STATUS_ERROR}         || 0,
                "count.edit.failedprereq"   => $dist{$STATUS_FAILEDPREREQ}  || 0,
                "count.edit.evalnochange"   => 0,
                "count.edit.deleted"        => $dist{$STATUS_DELETED}       || 0,
            };
        },
        NONREPLICATED => 1,
    },
    "count.edit.applied" => {
        DESC => "Count of applied edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.failedvote" => {
        DESC => "Count of edits which were voted down",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.faileddep" => {
        DESC => "Count of edits which failed their dependency check",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.error" => {
        DESC => "Count of edits which failed because of an internal error",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.failedprereq" => {
        DESC => "Count of edits which failed because a prerequisitite moderation failed",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.evalnochange" => {
        DESC => "Count of evalnochange edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.deleted" => {
        DESC => "Count of deleted edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.edit.perday" => {
        DESC => "Count of edits per day",
        SQL => "SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '1 day')
                  AND editor NOT IN (". $EDITOR_FREEDB .", ". $EDITOR_MODBOT .")",
        NONREPLICATED => 1,
    },
    "count.edit.perweek" => {
        DESC => "Count of edits per week",
        SQL => "SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '7 days')
                  AND editor NOT IN (". $EDITOR_FREEDB .", ". $EDITOR_MODBOT .")",
        NONREPLICATED => 1,
    },
    "count.edit.type" => {
	DESC => "Count of edits by type",
        CALC => sub {
            my ($self, $sql) = @_;

	    my $data = $sql->select_list_of_lists(
                "SELECT type, count(id) AS count 
		FROM edit GROUP BY type",
	    );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.edit.type.".$_ => $dist{$_}
                } keys %dist
            };
	}
    },

    "count.cdstub" => {
        DESC => "Count of all existing CD Stubs",
        SQL => "SELECT COUNT(*) FROM release_raw",
        NONREPLICATED => 1,
    },
    "count.cdstub.submitted" => {
        DESC => "Count of all submitted CD Stubs",
        SQL => "SELECT MAX(id) FROM release_raw",
        NONREPLICATED => 1,
    },
    "count.cdstub.track" => {
        DESC => "Count of all CD Stub tracks",
        SQL => "SELECT COUNT(*) FROM track_raw",
        NONREPLICATED => 1,
    },

    "count.artist.country" => {
        DESC => "Distribution of artists per country",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT COALESCE(c.iso_code::text, 'null'), COUNT(a.gid) AS count
                FROM artist a FULL OUTER JOIN country c
                    ON a.country=c.id
                GROUP BY c.iso_code
                ",
            );

            my %dist = map { @$_ } @$data;

            +{
                map {
                    "count.artist.country.".$_ => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.vote.yes" => {
        DESC => "Count of 'yes' votes",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT vote, COUNT(*) FROM vote GROUP BY vote",
            );

            my %dist = map { @$_ } @$data;

            +{
                "count.vote.yes"        => $dist{$VOTE_YES} || 0,
                "count.vote.no"         => $dist{$VOTE_NO}  || 0,
                "count.vote.abstain"    => $dist{$VOTE_ABSTAIN} || 0,
                "count.vote.approve"    => $dist{$VOTE_APPROVE} || 0,
            };
        },
        NONREPLICATED => 1,
    },
    "count.vote.no" => {
        DESC => "Count of 'no' votes",
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.vote.abstain" => {
        DESC => "Count of 'abstain' votes",
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.vote.approve" => {
        DESC => "Count of auto-editor approvals",
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.vote.perday" => {
        DESC => "Count of votes per day",
        SQL => "SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '1 day')
                  AND vote <> ". $VOTE_ABSTAIN,
        NONREPLICATED => 1,
    },
    "count.vote.perweek" => {
        DESC => "Count of votes per week",
        SQL => "SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '7 days')
                  AND vote <> ". $VOTE_ABSTAIN,
        NONREPLICATED => 1,
    },

    # count active moderators in last week(?)
    # editing / voting / overall

    "count.editor.editlastweek" => {
        DESC => "Count of editors who have submitted edits during the last week",
        CALC => sub {
            my ($self, $sql) = @_;

            my $threshold_id = $sql->select_single_value(
                "SELECT MAX(id) FROM edit
                WHERE open_time <= (now() - interval '7 days')",
            );

            # Active voters
            my $voters = $sql->select_single_value(
                "SELECT COUNT(DISTINCT editor)
                FROM vote
                WHERE edit > ?
                AND editor != ?",
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Editors
            my $editors = $sql->select_single_value(
                "SELECT COUNT(DISTINCT editor)
                FROM edit
                WHERE id > ?
                AND editor != ?",
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Either
            my $both = $sql->select_single_value(
                "SELECT COUNT(DISTINCT m) FROM (
                    SELECT editor AS m
                    FROM edit
                    WHERE id > ?
                    UNION
                    SELECT editor AS m
                    FROM vote
                    WHERE edit > ?
                ) t WHERE m != ?",
                $threshold_id,
                $threshold_id,
                $EDITOR_FREEDB,
            );
            
            +{
                "count.editor.editlastweek" => $editors,
                "count.editor.votelastweek" => $voters,
                "count.editor.activelastweek"=> $both,
            };
        },
        NONREPLICATED => 1,
    },
    "count.editor.votelastweek" => {
        DESC => "Count of editors who have voted on edits during the last week",
        PREREQ => [qw[ count.editor.editlastweek ]],
        PREREQ_ONLY => 1,
        NONREPLICATED => 1,
    },
    "count.editor.activelastweek" => {
        DESC => "Count of active editors (editing or voting) during the last week",
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
    "count.tag" => {
        DESC => "Count of all tags",
        SQL => "SELECT COUNT(*) FROM tag",
    },
    "count.tag.raw.artist" => {
        DESC => "Count of all artist raw tags",
        SQL => "SELECT COUNT(*) FROM artist_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw.label" => {
        DESC => "Count of all label raw tags",
        SQL => "SELECT COUNT(*) FROM label_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw.releasegroup" => {
        DESC => "Count of all release-group raw tags",
        SQL => "SELECT COUNT(*) FROM release_group_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw.release" => {
        DESC => "Count of all release raw tags",
        SQL => "SELECT COUNT(*) FROM release_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw.recording" => {
        DESC => "Count of all recording raw tags",
        SQL => "SELECT COUNT(*) FROM recording_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw.work" => {
        DESC => "Count of all work raw tags",
        SQL => "SELECT COUNT(*) FROM work_tag_raw",
        NONREPLICATED => 1,
        PRIVATE => 1,
    },
    "count.tag.raw" => {
        DESC => "Count of all raw tags",
        PREREQ => [qw[ count.tag.raw.artist count.tag.raw.label count.tag.raw.release count.tag.raw.releasegroup count.tag.raw.recording count.tag.raw.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.tag.raw.artist') + 
                   $self->fetch('count.tag.raw.label') +
                   $self->fetch('count.tag.raw.release') +
                   $self->fetch('count.tag.raw.releasegroup') +
                   $self->fetch('count.tag.raw.work') +
                   $self->fetch('count.tag.raw.recording');
        },
        NONREPLICATED => 1,
        PRIVATE => 1,
    },

    # Ratings
    "count.rating.artist" => {
        DESC => "Count of artist ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM artist_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.artist"       => $data->[0]   || 0,
                "count.rating.raw.artist"   => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.artist" => {
        DESC => "Count of all artist raw ratings",
        PREREQ => [qw[ count.rating.artist ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.releasegroup" => {
        DESC => "Count of release group ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM release_group_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.releasegroup"     => $data->[0]   || 0,
                "count.rating.raw.releasegroup" => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.releasegroup" => {
        DESC => "Count of all release group raw ratings",
        PREREQ => [qw[ count.rating.releasegroup ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.recording" => {
        DESC => "Count of recording ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM recording_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.recording"        => $data->[0]   || 0,
                "count.rating.raw.recording"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.recording" => {
        DESC => "Count of all recording raw ratings",
        PREREQ => [qw[ count.rating.track ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.label" => {
        DESC => "Count of label ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM label_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.label"        => $data->[0]   || 0,
                "count.rating.raw.label"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.label" => {
        DESC => "Count of all label raw ratings",
        PREREQ => [qw[ count.rating.label ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.work" => {
        DESC => "Count of work ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM work_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.work"        => $data->[0]   || 0,
                "count.rating.raw.work"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.work" => {
        DESC => "Count of all work raw ratings",
        PREREQ => [qw[ count.rating.work ]],
        PREREQ_ONLY => 1,
    },
    "count.rating" => {
        DESC => "Count of all ratings",
        PREREQ => [qw[ count.rating.artist count.rating.label count.rating.releasegroup count.rating.recording count.rating.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.artist') + 
                   $self->fetch('count.rating.label') +
                   $self->fetch('count.rating.releasegroup') +
                   $self->fetch('count.rating.work') +
                   $self->fetch('count.rating.recording');
        },
    },
    "count.rating.raw" => {
        DESC => "Count of all raw ratings",
        PREREQ => [qw[ count.rating.raw.artist count.rating.raw.label count.rating.raw.releasegroup count.rating.raw.recording count.rating.raw.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.raw.artist') + 
                   $self->fetch('count.rating.raw.label') +
                   $self->fetch('count.rating.raw.releasegroup') +
                   $self->fetch('count.rating.raw.work') +
                   $self->fetch('count.rating.raw.recording');
        },
    },

    "count.release.Ndiscids" => {
        DESC => "Distribution of disc IDs per release (varying disc IDs)",
        PREREQ => [qw[ count.release count.release.has_discid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT medium.release, COUNT(*) AS c
                    FROM medium_cdtoc
                    JOIN medium ON medium_cdtoc.medium = medium.id
                    GROUP BY medium.release
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch("count.release")
                - $self->fetch("count.release.has_discid");

            +{
                map {
                    "count.release.".$_."discids" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.medium.Ndiscids" => {
        DESC => "Distribution of disc IDs per medium (varying disc IDs)",
        PREREQ => [qw[ count.medium count.medium.has_discid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT medium, COUNT(*) AS c
                    FROM medium_cdtoc
                    GROUP BY medium
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch("count.medium")
                - $self->fetch("count.medium.has_discid");

            +{
                map {
                    "count.medium.".$_."discids" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.quality.release.high" => {
        DESC => "Count of high quality releases",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT quality, COUNT(*) FROM release GROUP BY quality",
            );

            my %dist = map { @$_ } @$data;
            +{
                "count.quality.release.high"        => $dist{$QUALITY_HIGH} || 0,
                "count.quality.release.low"     => $dist{$QUALITY_LOW}      || 0,
                "count.quality.release.normal"  => $dist{$QUALITY_NORMAL}   || 0,
                "count.quality.release.unknown" => $dist{$QUALITY_UNKNOWN}  || 0,
                "count.quality.release.default" => ($dist{$QUALITY_UNKNOWN} || 0) + ($dist{$QUALITY_NORMAL} || 0),
            };
        },
    },
    "count.quality.release.low" => {
        DESC => "Count of low quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    "count.quality.release.normal" => {
        DESC => "Count of normal quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    "count.quality.release.unknown" => {
        DESC => "Count of unknow quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    "count.quality.release.default" => {
        DESC => "Count of default quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },

    "count.puid.Nrecordings" => {
        DESC => "Distribution of recordings per PUID (collisions)",
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT puid, COUNT(*) AS c
                    FROM recording_puid
                    GROUP BY puid
                ) AS t
                GROUP BY c
                ",
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
                    "count.puid.".$_."recordings" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.recording.Npuids" => {
        DESC => "Distribution of PUIDs per recording (varying PUIDs)",
        PREREQ => [qw[ count.recording count.recording.has_puid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT recording, COUNT(*) AS c
                    FROM recording_puid
                    GROUP BY recording
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch("count.recording")
                - $self->fetch("count.recording.has_puid");
            
            +{
                map {
                    "count.recording.".$_."puids" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.recording.Nreleases" => {
        DESC => "Distribution of appearances on releases per recording",
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT r.id, count(distinct release.id) as c
                        FROM recording r 
                        LEFT JOIN track t ON t.recording = r.id 
                        LEFT JOIN tracklist tl ON tl.id = t.tracklist 
                        LEFT JOIN medium m ON tl.id = m.tracklist 
                        LEFT JOIN release on m.release = release.id 
                    GROUP BY r.id
                ) AS t
                GROUP BY c
                ",
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
                    "count.recording.".$_."releases" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.ar.links.table.type_name" => {
        DESC => "Count of advanced relationship links by type, inclusive of child counts and exclusive",
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
                     GROUP BY lt.name, lt.id, lt.parent", @$t
                );
                for (@$data) {
                    $dist{ $table . '.' . $_->{name} } = $_->{count};
                    $dist{ $table . '.' . $_->{name} . '.inclusive' } = $_->{count};
                }
                for (@$data) {
                    my $parent = $_->{parent};
                    my $count = $_->{count};
                    while (defined $parent) {
                        my @parent_obj = grep { $_->{id} == $parent } @$data;
                        my $parent_obj = $parent_obj[0] if scalar(@parent_obj) == 1;
                        die unless $parent_obj;

                        $dist{ $table . '.' . $parent_obj->{name} . '.inclusive' } += $count;

                        $parent = $parent_obj->{parent};
                    }
                }
            }

            +{
                map {
                    "count.ar.links.".$_ => $dist{$_}
                } keys %dist
            };
        }
    },

    "count.ar.links" => {
        DESC => "Count of all advanced relationships links",
        CALC => sub {
            my ($self, $sql) = @_;
            my %r;
            $r{'count.ar.links'} = 0;

            for my $t ($self->c->model('Relationship')->all_pairs) {
                my $table = join('_', 'l', @$t);
                my $n = $sql->select_single_value(
                    "SELECT count(*) FROM $table");
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
                PREREQ_ONLY => 1
            }
        } MusicBrainz::Server::Data::Relationship->all_pairs
    )
);

sub recalculate {
    my ($self, $statistic, $output_file) = @_;

    my $definition = $stats{$statistic}
        or warn("Unknown statistic '$statistic'"), return;

    return if $definition->{PREREQ_ONLY};
    return if $definition->{NONREPLICATED} && &DBDefs::REPLICATION_TYPE == RT_SLAVE;
    return if $definition->{PRIVATE} && &DBDefs::REPLICATION_TYPE != RT_MASTER;

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
        if (ref($output) eq "HASH")
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

    my %notdone = %stats;
    my %done;

    while (1) {
        last unless %notdone;

        my $count = 0;

        # Work out which stats from %notdone we can do this time around
        for my $name (sort keys %notdone) {
            my $d = $stats{$name}{PREREQ} || [];
            next if grep { $notdone{$_} } @$d;

            # $name has no unsatisfied dependencies.  Let's do it!
            $self->recalculate($name, $output_file);

            $done{$name} = delete $notdone{$name};
            ++$count;
        }

        next if $count;

        my $s = join ", ", keys %notdone;
        die "Failed to solve stats dependencies: circular dependency? ($s)";
    }
}

1;
