package MusicBrainz::Server::Data::Release;

use Moose;
use namespace::autoclean -also => [qw( _where_status_in _where_type_in )];

use Carp 'confess';
use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_partial_date
    order_by
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Log qw( log_debug );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'release_name' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::BrowseVA';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'release' };

use Readonly;
Readonly our $MERGE_APPEND => 1;
Readonly our $MERGE_MERGE => 2;

sub _table
{
    return 'release JOIN release_name name ON release.name=name.id';
}

sub _columns
{
    return 'release.id, release.gid, name.name, release.artist_credit AS artist_credit_id,
            release.release_group, release.status, release.packaging,
            release.date_year, release.date_month, release.date_day,
            release.country, release.comment, release.edits_pending, release.barcode,
            release.script, release.language, release.quality, release.last_updated';
}

sub _id_column
{
    return 'release.id';
}

sub _gid_redirect_table
{
    return 'release_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        artist_credit_id => 'artist_credit_id',
        release_group_id => 'release_group',
        status_id => 'status',
        packaging_id => 'packaging',
        country_id => 'country',
        date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        barcode => sub { MusicBrainz::Server::Entity::Barcode->new_from_row(shift, shift) },
        script_id => 'script',
        language_id => 'language',
        quality => sub {
            my ($row, $prefix) = @_;
            my $quality = $row->{"${prefix}quality"};
            $quality = $QUALITY_UNKNOWN unless defined($quality);
            return $quality == $QUALITY_UNKNOWN ? $QUALITY_UNKNOWN_MAPPED : $quality;
        },
        last_updated => 'last_updated'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Release';
}

sub _where_filter
{
    my ($filter) = @_;

    my (@query, @joins, @params);

    if (defined $filter) {
        if (exists $filter->{name}) {
            push @query, "(to_tsvector('mb_simple', name.name) @@ plainto_tsquery('mb_simple', ?) OR name.name = ?)";
            push @params, $filter->{name}, $filter->{name};
        }
        if (exists $filter->{artist_credit_id}) {
            push @query, "release.artist_credit = ?";
            push @params, $filter->{artist_credit_id};
        }
        if (exists $filter->{status} && $filter->{status}) {
            my @statuses = ref($filter->{status}) ? @{ $filter->{status} } : ( $filter->{status} );
            if (@statuses) {
                push @query, 'status IN (' . placeholders(@statuses) . ')';
                push @params, @statuses;
            }
        }
        if (exists $filter->{type} && $filter->{type}) {
            my @types = ref($filter->{type}) ? @{ $filter->{type} } : ( $filter->{type} );
            my %partitioned_types = partition_by {
                "$_" =~ /^st:/ ? 'secondary' : 'primary'
            } @types;

            if (my $primary = $partitioned_types{primary}) {
                push @query, 'release_group.type = any(?)';
                push @joins, 'JOIN release_group ON release.release_group = release_group.id';
                push @params, $primary;
            }

            if (my $secondary = $partitioned_types{secondary}) {
                push @query, 'st.secondary_type = any(?)';
                push @params, [ map { substr($_, 3) } @$secondary ];
                push @joins, 'JOIN release_group_secondary_type_join st ON release.release_group = st.release_group';
            }
        }
    }

    return (\@query, \@joins, \@params);
}

sub load
{
    my ($self, @objs) = @_;
    return load_subobjects($self, 'release', @objs);
}

sub find_artist_credits_by_artist
{
    my ($self, $artist_id) = @_;

    my $query = "SELECT DISTINCT rel.artist_credit
                 FROM release rel
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rel.artist_credit
                 WHERE acn.artist = ?";
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->c->model('ArtistCredit')->find_by_ids($ids);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "acn.artist = ?";
    push @$params, $artist_id;

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                        country.name AS country_name,
                        musicbrainz_collate(name.name) AS name_collate
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                     " . join(' ', @$extra_joins) . "
                     LEFT JOIN country ON release.country = country.id
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY date_year, date_month, date_day,
                          country.name, barcode, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @$params, $offset || 0);
}

sub find_by_label
{
    my ($self, $label_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "release_label.label = ?";
    push @$params, $label_id;

    my $query =
        "SELECT * FROM (
           SELECT DISTINCT ON (release.id) " . $self->_columns . " 
             , country.name AS country_name, catalog_number
           FROM " . $self->_table . "
           JOIN release_label
             ON release_label.release = release.id
           " . join(' ', @$extra_joins) . "
           LEFT JOIN country ON release.country = country.id
           WHERE " . join(" AND ", @$conditions) . "
         ) s
         ORDER BY date_year, date_month, date_day, catalog_number,
                  musicbrainz_collate(name), country_name,
                  barcode
         OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @$params, $offset || 0);
}

sub find_by_disc_id
{
    my ($self, $disc_id) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN medium ON medium.release = release.id
                     JOIN medium_cdtoc ON medium_cdtoc.medium = medium.id
                     JOIN cdtoc ON medium_cdtoc.cdtoc = cdtoc.id
                 WHERE cdtoc.discid = ?
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $disc_id);
}

sub find_by_release_group
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "release_group IN (" . placeholders(@ids) . ")";
    push @$params, @ids;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 " . join(' ', @$extra_joins) . "
                 LEFT JOIN country ON release.country = country.id
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY date_year, date_month, date_day,
                          country.name, barcode
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @$params, $offset || 0);
}

sub find_by_track_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "
        release.id IN (
            SELECT release FROM medium
                JOIN track tr
                ON tr.tracklist = medium.tracklist
                JOIN artist_credit_name acn
                ON acn.artist_credit = tr.artist_credit
            WHERE acn.artist = ?)
        AND release.id NOT IN (
            SELECT id FROM release
              JOIN artist_credit_name acn
                ON release.artist_credit = acn.artist_credit
             WHERE acn.artist = ?)";
    push @$params, $artist_id, $artist_id;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 " . join(' ', @$extra_joins) . "
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @$params, $offset || 0);
}

sub find_for_various_artists
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

	my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "
        acn.artist != ?
        AND release.id IN (
            SELECT release FROM medium
                JOIN track tr
                ON tr.tracklist = medium.tracklist
                JOIN artist_credit_name acn
                ON acn.artist_credit = tr.artist_credit
            WHERE acn.artist = ?)";
    push @$params, $artist_id, $artist_id;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                     " . join(' ', @$extra_joins) . "
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @$params, $offset || 0);
}

sub find_by_recording
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "track.recording IN (" . placeholders(@ids) . ")";
    push @$params, @ids;

    my $query = "SELECT DISTINCT ON (release.id) " . $self->_columns . "
                 FROM " . $self->_table . "
                     " . join(' ', @$extra_joins) . "
                     JOIN medium ON medium.release = release.id
                     JOIN track ON track.tracklist = medium.tracklist
                 WHERE " . join(" AND ", @$conditions) . "
                 ORDER BY release.id, date_year, date_month, date_day, musicbrainz_collate(name.name)
                 OFFSET ?";

    if (!defined $limit) {
        return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                             $query, @$params, $offset || 0);
    }
    else {
        return query_to_list_limited(
            $self->c->sql, $offset, $limit || 25, sub { $self->_new_from_row(@_) },
            $query, @$params, $offset || 0);
    }
}

sub find_by_recordings
{
    my ($self, @ids) = @_;
    return () unless @ids;

    my $query =
        "SELECT DISTINCT ON (release.id) " . $self->_columns . ",
                track.recording, track.position
           FROM release
           JOIN release_name name ON name.id = release.name
           JOIN medium ON release.id = medium.release
           JOIN track ON track.tracklist = medium.tracklist
          WHERE track.recording IN (" . placeholders(@ids) . ")";

    my %map;
    $self->sql->select($query, @ids);
    while (my $row = $self->sql->next_row_hash_ref) {
        $map{ $row->{recording} } ||= [];
        push @{ $map{ $row->{recording} } },
            [ $self->_new_from_row($row),
              $self->c->model('Track')->_new_from_row({
                  position => $row->{position}
              }) ];
    }

    return %map;
}

sub find_for_cdtoc
{
    my ($self, $artist_id, $track_count, $limit, $offset) = @_;

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                        musicbrainz_collate(name.name) AS name_collate,
                        release_group.id AS rg_id
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = release.artist_credit
                     JOIN medium
                        ON medium.release = release.id
                     LEFT JOIN medium_format
                        ON medium_format.id = medium.format
                     JOIN tracklist
                        ON medium.tracklist = tracklist.id
                     JOIN release_group
                        ON release.release_group = release_group.id
                 WHERE tracklist.track_count = ? AND acn.artist = ?
                   AND (medium_format.id IS NULL OR medium_format.has_discids)
                 ORDER BY release_group.id, musicbrainz_collate(name.name), date_year, date_month, date_day
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $track_count, $artist_id, $offset || 0);
}

sub load_with_tracklist_for_recording
{
    my ($self, $recording_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "track.recording = ?";
    push @$params, $recording_id;

    my $query = "
        SELECT
            release.id AS r_id, release.gid AS r_gid, release_name.name AS r_name,
                release.artist_credit AS r_artist_credit_id,
                release.date_year AS r_date_year,
                release.date_month AS r_date_month,
                release.date_day AS r_date_day,
                release.country AS r_country, release.status AS r_status,
                release.packaging AS r_packaging,
                release.quality AS r_quality,
                release.release_group AS r_release_group,
                release.comment AS r_comment,
            medium.id AS m_id, medium.format AS m_format,
                medium.position AS m_position, medium.name AS m_name,
                medium.tracklist AS m_tracklist,
                tracklist.track_count AS m_track_count,
            track.id AS t_id, track_name.name AS t_name,
                track.tracklist AS t_tracklist, track.position AS t_position,
                track.length AS t_length, track.artist_credit AS t_artist_credit,
                track.number AS t_number
        FROM
            track
            JOIN tracklist ON tracklist.id = track.tracklist
            JOIN medium ON medium.tracklist = tracklist.id
            JOIN release ON release.id = medium.release
            JOIN release_name ON release.name = release_name.id
            JOIN track_name ON track.name = track_name.id
            " . join(' ', @$extra_joins) . "
       WHERE " . join(" AND ", @$conditions) . "
       ORDER BY date_year, date_month, date_day, musicbrainz_collate(release_name.name)
       OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = shift;
            my $track = MusicBrainz::Server::Data::Track->_new_from_row($row, 't_');
            my $medium = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');
            my $tracklist = $medium->tracklist;
            my $release = $self->_new_from_row($row, 'r_');

            push @{ $release->mediums }, $medium;
            push @{ $tracklist->tracks }, $track;

            return $release;
        },
        $query, @$params, $offset || 0);
}

sub find_by_puid
{
    my ($self, $ids) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                      JOIN track ON track.tracklist = medium.tracklist
                      JOIN recording ON recording.id = track.recording
                      JOIN recording_puid ON recording_puid.recording = recording.id
                      JOIN puid ON puid.id = recording_puid.puid
                     WHERE puid.puid IN (' . placeholders(@ids) . ')
                )';
    return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                         $query, @{ids});
}

sub find_by_tracklist
{
    my ($self, $tracklist_id) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' JOIN medium ON medium.release = release.id ' .
                ' WHERE medium.tracklist = ?';
    return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                         $query, $tracklist_id);
}

sub find_by_medium
{
    my ($self, $ids, $limit, $offset) = @_;
    my @ids = ref $ids ? @$ids : ( $ids )
        or return ();
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                     WHERE medium.id IN (' . placeholders(@ids) . ')
                )
                OFFSET ?';
    return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                         $query, @{ids}, $offset || 0);
}

sub find_by_collection
{
    my ($self, $collection_id, $limit, $offset, $order) = @_;

    my $extra_join = "";
    my $order_by = order_by($order, "date", {
        "date"   => "date_year, date_month, date_day, musicbrainz_collate(name.name)",
        "title"  => "musicbrainz_collate(name.name), date_year, date_month, date_day",
        "artist" => sub {
            $extra_join = "JOIN artist_credit ac ON ac.id = release.artist_credit
                           JOIN artist_name ac_name ON ac_name.id=ac.name";
            return "musicbrainz_collate(ac_name.name), date_year, date_month, date_day, musicbrainz_collate(name.name)";
        },
    });

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_collection_release cr
                        ON release.id = cr.release
                    $extra_join
                 WHERE cr.collection = ?
                 ORDER BY $order_by
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $collection_id, $offset || 0);
}

sub insert
{
    my ($self, @releases) = @_;
    my @created;
    my %names = $self->find_or_insert_names(map { $_->{name} } @releases);
    my $class = $self->_entity_class;
    for my $release (@releases)
    {
        my $row = $self->_hash_to_row($release, \%names);
        $row->{gid} = $release->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('release', $row, 'id'),
            gid => $row->{gid},
            name => $release->{name}
        );
    }
    return @releases > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $release_id, $update) = @_;
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $self->sql->update_row('release', $row, { id => $release_id });
}

sub can_delete { 1 }

sub delete
{
    my ($self, @release_ids) = @_;

    $self->c->model('Collection')->delete_releases(@release_ids);
    $self->c->model('Relationship')->delete_entities('release', @release_ids);
    $self->annotation->delete(@release_ids);
    $self->remove_gid_redirects(@release_ids);
    $self->tags->delete(@release_ids);

    $self->sql->do('DELETE FROM release_coverart WHERE id IN (' . placeholders(@release_ids) . ')',
             @release_ids);

    $self->sql->do('DELETE FROM release_label WHERE release IN (' . placeholders(@release_ids) . ')',
             @release_ids);

    my @mediums = @{
        $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release IN (' . placeholders(@release_ids) . ')',
            @release_ids
        )
    };

    $self->c->model('Medium')->delete($_) for @mediums;

    my @release_group_ids = @{
        $self->sql->select_single_column_array(
            'DELETE FROM release WHERE id IN (' . placeholders(@release_ids) . ')
             RETURNING release_group',
            @release_ids
        )
    };

    $self->c->model('ReleaseGroup')->clear_empty_release_groups(@release_group_ids);

    return;
}

sub can_merge {
    my ($self, %opts) = @_;

    my $new_id = $opts{new_id};
    my @old_ids = @{ $opts{old_ids} };
    my $strategy = $opts{merge_strategy} || $MERGE_APPEND;

    if ($strategy == $MERGE_MERGE) {
        my $mediums_differ = $self->sql->select_single_value(
            'SELECT TRUE
             FROM (
                 SELECT medium.id, medium.position, tracklist.track_count
                 FROM medium
                 JOIN tracklist ON tracklist.id = medium.tracklist
                 WHERE release IN (' . placeholders(@old_ids) . ')
             ) s
             LEFT JOIN medium new_medium ON
                 (new_medium.position = s.position AND new_medium.release = ?)
             LEFT JOIN tracklist ON tracklist.id = new_medium.tracklist
             WHERE tracklist.track_count <> s.track_count
                OR new_medium.id IS NULL
             LIMIT 1',
            @old_ids, $new_id);

        return !$mediums_differ;
    }
    elsif ($strategy == $MERGE_APPEND) {
        my %positions = %{ $opts{medium_positions} || {} } or return 0;

        # All mediums on the source releases must be moved
        my @must_move_mediums = @{ $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release = any(?)',
            \@old_ids
        ) };

        return 0 if grep { !exists $positions{$_} } @must_move_mediums;

        # Make sure the new positions don't conflict with the current new medium
        my @conflicts = @{
            $self->sql->select_single_column_array(
            'WITH changes (id, position) AS (
               VALUES ' . join(', ', ('(?::integer, ?::integer)') x keys %positions) . '
             )
             SELECT DISTINCT position
             FROM (
               (
                 SELECT id, position
                 FROM changes
               ) UNION
               (
                 SELECT all_m.id, all_m.position
                 FROM changes
                 JOIN medium changed_m ON changed_m.id = changes.id
                 JOIN medium all_m ON all_m.release = changed_m.release
                 WHERE all_m.id not in (select id from changes)
               )
             ) s
             GROUP BY position
             HAVING count(id) > 1
             ', map { $_, $positions{$_} } keys %positions)
        };

        return 0 if @conflicts;

        # If we've got this far, it must be ok to merge
        return 1;
    }
}

sub determine_recording_merges
{
    my ($self, @releases) = @_;

    my %medium_by_position;
    foreach my $release (@releases) {
        foreach my $medium ($release->all_mediums) {
            if (exists $medium_by_position{$medium->position}) {
                push @{ $medium_by_position{$medium->position} }, $medium;
			}
            else {
                $medium_by_position{$medium->position} = [ $medium ];
            }
        }
    }

    my %recording_by_position;
    for my $m_pos (keys %medium_by_position) {
        # must have at least two mediums
        my @mediums = @{ $medium_by_position{$m_pos} };
        next if @mediums <= 1;
        # all mediums must have the same number of tracks
        my $track_count = $mediums[0]->tracklist->track_count;
        next if grep { $_->tracklist->track_count != $track_count } @mediums;
        # group recordings by track position 
        $recording_by_position{$m_pos} = {};
        for my $medium (@mediums) {
            for my $tr ($medium->tracklist->all_tracks) {
                my $tr_pos = $tr->position;
                if (exists $recording_by_position{$m_pos}->{$tr_pos}) {
                    push @{ $recording_by_position{$m_pos}->{$tr_pos} }, $tr->recording;
                }
                else {
                    $recording_by_position{$m_pos}->{$tr_pos} = [ $tr->recording ];
                }   
            }
        }
    }

    my @merges;
    for my $m_pos (sort { $a <=> $b } keys %recording_by_position) {
        for my $tr_pos (sort { $a <=> $b } keys %{ $recording_by_position{$m_pos} }) {
            my $recordings = $recording_by_position{$m_pos}->{$tr_pos};
            push @merges, $recordings if scalar @$recordings;
        }
    }

    return @merges;
}

sub merge
{
    my ($self, %opts) = @_;

    my $new_id = $opts{new_id};
    my @old_ids = @{ $opts{old_ids} };
    my $merge_strategy = $opts{merge_strategy} || $MERGE_APPEND;

    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_releases($new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_releases($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('release', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('release', $new_id, @old_ids);
    $self->c->model('CoverArtArchive')->merge_releases($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'release',
            columns => [ qw( status packaging country barcode script language ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    merge_partial_date(
        $self->sql => (
            table => 'release',
            field => 'date',
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    if ($merge_strategy == $MERGE_APPEND) {
        my %positions = %{ $opts{medium_positions} || {} }
            or confess('Missing medium_positions parameter');

        my $update_names = defined $opts{medium_names};
        my %names = %{ $opts{medium_names} || {} };

        my @medium_ids = @{ $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release IN (' . placeholders($new_id, @old_ids) . ')',
            $new_id, @old_ids
        ) };

        confess('medium_positions does not account for all mediums in all releases')
            if (keys %positions != grep { exists $positions{$_} } @medium_ids);

        foreach my $id (@medium_ids) {
            next unless exists $positions{$id};
            $self->sql->do('UPDATE medium SET release = ?, position = ? WHERE id = ?',
                           $new_id, $positions{$id}, $id);
        }

        if ($update_names) {
            foreach my $id (@medium_ids) {
                next unless exists $names{$id};
                $self->sql->do('UPDATE medium SET name = ? WHERE id = ?',
                               $names{$id} || undef, $id);
            }
        }
    }
    elsif ($merge_strategy == $MERGE_MERGE) {
        confess('Mediums contain differing numbers of tracks')
            unless $self->can_merge(
                merge_strategy => $MERGE_MERGE,
                new_id => $new_id,
                old_ids => \@old_ids);

        my @merges = @{
            $self->sql->select_list_of_hashes(
                'SELECT newmed.id AS new_id,
                        oldmed.id AS old_id,
                        newmed.tracklist AS new_tracklist,
                        oldmed.tracklist AS old_tracklist
                   FROM medium newmed, medium oldmed
                  WHERE newmed.release = ?
                    AND oldmed.release IN (' . placeholders(@old_ids) . ')
                    AND newmed.position = oldmed.position',
                $new_id, @old_ids
            )
        };
        for my $merge (@merges) {
            $self->c->model('Tracklist')->merge(
                $merge->{new_tracklist},
                $merge->{old_tracklist}
            ) if $merge->{new_tracklist} != $merge->{old_tracklist};

            $self->c->model('MediumCDTOC')->merge_mediums(
                $merge->{new_id},
                $merge->{old_id}
            );
        }

        $self->sql->do(
            'DELETE FROM medium WHERE release IN (' . placeholders(@old_ids) . ')',
            @old_ids
        );
    }

    $self->sql->do(
        'DELETE FROM release_coverart
          WHERE id IN (' . placeholders(@old_ids) . ')',
        @old_ids
    );

    $self->_delete_and_redirect_gids('release', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $release, $names) = @_;
    my $row = hash_to_row($release, {
        artist_credit => 'artist_credit',
        release_group => 'release_group_id',
        status => 'status_id',
        packaging => 'packaging_id',
        country => 'country_id',
        script => 'script_id',
        language => 'language_id',
        map { $_ => $_ } qw( barcode comment quality )
    });

    add_partial_date_to_row($row, $release->{date}, 'date');

    $row->{name} = $names->{$release->{name}}
        if (exists $release->{name});

    return $row;
}

sub load_meta
{
    my $self = shift;
    my (@objs) = @_;

    my %id_to_obj = map { $_->id => $_ } @objs;

    MusicBrainz::Server::Data::Utils::load_meta($self->c, "release_meta", sub {
        my ($obj, $row) = @_;
        $obj->info_url($row->{info_url}) if defined $row->{info_url};
        $obj->amazon_asin($row->{amazon_asin}) if defined $row->{amazon_asin};
        $obj->amazon_store($row->{amazon_store}) if defined $row->{amazon_store};
        $obj->cover_art_presence($row->{cover_art_presence});
    }, @objs);

    my @ids = keys %id_to_obj;
    $self->sql->select(
        'SELECT * FROM release_coverart WHERE id IN ('.placeholders(@ids).')',
        @ids
    );
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        $id_to_obj{ $row->{id} }->cover_art_url( $row->{cover_art_url} )
            if defined $row->{cover_art_url};
    }
    $self->sql->finish;
}

sub find_ids_by_track_ids
{
    my ($self, @ids) = @_;
    my $query = 'SELECT release
                   FROM medium
                  WHERE tracklist IN (
                            SELECT tracklist FROM track
                             WHERE id IN (' . placeholders(@ids) . ')
                        )';
    return $self->sql->select_single_column_array($query, @ids);
}

sub find_similar
{
    my ($self, %opts) = @_;
    my $name = $opts{name};
    my $artist_credit = $opts{artist_credit};

    my ($results) = $self->c->model('Search')->search('release', $name, 50, 0);
    my @releases = map { $_->entity } @$results;
    $self->c->model('ArtistCredit')->load(@releases);

    my %artist_ids = map { $_->{artist}->{id} => 1 }
        grep { $_->{artist}->{id} } grep { ref($_) } @{ $artist_credit->{names} };

    return
        # Make sure all the artists are in the artist credit
        grep {
            keys %artist_ids == grep {
                exists $artist_ids{$_->artist_id}
            } $_->artist_credit->all_names
        }
        # Make sure the artist credit has the same amount of artists
        grep { $_->artist_credit->artist_count == keys %artist_ids }
            @releases;
}

sub filter_barcode_changes {
    my ($self, @barcodes) = @_;
    return unless @barcodes;
    return @{
        $self->c->sql->select_list_of_hashes(
            'SELECT DISTINCT change.release, change.barcode
             FROM (VALUES ' . join(', ', ("(?::uuid, ?)") x @barcodes) . ') change (release, barcode)
             LEFT JOIN release_gid_redirect rgr ON rgr.gid = change.release
             JOIN release ON (release.gid = change.release OR rgr.new_id = release.id)
             WHERE change.barcode IS DISTINCT FROM release.barcode',
            map { $_->{release}, $_->{barcode} } @barcodes
        )
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Release

=head1 METHODS

=head2 find_by_artist ($artist_id, $limit, [$offset])

Finds releases by the specified artist, and returns an array containing
a reference to the array of releases and the total number of found releases.
The $limit parameter is used to limit the number of returned releass.

=head2 find_by_release_group ($release_group_id, $limit, [$offset])

Finds releases by the specified release group, and returns an array containing
a reference to the array of releases and the total number of found releases.
The $limit parameter is used to limit the number of returned releass.

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
