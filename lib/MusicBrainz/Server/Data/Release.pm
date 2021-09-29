package MusicBrainz::Server::Data::Release;

use 5.18.2; # enables the state feature
use utf8;

use Moose;
use namespace::autoclean -also => [qw( _where_status_in _where_type_in )];

use Carp 'confess';
use DBDefs;
use JSON::XS;
use List::AllUtils qw( all any );
use List::MoreUtils qw( part );
use List::UtilsBy qw( nsort_by partition_by );
use MusicBrainz::Server::Constants qw(
    :quality
    $EDIT_RELEASE_CREATE
    $STATUS_APPLIED
    $VARTIST_ID
);
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::ReleaseEvent;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    hash_to_row
    load_subobjects
    merge_table_attributes
    object_to_ids
    order_by
    placeholders
);
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Translation qw( comma_list N_l );
use MusicBrainz::Server::Validation qw( encode_entities );
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Collection';

use Readonly;
Readonly our $MERGE_APPEND => 1;
Readonly our $MERGE_MERGE => 2;

Readonly::Hash our %RELEASE_MERGE_ERRORS => (
    ambiguous_recording_merge   => N_l('Unable to determine which recording {source_recording} should be merged into. There are multiple valid options: {target_recordings}.'),
    medium_missing              => N_l('Some mediums being merged don’t have an equivalent on the target release: either the target release has less mediums, or the positions don’t match.'),
    medium_positions            => N_l('The medium positions conflict.'),
    medium_track_counts         => N_l('The track counts on at least one set of corresponding mediums do not match.'),
    merging_into_empty          => N_l('Merging a medium with tracks into one without them is not currently supported. You can always merge in the other direction!'),
    pregaps                     => N_l('Mediums with a pregap track can only be merged with other mediums with a pregap track.'),
    recording_merge_cycle       => N_l('A merge cycle exists whereby two recordings ({recording1} and {recording2}) each want to merge into the other. This is likely because the tracks or recordings are in an inconsistent order on the releases.'),
);

sub _type { 'release' }

sub _columns
{
    return 'release.id, release.gid, release.name, release.artist_credit AS artist_credit_id,
            release.release_group, release.status, release.packaging,
            release.comment, release.edits_pending, release.barcode,
            release.script, release.language, release.quality, release.last_updated';
}

sub _id_column
{
    return 'release.id';
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

sub _where_filter
{
    my ($filter, $using_artist_release_table) = @_;

    my (@query, @joins, @params);

    if (defined $filter) {
        if (exists $filter->{name}) {
            push @query, q{(mb_simple_tsvector(release.name) @@ plainto_tsquery('mb_simple', mb_lower(?)) OR release.name = ?)};
            push @params, $filter->{name}, $filter->{name};
        }
        if (exists $filter->{artist_credit_id}) {
            push @query, 'release.artist_credit = ?';
            push @params, $filter->{artist_credit_id};
        }
        if (exists $filter->{status} && $filter->{status}) {
            my @statuses = ref($filter->{status}) ? @{ $filter->{status} } : ( $filter->{status} );
            if (@statuses) {
                push @query, 'release.status IN (' . placeholders(@statuses) . ')';
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
        my $country_id_filter = $filter->{country_id};
        my $date_filter = $filter->{date};
        if (defined $country_id_filter || defined $date_filter) {
            my $country_date_query = 'release.id IN (SELECT release FROM release_event WHERE ';
            my @country_date_conditions;
            if (defined $country_id_filter) {
                push @country_date_conditions, 'country = ?';
                push @params, $country_id_filter;
            }
            if (defined $date_filter) {
                my $date = MusicBrainz::Server::Entity::PartialDate->new($date_filter);
                if (defined $date->year) {
                    push @country_date_conditions, 'date_year = ?';
                    push @params, $date->year;
                }
                if (defined $date->month) {
                    push @country_date_conditions, 'date_month = ?';
                    push @params, $date->month;
                }
                if (defined $date->day) {
                    push @country_date_conditions, 'date_day = ?';
                    push @params, $date->day;
                }
            }
            $country_date_query .= (join ' AND ', @country_date_conditions) . ')';
            push @query, $country_date_query;
        }
        if ($using_artist_release_table) {
            unshift @joins, 'JOIN release ON release.id = ar.release';
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

    my $query = 'SELECT DISTINCT rel.artist_credit
                 FROM release rel
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rel.artist_credit
                 WHERE acn.artist = ?';
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->c->model('ArtistCredit')->find_by_ids($ids);
}

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                   JOIN release_event ON release.id = release_event.release
                   JOIN area ON release_event.country = area.id
                 WHERE area.id = ?
                 ORDER BY release.name COLLATE musicbrainz, release.id';

    $self->query_to_list_limited($query, [$area_id], $limit, $offset);
}

sub has_materialized_artist_release_data {
    my ($self) = @_;
    CORE::state $has_data;
    if (defined $has_data) {
        return $has_data;
    }
    $has_data = $self->sql->select_single_value(
        'SELECT 1 FROM artist_release LIMIT 1',
    ) ? 1 : 0;
    return $has_data;
}

sub _find_by_artist_slow
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'acn.artist = ?';
    push @$params, $artist_id;

    my $query;
    if ($artist_id == $VARTIST_ID) {
        # MBS-10939: For VA, only order by ID. Sorting by date, country
        # name, etc. doesn't currently scale at this level and causes
        # load issues on our DB server.
        $query = '
            SELECT DISTINCT ON (release.id) ' .
            $self->_columns . ' FROM ' . $self->_table . '
            JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
            ' . join(' ', @$extra_joins) . '
            WHERE ' . join(' AND ', @$conditions) . '
            ORDER BY release.id';
    } else {
        $query = '
            SELECT *
            FROM (
              SELECT DISTINCT ON (release.id)
                ' . $self->_columns . ',
                date_year, date_month, date_day, area.name AS country_name
              FROM ' . $self->_table . '
              JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
              ' . join(' ', @$extra_joins) . '
              LEFT JOIN release_event ON release_event.release = release.id
              LEFT JOIN area ON area.id = release_event.country
              WHERE ' . join(' AND ', @$conditions) . '
              ORDER BY release.id, date_year, date_month, date_day,
                country_name, barcode, release.name COLLATE musicbrainz
            ) release
            ORDER BY date_year, date_month, date_day,
              country_name, barcode, name COLLATE musicbrainz';
    }
    $self->query_to_list_limited($query, $params, $limit, $offset, undef, cache_hits => 1);
}

sub _find_by_artist_fast {
    my ($self, $artist_id, $va, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 1);

    push @$conditions, 'ar.is_track_artist = ' . ($va ? 'TRUE' : 'FALSE');
    push @$conditions, 'ar.artist = ?';
    push @$params, $artist_id;

    my $inner_query = 'FROM artist_release ar ' .
        join(' ', @$extra_joins) . ' ' .
        'WHERE ' . join(' AND ', @$conditions);

    my $count_query = 'SELECT count(*) ' . $inner_query;
    my $total_row_count = $self->sql->select_single_value($count_query, @$params);

    my $results_query = 'SELECT release ' .
        $inner_query . ' ' .
        # Do NOT modify the `ORDER BY` here. We're returning things in
        # index order (`artist_release_*_idx_sort`) to avoid a sort
        # operation. Changing the order is a schema change.
        'ORDER BY ar.artist, ' .
            'ar.first_release_date NULLS LAST, ' .
            'ar.catalog_numbers NULLS LAST, ' .
            'ar.country_code NULLS LAST, ' .
            'ar.barcode NULLS LAST, ' .
            'ar.sort_character, ' .
            'ar.release ' .
        'LIMIT ? OFFSET ?';

    my $release_ids = $self->sql->select_single_column_array(
        $results_query, @$params, $limit, $offset,
    );
    my $releases_by_id = $self->get_by_ids(@$release_ids);

    my @releases = map { $releases_by_id->{$_} } @$release_ids;
    $self->load_meta(@releases);

    return (\@releases, $total_row_count);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    if ($self->has_materialized_artist_release_data) {
        return $self->_find_by_artist_fast($artist_id, 0, $limit, $offset, %args);
    }
    return $self->_find_by_artist_slow($artist_id, $limit, $offset, %args);
}

sub find_by_artist_credit
{
    my ($self, $artist_credit_id, $limit, $offset) = @_;

    my $query = 'SELECT ' . $self->_columns . ',
                   release.name COLLATE musicbrainz AS name_collate
                 FROM ' . $self->_table . '
                 WHERE artist_credit = ?
                 ORDER BY release.name COLLATE musicbrainz';
    $self->query_to_list_limited($query, [$artist_credit_id], $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'instrument.id = ?';
    push @$params, $instrument_id;

    # NOTE: if more tables than l_artist_release are added here, check admin/BuildSitemaps.pl
    my $query = '
      SELECT *
      FROM (
        SELECT ' . $self->_columns . q(,
          date_year, date_month, date_day,
          area.name AS country_name,
          array_agg(json_build_object('typeName', link_type.name, 'credit', lac.credited_as)) AS instrument_credits_and_rel_types
        FROM ) . $self->_table . '
        JOIN l_artist_release ON l_artist_release.entity1 = release.id
        JOIN link ON link.id = l_artist_release.link
        JOIN link_type ON link_type.id = link.link_type
        JOIN link_attribute ON link_attribute.link = link.id
        JOIN link_attribute_type ON link_attribute_type.id = link_attribute.attribute_type
        JOIN instrument ON instrument.gid = link_attribute_type.gid
        LEFT JOIN link_attribute_credit lac ON (
          lac.link = link_attribute.link AND
          lac.attribute_type = link_attribute.attribute_type
        )
        ' . join(' ', @$extra_joins) . '
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
         WHERE ' . join(' AND ', @$conditions) . '
        GROUP BY release.id, date_year, date_month, date_day, country_name
        ORDER BY release.id, date_year, date_month, date_day,
          release.name COLLATE musicbrainz, country_name,
          barcode
      ) s
      ORDER BY date_year, date_month, date_day,
        name COLLATE musicbrainz, country_name,
        barcode';

    $self->query_to_list_limited($query, $params, $limit, $offset, sub {
        my ($model, $row) = @_;

        my $credits_and_rel_types = delete $row->{instrument_credits_and_rel_types};
        { release => $model->_new_from_row($row), instrument_credits_and_rel_types => $credits_and_rel_types };
    });
}

sub find_by_label
{
    my ($self, $label_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'release_label.label = ?';
    push @$params, $label_id;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day, catalog_number,
          area.name AS country_name
        FROM ' . $self->_table . '
        JOIN release_label ON release_label.release = release.id
        ' . join(' ', @$extra_joins) . '
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
         WHERE ' . join(' AND ', @$conditions) . '
        ORDER BY release.id, date_year, date_month, date_day, catalog_number,
          release.name COLLATE musicbrainz, country_name,
          barcode
      ) s
      ORDER BY date_year, date_month, date_day, catalog_number,
        name COLLATE musicbrainz, country_name,
        barcode';
    $self->query_to_list_limited($query, $params, $limit, $offset, undef, cache_hits => 1);
}

sub find_by_disc_id
{
    my ($self, $disc_id) = @_;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day
        FROM ' . $self->_table . '
        JOIN medium ON medium.release = release.id
        JOIN medium_cdtoc ON medium_cdtoc.medium = medium.id
        JOIN cdtoc ON medium_cdtoc.cdtoc = cdtoc.id
        LEFT JOIN release_event ON release_event.release = release.id
        WHERE cdtoc.discid = ?
        ORDER BY release.id, date_year, date_month, date_day,
          release.name COLLATE musicbrainz
      ) s
      ORDER BY date_year, date_month, date_day,
        name COLLATE musicbrainz';

    $self->query_to_list($query, [$disc_id]);
}

sub find_by_release_group
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'release_group IN (' . placeholders(@ids) . ')';
    push @$params, @ids;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id) ' . $self->_columns . ',
          date_year, date_month, date_day, area.name AS country_name
        FROM ' . $self->_table . '
        ' . join(' ', @$extra_joins) . '
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE ' . join(' AND ', @$conditions) . '
        ORDER BY release.id, date_year, date_month, date_day,
          country_name, barcode
      ) s
      ORDER BY date_year, date_month, date_day,
        country_name, barcode
    ';

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub _find_by_track_artist_slow
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, '
        release.id IN (
            SELECT release FROM medium
                JOIN track tr
                ON tr.medium = medium.id
                JOIN artist_credit_name acn
                ON acn.artist_credit = tr.artist_credit
            WHERE acn.artist = ?)
        AND release.id NOT IN (
            SELECT id FROM release
              JOIN artist_credit_name acn
                ON release.artist_credit = acn.artist_credit
             WHERE acn.artist = ?)';
    push @$params, $artist_id, $artist_id;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day
          FROM ' . $self->_table . '
          ' . join(' ', @$extra_joins) . '
          LEFT JOIN release_event ON release_event.release = release.id
          LEFT JOIN area ON area.id = release_event.country
          WHERE ' . join(' AND ', @$conditions) . '
          ORDER BY release.id, date_year, date_month, date_day,
            release.name COLLATE musicbrainz
      ) s
      ORDER BY date_year, date_month, date_day,
        name COLLATE musicbrainz';

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_track_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    # Note: This excludes releases where $artist_id appears in the
    # release artist credit.
    if ($self->has_materialized_artist_release_data) {
        return $self->_find_by_artist_fast($artist_id, 1, $limit, $offset, %args);
    }
    return $self->_find_by_track_artist_slow($artist_id, $limit, $offset, %args);
}

sub find_by_recording
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );
    return ([], 0) unless @ids;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'track.recording IN (' . placeholders(@ids) . ')';
    push @$params, @ids;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day
        FROM ' . $self->_table . '
        ' . join(' ', @$extra_joins) . '
        JOIN medium ON medium.release = release.id
        JOIN track ON track.medium = medium.id
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE ' . join(' AND ', @$conditions) . '
        ORDER BY release.id, date_year, date_month, date_day,
          release.name COLLATE musicbrainz
      ) s
      ORDER BY date_year, date_month, date_day,
        name COLLATE musicbrainz
    ';

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_recordings
{
    my ($self, @ids) = @_;
    return () unless @ids;

    my $query =
        'SELECT DISTINCT ON (release.id, track.recording) ' . $self->_columns . ',
                track.recording, track.position AS track_position, medium.position AS medium_position,
                medium.track_count as medium_track_count
           FROM release
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
          WHERE track.recording IN (' . placeholders(@ids) . ')';

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        $map{ $row->{recording} } ||= [];
        push @{ $map{ $row->{recording} } }, {
            release             => $self->_new_from_row($row),
            track_position      => $row->{track_position},
            medium_position     => $row->{medium_position},
            medium_track_count  => $row->{medium_track_count}
        }
    }

    return %map;
}

sub find_by_country
{
    my ($self, $country_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'release_event.country = ?';
    push @$params, $country_id;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day, area.name AS country_name
        FROM ' . $self->_table . '
        JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
        ' . join(' ', @$extra_joins) . '
        LEFT JOIN (
          SELECT release, country, date_year, date_month, date_day
          FROM release_country
        ) release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE ' . join(' AND ', @$conditions) . '
        ORDER BY release.id, date_year, date_month, date_day,
          country_name, barcode, release.name COLLATE musicbrainz
      ) release
      ORDER BY date_year, date_month, date_day,
        country_name, barcode, name COLLATE musicbrainz';

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_for_cdtoc
{
    my ($self, $artist_id, $track_count, $limit, $offset) = @_;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          ' . $self->_columns . ',
          date_year, date_month, date_day
        FROM ' . $self->_table . '
        JOIN artist_credit_name acn
          ON acn.artist_credit = release.artist_credit
        JOIN medium
           ON medium.release = release.id
        LEFT JOIN medium_format
           ON medium_format.id = medium.format
        JOIN release_group
           ON release.release_group = release_group.id
        LEFT JOIN release_event ON release_event.release = release.id
        WHERE track_count_matches_cdtoc(medium, ?)
          AND acn.artist = ?
        ORDER BY release.id, release.release_group,
          date_year, date_month, date_day, release.name COLLATE musicbrainz
      ) s
      ORDER BY release_group,
          date_year, date_month, date_day, name COLLATE musicbrainz';

    $self->query_to_list_limited($query, [$track_count, $artist_id], $limit, $offset);
}

sub find_gid_for_track
{
    my ($self, $track_id) = @_;

    # A track is not a user visible entity, this function is called by
    # the track controller to issue a redirect to the release page
    # on which the track appears.  So only the release MBID is needed.

    my $query =
        'SELECT release.gid
           FROM release
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
          WHERE track.id = ?';

    return $self->sql->select_single_value($query, $track_id);
}

sub load_with_medium_for_recording
{
    my ($self, $recording_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter}, 0);

    push @$conditions, 'track.recording = ?';
    push @$params, $recording_id;

    my $query = '
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          release.id AS r_id,
          release.gid AS r_gid,
          release.name AS r_name,
          release.artist_credit AS r_artist_credit_id,
          release.release_group AS r_release_group,
          release.status AS r_status,
          release.packaging AS r_packaging,
          release.comment AS r_comment,
          release.edits_pending AS r_edits_pending,
          release.barcode AS r_barcode,
          release.script AS r_script,
          release.language AS r_language,
          release.quality AS r_quality,
          release.last_updated as r_last_updated,
          medium.id AS m_id,
          medium.format AS m_format,
          medium.position AS m_position,
          medium.name AS m_name,
          medium.track_count AS m_track_count,
          (SELECT count(*) FROM track WHERE medium = medium.id AND position > 0 AND is_data_track = false) AS m_cdtoc_track_count,
          track.id AS t_id,
          track.gid AS t_gid,
          track.name AS t_name,
          track.medium AS t_medium,
          track.position AS t_position,
          track.length AS t_length,
          track.artist_credit AS t_artist_credit,
          track.number AS t_number,
          date_year, date_month, date_day
        FROM track
        JOIN medium ON medium.id = track.medium
        JOIN release ON release.id = medium.release
        LEFT JOIN release_event ON release_event.release = release.id
        ' . join(' ', @$extra_joins) . '
        WHERE ' . join(' AND ', @$conditions) . '
        ORDER BY release.id, date_year, date_month, date_day,
          release.name COLLATE musicbrainz
      ) s
      ORDER BY date_year, date_month, date_day,
        r_name COLLATE musicbrainz';

    $self->query_to_list_limited($query, $params, $limit, $offset, sub {
        my ($model, $row) = @_;

        my $track = MusicBrainz::Server::Data::Track->_new_from_row($row, 't_');
        my $medium = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');

        my $release = $model->_new_from_row($row, 'r_');

        push @{ $release->mediums }, $medium;
        push @{ $medium->tracks }, $track;

        $release;
    });
}

sub find_by_medium {
    my ($self, $medium_ids, $limit, $offset) = @_;

    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                     WHERE medium.id = any(?)
                )' .
                ' ORDER BY release.id';

    $self->query_to_list_limited($query, [$medium_ids], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = '';
    my $also_select = '';

    my $order_by = order_by($order, 'date', {
        'date' => sub {
            return 'date_year, date_month, date_day, release.name COLLATE musicbrainz'
        },
        'name' => sub {
            return 'release.name COLLATE musicbrainz, date_year, date_month, date_day'
        },
        'country' => sub {
            $extra_join = 'LEFT JOIN area ON release_event.country = area.id';
            $also_select = 'area.name AS country_name';
            return 'country_name, date_year, date_month, date_day';
        },
        'artist' => sub {
            $extra_join = 'JOIN artist_credit ac ON ac.id = release.artist_credit';
            $also_select = 'ac.name AS ac_name';
            return 'ac_name COLLATE musicbrainz, release.name COLLATE musicbrainz';
        },
        'label' => sub {
            $extra_join = 'LEFT OUTER JOIN
                (SELECT release, array_agg(label.name COLLATE musicbrainz) AS labels FROM release_label
                    JOIN label ON release_label.label = label.id
                    GROUP BY release) rl
                ON rl.release = release.id';
            $also_select = 'rl.labels AS labels';
            return 'labels, release.name COLLATE musicbrainz';
        },
        'catno' => sub {
            $extra_join = 'LEFT OUTER JOIN
                (SELECT release, array_agg(catalog_number) AS catnos FROM release_label
                  WHERE catalog_number IS NOT NULL GROUP BY release) rl
                ON rl.release = release.id';
            $also_select = 'catnos';
            return 'catnos, release.name COLLATE musicbrainz';
        },
        'format' => sub {
            $extra_join = 'LEFT JOIN medium ON medium.release = release.id
                           LEFT JOIN medium_format ON medium.format = medium_format.id';
            $also_select = 'medium_format.name AS medium_format_name';
            return 'medium_format_name COLLATE musicbrainz, release.name COLLATE musicbrainz';
        },
        'tracks' => sub {
            $extra_join = 'LEFT JOIN
                (SELECT medium.release, sum(track_count) AS total_track_count
                    FROM medium
                    GROUP BY medium.release) tc
                ON tc.release = release.id';
            $also_select = 'total_track_count';
            return 'total_track_count, release.name COLLATE musicbrainz';
        },
        'barcode' => sub {
            return 'length(barcode), barcode, release.name COLLATE musicbrainz'
        },
    });

    # Date and release event information should always be included.
    if ($also_select ne '') {
        $also_select .= ', ';
    }
    $also_select .= 'date_year, date_month, date_day';

    $extra_join = 'LEFT JOIN release_event ON release_event.release = release.id ' . $extra_join;

    my $inner_order_by = $order_by
        =~ s/country_name/area.name/r
        =~ s/ac_name/ac.name/r
        =~ s/labels/rl.labels/r
        =~ s/catnos/rl.catnos/r
        =~ s/medium_format_name/medium_format.name/r
        =~ s/total_track_count/tc.total_track_count/r;

    return ($order_by, $extra_join, $also_select, $inner_order_by);
}

sub _insert_hook_after_each {
    my ($self, $created, $release) = @_;

    $self->set_release_events(
        $created->{id}, $release->{release_group_id}, _release_events_from_spec($release->{events} // [])
    );
}

sub _release_events_from_spec {
    my $events = shift;
    return [
        map {
            MusicBrainz::Server::Entity::ReleaseEvent->new(
                country_id => $_->{country_id},
                date => MusicBrainz::Server::Entity::PartialDate->new($_->{date})
            )
        } @$events
    ];
}

sub update {
    my ($self, $release_id, $update) = @_;

    my $release_group_id = $update->{release_group_id} // $self->sql->select_single_value(
        'SELECT release_group FROM release WHERE id = ?', $release_id
    );

    $self->set_release_events(
        $release_id, $release_group_id, _release_events_from_spec($update->{events})
    ) if $update->{events};

    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('release', $row, { id => $release_id }) if %$row;

    if ($update->{events} || $update->{name}) {
        $self->c->model('Series')->reorder_for_entities('release', $release_id);
    }

    if ($update->{events} || $update->{release_group_id}) {
        $self->c->model('Series')->reorder_for_entities('release_group', $release_group_id);
    }
}

sub can_delete { 1 }

sub delete
{
    my ($self, @release_ids) = @_;

    $self->c->model('Collection')->delete_entities('release', @release_ids);
    $self->c->model('Relationship')->delete_entities('release', @release_ids);
    $self->alias->delete_entities(@release_ids);
    $self->annotation->delete(@release_ids);
    $self->remove_gid_redirects(@release_ids);
    $self->tags->delete(@release_ids);

    $self->sql->do('DELETE FROM release_coverart WHERE id IN (' . placeholders(@release_ids) . ')',
             @release_ids);

    $self->sql->do('DELETE FROM release_label WHERE release IN (' . placeholders(@release_ids) . ')',
             @release_ids);

    $self->sql->do('DELETE FROM cover_art_archive.release_group_cover_art ' .
                   'WHERE release IN (' . placeholders(@release_ids) . ')',
                   @release_ids);

    $self->sql->do('DELETE FROM release_country WHERE release = any(?)', \@release_ids);
    $self->sql->do('DELETE FROM release_unknown_country WHERE release = any(?)', \@release_ids);

    my @mediums = @{
        $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release IN (' . placeholders(@release_ids) . ')',
            @release_ids
        )
    };

    $self->c->model('Medium')->delete($_) for @mediums;

    my @release_group_ids = @{
        $self->sql->select_single_column_array(
            'SELECT release_group FROM release WHERE id IN (' . placeholders(@release_ids) . ')',
            @release_ids
        )
    };

    $self->delete_returning_gids(@release_ids);

    $self->c->model('ReleaseGroup')->clear_empty_release_groups(@release_group_ids);

    return;
}

sub can_merge {
    my ($self, $opts) = @_;

    my $new_id = $opts->{new_id};
    my @old_ids = @{ $opts->{old_ids} };
    my $strategy = $opts->{merge_strategy} || $MERGE_APPEND;

    if ($strategy == $MERGE_MERGE) {
        my $mediums_query =
            'SELECT TRUE
             FROM (
                 SELECT medium.id, medium.position, medium.track_count
                 FROM medium
                 WHERE release = any(?)
             ) s
             LEFT JOIN medium new_medium ON
                 (new_medium.position = s.position AND new_medium.release = ?)';

        my $target_medium_missing = $self->sql->select_single_value(
            "$mediums_query
             WHERE new_medium.id IS NULL
             LIMIT 1",
            \@old_ids, $new_id);

        if ($target_medium_missing) {
            return (0, {
                message => $RELEASE_MERGE_ERRORS{medium_missing},
            });
        }

        my $merging_into_empty_medium = $self->sql->select_single_value(<<~"SQL", \@old_ids, $new_id);
            $mediums_query
            WHERE s.track_count > 0
            AND new_medium.track_count = 0
            LIMIT 1
            SQL

        if ($merging_into_empty_medium) {
            return (0, {
                message => $RELEASE_MERGE_ERRORS{merging_into_empty},
            });
        }

        my $medium_track_counts_differ = $self->sql->select_single_value(<<~"SQL", \@old_ids, $new_id);
            $mediums_query
            WHERE new_medium.track_count <> s.track_count
            AND s.track_count > 0
            LIMIT 1
            SQL

        if ($medium_track_counts_differ) {
            return (0, {
                message => $RELEASE_MERGE_ERRORS{medium_track_counts},
            });
        }

        my $medium_ids = $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release = any(?)',
            [$new_id, @old_ids]
        );

        my %mediums_by_position =
            partition_by { $_->position }
            values %{ $self->c->model('Medium')->get_by_ids(@{$medium_ids}) };

        for my $mediums (values %mediums_by_position) {
            my %pregap_count;
            $pregap_count{$_->has_pregap}++ for @{$mediums};

            # Mediums in the same position should either all have pregaps,
            # or none should.
            if ($pregap_count{0} && $pregap_count{1}) {
                return (0, {
                    message => $RELEASE_MERGE_ERRORS{pregaps},
                });
            }
        }

        return 1;
    }
    elsif ($strategy == $MERGE_APPEND) {
        my @failure = (0, {
            message => $RELEASE_MERGE_ERRORS{medium_positions},
        });

        my %positions = %{ $opts->{medium_positions} || {} } or return 0;

        # All mediums on the source releases must be moved
        my @must_move_mediums = @{ $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release = any(?)',
            \@old_ids
        ) };

        return @failure if any { !exists $positions{$_} } @must_move_mediums;

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
                 WHERE all_m.id NOT IN (SELECT id FROM changes)
               )
             ) s
             GROUP BY position
             HAVING count(id) > 1
             ', map { $_, $positions{$_} } keys %positions)
        };

        return @failure if @conflicts;

        # If we've got this far, it must be ok to merge
        return 1;
    }
}

sub determine_medium_merges {
    my ($self, $new_id, @old_ids) = @_;

    $self->sql->select_list_of_hashes(
        'SELECT newm.id AS new_id,
                array_agg(oldm.id) AS old_ids
           FROM medium newm,
                medium oldm
          WHERE newm.release = ?
            AND oldm.release = any(?)
            AND newm.position = oldm.position
            AND newm.track_count = oldm.track_count
          GROUP BY newm.id',
        $new_id,
        \@old_ids,
    );
}

sub _link_recording {
    my $recording_info = shift;

    MusicBrainz::Server::Translation->expand(
        '{url|{name}}',
        url => '/recording/' . $recording_info->{gid},
        name => encode_entities($recording_info->{name}),
    );
}

sub determine_recording_merges {
    my ($self, $new_release_id, @old_release_ids) = @_;

    my $possible_merges = $self->sql->select_list_of_hashes(q{
        SELECT newm.position AS new_medium_position,
               newt.number AS new_track_number,
               newt.position AS new_track_position,
               jsonb_build_object(
                 'id', newr.id,
                 'gid', newr.gid,
                 'name', newr.name,
                 'length', newr.length,
                 'artist_credit_id', newr.artist_credit
               ) AS new_recording,
               array_agg(DISTINCT jsonb_build_object(
                 'id', oldr.id,
                 'gid', oldr.gid,
                 'name', oldr.name,
                 'length', oldr.length,
                 'artist_credit_id', oldr.artist_credit
               )) AS old_recordings
          FROM medium newm,
               medium oldm,
               track newt,
               track oldt,
               recording newr,
               recording oldr
         WHERE newm.release = ?
           AND oldm.release = any(?)
           AND newm.position = oldm.position
           AND newm.track_count = oldm.track_count
           AND newt.medium = newm.id
           AND oldt.medium = oldm.id
           AND newt.position = oldt.position
           AND newr.id = newt.recording
           AND oldr.id = oldt.recording
           AND newr.id != oldr.id
         GROUP BY new_medium_position,
                  new_track_number,
                  new_track_position,
                  newr.id
         ORDER BY new_medium_position,
                  new_track_position
    }, $new_release_id, \@old_release_ids);

    state $json = JSON::XS->new->utf8(0);
    # MBS-8614. Track recording merges, to resolve cases where a recording is
    # a merge source on one track (after which it gets deleted), and a merge
    # target on another track (in which case we should instead use the ID of
    # the target from the first merge). Example where recording 3 should be
    # merged into recording 2:
    # 1 -> 2
    # 3 -> 1
    my %merge_targets;
    my %old_recordings_by_id;

    for my $possible_merge (@{$possible_merges}) {
        my $new_recording =
            $possible_merge->{new_recording} =
            $json->decode($possible_merge->{new_recording});

        my $old_recordings = $possible_merge->{old_recordings};
        @{$old_recordings} = map { $json->decode($_) } @{$old_recordings};

        for my $old_recording (@{$old_recordings}) {
            my $old_id = $old_recording->{id};

            $old_recordings_by_id{$old_id} = $old_recording;

            my $target = \$merge_targets{$old_id};

            if (defined ${$target}) {
                ${$target} = [${$target}] if ref ${$target} ne 'ARRAY';
                push @{${$target}}, $new_recording;
            } else {
                ${$target} = $new_recording;
            }
        }
    }

    for my $old_id (keys %merge_targets) {
        my $target = $merge_targets{$old_id};

        # We need to make sure that for each old recording, there is only 1
        # new recording to merge into. If there is > 1, then it's not clear
        # what we should merge into.

        if (ref $target eq 'ARRAY') {
            my $source = $old_recordings_by_id{$old_id};

            return (0, {
                message => $RELEASE_MERGE_ERRORS{ambiguous_recording_merge},
                vars => {
                    source_recording => _link_recording($source),
                    target_recordings => comma_list(map { _link_recording($_) } @{$target}),
                },
            });
        }
    }

    my %recording_merges;
    for my $possible_merge (@{$possible_merges}) {
        my ($new_recording, $old_recordings) = @{$possible_merge}{qw(
            new_recording
            old_recordings
        )};

        my $target = $merge_targets{$new_recording->{id}} // $new_recording;
        my $new_id = $target->{id};

        for my $old_recording (@{$old_recordings}) {
            my $old_id = $old_recording->{id};

            # If two recordings' positions are swapped (e.g. recording 1 is being
            # merged into recording 2, and recording 2 is being merged into
            # recording 1), then we don't merge them in that case, because it's
            # probably not intentional.
            if ($new_id == $old_id) {
                return (0, {
                    message => $RELEASE_MERGE_ERRORS{recording_merge_cycle},
                    vars => {
                        recording1 => _link_recording($old_recording),
                        recording2 => _link_recording($new_recording),
                    },
                });
            }

            my $merge = ($recording_merges{$new_id} //= {
                new_recording       => $target,
                new_medium_position => $possible_merge->{new_medium_position},
                new_track_number    => $possible_merge->{new_track_number},
                new_track_position  => $possible_merge->{new_track_position},
            });

            push @{$merge->{old_recordings}}, $old_recording;

            $merge_targets{$old_id} = $target;
        }
    }

    # Sort, then convert to the format expected by
    # MusicBrainz::Server::Edit::Release::Merge.
    (1, [map +{
        medium      => $_->{new_medium_position},
        track       => $_->{new_track_number},
        destination => $_->{new_recording},
        sources     => $_->{old_recordings},
    }, sort {
        $a->{new_medium_position} <=> $b->{new_medium_position} ||
        $a->{new_track_position} <=> $b->{new_track_position}
    } values %recording_merges]);
}

sub merge
{
    my ($self, %opts) = @_;

    my $new_id = $opts{new_id};
    my @old_ids = @{ $opts{old_ids} };
    my $merge_strategy = $opts{merge_strategy} || $MERGE_APPEND;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('release', $new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_releases($new_id, @old_ids);
    $self->c->model('ReleaseGroup')->merge_releases($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('release', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('release', $new_id, \@old_ids);
    $self->c->model('CoverArtArchive')->merge_releases($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'release',
            columns => [ qw( status packaging barcode script language ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    # Remove any release_unknown_country rows if other releases have the same
    # date but also set a country. However, only apply this clean up for
    # different releases - don't do within-release clean ups.
    $self->sql->do(
        'DELETE FROM release_unknown_country
         WHERE release IN (
             SELECT release_unknown_country.release
             FROM
               release_unknown_country,
               release_country
             WHERE release_unknown_country.release = any(?)
               AND release_country.release = any(?)
               AND release_unknown_country.release <> release_country.release
               AND release_unknown_country.date_year IS NOT DISTINCT FROM
                     release_country.date_year
               AND release_unknown_country.date_month IS NOT DISTINCT FROM
                     release_country.date_month
               AND release_unknown_country.date_day IS NOT DISTINCT FROM
                     release_country.date_day
         )',
         [ $new_id, @old_ids ],
         [ $new_id, @old_ids ],
    );

    $self->sql->do(
        'DELETE FROM release_country
         WHERE (release, country) IN (
           SELECT release, country
           FROM (
             SELECT release, country,
               (row_number() OVER (
                  PARTITION BY country
                  ORDER BY date_year IS NOT NULL DESC,
                           date_month IS NOT NULL DESC,
                           date_day IS NOT NULL DESC,
                           release = ? DESC)
               ) > 1 AS remove
             FROM release_country
             WHERE release = any(?)
           ) a
           WHERE remove
         )',
        $new_id,
        [ $new_id, @old_ids ],
    );

    $self->sql->do(
        'DELETE FROM release_unknown_country
         WHERE release IN (
           SELECT release
           FROM (
             SELECT release,
               (row_number() OVER (
                  ORDER BY date_year IS NOT NULL DESC,
                           date_month IS NOT NULL DESC,
                           date_day IS NOT NULL DESC,
                           release = ? DESC)
               ) > 1 AS remove
             FROM release_unknown_country
             WHERE release = any(?)
           ) a
           WHERE remove
         )',
        $new_id,
        [ $new_id, @old_ids ],
    );

    $self->sql->do(
        'UPDATE release_country SET release = ? WHERE release = any(?)',
        $new_id,
        [ $new_id, @old_ids ]
    );

    $self->sql->do(
        'UPDATE release_unknown_country SET release = ? WHERE release = any(?)',
        $new_id,
        [ $new_id, @old_ids ]
    );

    if ($merge_strategy == $MERGE_APPEND) {
        my %positions_by_medium = %{ $opts{medium_positions} || {} }
            or confess('Missing medium_positions parameter');

        my %new_positions = map { $_ => 1 } values %positions_by_medium;
        my $update_names = defined $opts{medium_names};
        my %names = %{ $opts{medium_names} || {} };

        my @existing_mediums = @{ $self->sql->select_list_of_hashes(
            'SELECT id, position FROM medium WHERE release IN (' . placeholders($new_id, @old_ids) . ')',
            $new_id, @old_ids
        ) };

        confess('medium_positions does not account for all mediums in all releases')
            unless all {
                exists $positions_by_medium{$_->{id}} || !exists $new_positions{$_->{position}}
            } @existing_mediums;

        # Set all medium positions in one query; otherwise medium_idx_uniq will
        # sometimes cause individual reorders to fail when they produce
        # duplicate positions. (MBS-7736)
        my $q = 'WITH new_positions (medium, position) AS ' .
                '(VALUES ' . join(', ', ('(?::integer,?::integer)') x keys %positions_by_medium) .') ' .
                'UPDATE medium SET release = ?, position = new_positions.position ' .
                'FROM new_positions WHERE medium.id = new_positions.medium';
        $self->sql->do($q, %positions_by_medium, $new_id);

        if ($update_names) {
            foreach my $id (map { $_->{id} } @existing_mediums) {
                next unless exists $names{$id};
                $self->sql->do('UPDATE medium SET name = ? WHERE id = ?', $names{$id}, $id);
            }
        }
    }
    elsif ($merge_strategy == $MERGE_MERGE) {
        my $recording_merges = $opts{recording_merges};

        unless (defined $recording_merges) {
            (my $can_merge, $recording_merges) = $self->determine_recording_merges($new_id, @old_ids);
            die unless $can_merge; # we should never hit this here
        }

        for my $recording_merge (@{$recording_merges}) {
            $self->c->model('Recording')->merge(
                $recording_merge->{destination}{id},
                map { $_->{id} } @{$recording_merge->{sources}},
            );
        }

        for my $medium_merge (@{ $self->determine_medium_merges($new_id, @old_ids) }) {
            $self->c->model('Track')->merge_mediums(
                $medium_merge->{new_id},
                @{$medium_merge->{old_ids}},
            );
            $self->c->model('MediumCDTOC')->merge_mediums(
                $medium_merge->{new_id},
                @{$medium_merge->{old_ids}},
            );
        }

        my $delete_these_media = $self->sql->select_single_column_array(
            'SELECT id FROM medium WHERE release IN ('.placeholders(@old_ids).')',
            @old_ids);

        $self->c->model('Medium')->delete($_) for @$delete_these_media;
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
    my ($self, $release) = @_;
    my $row = hash_to_row($release, {
        artist_credit => 'artist_credit',
        release_group => 'release_group_id',
        status => 'status_id',
        packaging => 'packaging_id',
        script => 'script_id',
        language => 'language_id',
        map { $_ => $_ } qw( barcode comment quality name )
    });

    return $row;
}

=method load_ids

Load internal IDs for release objects that only have GIDs.

=cut

sub load_ids
{
    my ($self, @releases) = @_;

    my @gids = map { $_->gid } @releases;
    return () unless @gids;

    my $query = '
        SELECT gid, id FROM release
        WHERE gid IN (' . placeholders(@gids) . ')
    ';
    my %map = map { $_->[0] => $_->[1] }
        @{ $self->sql->select_list_of_lists($query, @gids) };

    for my $release (@releases) {
        $release->id($map{$release->gid}) if exists $map{$release->gid};
    }
}

sub load_meta
{
    my $self = shift;
    my (@objs) = @_;

    my %id_to_obj = map { $_->id => $_ } @objs;

    MusicBrainz::Server::Data::Utils::load_meta($self->c, 'release_meta', sub {
        my ($obj, $row) = @_;
        $obj->info_url($row->{info_url}) if defined $row->{info_url};
        $obj->amazon_asin($row->{amazon_asin}) if defined $row->{amazon_asin};
        $obj->amazon_store($row->{amazon_store}) if defined $row->{amazon_store};
        $obj->cover_art_presence($row->{cover_art_presence});
    }, @objs);

    my @ids = keys %id_to_obj;
    if (@ids) {
        for my $row (@{
            $self->sql->select_list_of_hashes(
                'SELECT * FROM release_coverart WHERE id IN ('.placeholders(@ids).')',
                @ids
            )
        }) {
            $id_to_obj{ $row->{id} }->cover_art_url( $row->{cover_art_url} )
                if defined $row->{cover_art_url};
        }
    }
}

sub load_related_info {
    my ($self, @entities) = @_;

    $self->c->model('Medium')->load_for_releases(@entities);
    $self->c->model('MediumFormat')->load(map { $_->all_mediums } @entities);
    $self->load_release_events(@entities);
    $self->c->model('ReleaseLabel')->load(@entities);
    $self->c->model('Label')->load(map { $_->all_labels } @entities);
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
             FROM (VALUES ' . join(', ', ('(?::uuid, ?)') x @barcodes) . ') change (release, barcode)
             LEFT JOIN release_gid_redirect rgr ON rgr.gid = change.release
             JOIN release ON (release.gid = change.release OR rgr.new_id = release.id)
             WHERE change.barcode IS DISTINCT FROM release.barcode',
            map { $_->{release}, $_->{barcode} } @barcodes
        )
    };
}

sub newest_releases_with_artwork {
    my $self = shift;
    my $query = '
      SELECT DISTINCT ON (edit.id) ' . $self->_columns . ',
        cover_art.id AS cover_art_id
      FROM ' . $self->_table . q(
      JOIN cover_art_archive.cover_art ON (cover_art.release = release.id)
      JOIN cover_art_archive.cover_art_type
        ON (cover_art.id = cover_art_type.id)
      JOIN edit_release ON edit_release.release = release.id
      JOIN edit ON edit.id = edit_release.edit
      WHERE cover_art_type.type_id = ?
        AND cover_art.ordering = 1
        AND edit.type = ?
        AND cover_art.date_uploaded < NOW() - INTERVAL '10 minutes'
      ORDER BY edit.id DESC
      LIMIT 10);

    my $FRONT = 1;
    $self->query_to_list($query, [$FRONT, $EDIT_RELEASE_CREATE], sub {
        my ($model, $row) = @_;

        my $release = $model->_new_from_row($row);
        my $mbid = $release->gid;
        my $caa_id = $row->{cover_art_id};

        Artwork->new(
            id => $caa_id,
            release => $release,
            suffix => 'spoof',
        );
    });
}

sub load_release_events {
    my ($self, @releases) = @_;

    my @releases_to_load = grep { $_->event_count < 1 } @releases;
    my $events = $self->find_release_events(map { $_->id } @releases_to_load);

    for my $release (@releases_to_load) {
        $release->events($events->{$release->id});
    }

    $self->c->model('Area')->load(
        grep { $_->country_id && !defined($_->country) }
        map { $_->all_events }
        @releases
    );
}

sub find_release_events {
    my ($self, @release_ids) = @_;

    my $query = '
      SELECT *
      FROM release_event
      LEFT JOIN area ON release_event.country = area.id
      WHERE release = any(?)
      ORDER BY
        date_year ASC NULLS LAST,
        date_month ASC NULLS LAST,
        date_day ASC NULLS LAST,
        area.name COLLATE musicbrainz ASC NULLS LAST
    ';

    my $events = $self->sql->select_list_of_hashes($query, \@release_ids);

    my %ret = map { $_ => [] } @release_ids;
    for my $event (@$events) {
        push @{ $ret{$event->{release}} },
            MusicBrainz::Server::Entity::ReleaseEvent->new(
                country_id => $event->{country},
                date => MusicBrainz::Server::Entity::PartialDate->new_from_row($event, 'date_')
            );
    }

    return \%ret;
}

sub set_release_events {
    my ($self, $release_id, $release_group_id, $events) = @_;

    my ($without_country, $with_country) = part { defined($_->country_id) } @$events;

    $self->sql->do('DELETE FROM release_country WHERE release = ?', $release_id);
    $self->sql->do('DELETE FROM release_unknown_country WHERE release = ?', $release_id);

    $self->sql->insert_many(
        'release_country',
        map +{
            release => $release_id,
            country => $_->country_id,
            date_year => $_->date->year,
            date_month => $_->date->month,
            date_day => $_->date->day
        }, @$with_country
    );

    $self->sql->insert_many(
        'release_unknown_country',
        map +{
            release => $release_id,
            date_year => $_->date->year,
            date_month => $_->date->month,
            date_day => $_->date->day
        }, @$without_country
    );

    # To ensure the new first release date is cached
    $self->c->model('ReleaseGroup')->_delete_from_cache($release_group_id);
}

sub series_ordering {
    my ($self, $r1, $r2) = @_;

    my @releases = ($r1->entity0, $r2->entity0);
    $self->load_release_events(@releases);

    my ($a_date) = sort { $a <=> $b } map { $_->date } $r1->entity0->all_events;
    my ($b_date) = sort { $a <=> $b } map { $_->date } $r2->entity0->all_events;
    my $empty = MusicBrainz::Server::Entity::PartialDate->new();
    my $cmp = ($a_date // $empty) <=> ($b_date // $empty);
    return $cmp if $cmp;

    $self->c->model('ReleaseLabel')->load(@releases);
    my ($a_catalog_number) = sort map { $_->catalog_number // '' } $r1->entity0->all_labels;
    my ($b_catalog_number) = sort map { $_->catalog_number // '' } $r2->entity0->all_labels;
    return ($a_catalog_number // '') cmp ($b_catalog_number // '');
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
