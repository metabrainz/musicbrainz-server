package MusicBrainz::Server::Data::Release;

use Moose;
use namespace::autoclean -also => [qw( _where_status_in _where_type_in )];

use Carp 'confess';
use DBDefs;
use List::AllUtils qw( all );
use List::MoreUtils qw( part );
use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Constants qw( :quality $EDIT_RELEASE_CREATE $STATUS_APPLIED );
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
use aliased 'MusicBrainz::Server::Entity::Artwork';

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'release' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'release' };
with 'MusicBrainz::Server::Data::Role::Collection';

use Readonly;
Readonly our $MERGE_APPEND => 1;
Readonly our $MERGE_MERGE => 2;

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
    my ($filter) = @_;

    my (@query, @joins, @params);

    if (defined $filter) {
        if (exists $filter->{name}) {
            push @query, "(to_tsvector('mb_simple', release.name) @@ plainto_tsquery('mb_simple', ?) OR release.name = ?)";
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

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                   JOIN release_event ON release.id = release_event.release
                   JOIN area ON release_event.country = area.id
                 WHERE area.id = ?
                 ORDER BY musicbrainz_collate(release.name), release.id";

    $self->query_to_list_limited($query, [$area_id], $limit, $offset);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "acn.artist = ?";
    push @$params, $artist_id;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day, area.name AS country_name
        FROM " . $self->_table . "
        JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
        " . join(' ', @$extra_joins) . "
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day,
          country_name, barcode, musicbrainz_collate(release.name)
      ) release
      ORDER BY date_year, date_month, date_day,
        country_name, barcode, musicbrainz_collate(name)";
    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "instrument.id = ?";
    push @$params, $instrument_id;

    # NOTE: if more tables than l_artist_release are added here, check admin/BuildSitemaps.pl
    my $query = "
      SELECT *
      FROM (
        SELECT " . $self->_columns . ",
          date_year, date_month, date_day,
          area.name AS country_name,
          array_agg(lac.credited_as) AS instrument_credits
        FROM " . $self->_table . "
        JOIN l_artist_release ON l_artist_release.entity1 = release.id
        JOIN link_attribute ON link_attribute.link = l_artist_release.link
        JOIN link_attribute_type ON link_attribute_type.id = link_attribute.attribute_type
        JOIN instrument ON instrument.gid = link_attribute_type.gid
        LEFT JOIN link_attribute_credit lac ON (
          lac.link = link_attribute.link AND
          lac.attribute_type = link_attribute.attribute_type
        )
        " . join(' ', @$extra_joins) . "
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
         WHERE " . join(" AND ", @$conditions) . "
        GROUP BY release.id, date_year, date_month, date_day, country_name
        ORDER BY release.id, date_year, date_month, date_day,
          musicbrainz_collate(release.name), country_name,
          barcode
      ) s
      ORDER BY date_year, date_month, date_day,
        musicbrainz_collate(name), country_name,
        barcode";

    $self->query_to_list_limited($query, $params, $limit, $offset, sub {
        my ($model, $row) = @_;

        my $credits = delete $row->{instrument_credits};
        { release => $model->_new_from_row($row), instrument_credits => $credits };
    });
}

sub find_by_label
{
    my ($self, $label_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "release_label.label = ?";
    push @$params, $label_id;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day, catalog_number,
          area.name AS country_name
        FROM " . $self->_table . "
        JOIN release_label ON release_label.release = release.id
        " . join(' ', @$extra_joins) . "
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
         WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day, catalog_number,
          musicbrainz_collate(release.name), country_name,
          barcode
      ) s
      ORDER BY date_year, date_month, date_day, catalog_number,
        musicbrainz_collate(name), country_name,
        barcode";
    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_disc_id
{
    my ($self, $disc_id) = @_;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day
        FROM " . $self->_table . "
        JOIN medium ON medium.release = release.id
        JOIN medium_cdtoc ON medium_cdtoc.medium = medium.id
        JOIN cdtoc ON medium_cdtoc.cdtoc = cdtoc.id
        LEFT JOIN release_event ON release_event.release = release.id
        WHERE cdtoc.discid = ?
        ORDER BY release.id, date_year, date_month, date_day,
          musicbrainz_collate(release.name)
      ) s
      ORDER BY date_year, date_month, date_day,
        musicbrainz_collate(name)";

    $self->query_to_list($query, [$disc_id]);
}

sub find_by_release_group
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "release_group IN (" . placeholders(@ids) . ")";
    push @$params, @ids;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id) " . $self->_columns . ",
          date_year, date_month, date_day, area.name AS country_name
        FROM " . $self->_table . "
        " . join(' ', @$extra_joins) . "
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day,
          country_name, barcode
      ) s
      ORDER BY date_year, date_month, date_day,
        country_name, barcode
    ";

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_track_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "
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
             WHERE acn.artist = ?)";
    push @$params, $artist_id, $artist_id;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day
          FROM " . $self->_table . "
          " . join(' ', @$extra_joins) . "
          LEFT JOIN release_event ON release_event.release = release.id
          LEFT JOIN area ON area.id = release_event.country
          WHERE " . join(" AND ", @$conditions) . "
          ORDER BY release.id, date_year, date_month, date_day,
            musicbrainz_collate(release.name)
      ) s
      ORDER BY date_year, date_month, date_day,
        musicbrainz_collate(name)";

    $self->query_to_list_limited($query, $params, $limit, $offset);
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
                ON tr.medium = medium.id
                JOIN artist_credit_name acn
                ON acn.artist_credit = tr.artist_credit
            WHERE acn.artist = ?)";
    push @$params, $artist_id, $artist_id;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day
        FROM " . $self->_table . "
        JOIN artist_credit_name acn
          ON acn.artist_credit = release.artist_credit
        " . join(' ', @$extra_joins) . "
        LEFT JOIN release_event ON release_event.release = release.id
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id,
          date_year, date_month, date_day, musicbrainz_collate(release.name)
      ) release
      ORDER BY date_year, date_month, date_day, musicbrainz_collate(name)";

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_recording
{
    my ($self, $ids, $limit, $offset, %args) = @_;
    my @ids = ref $ids ? @$ids : ( $ids );

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "track.recording IN (" . placeholders(@ids) . ")";
    push @$params, @ids;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day
        FROM " . $self->_table . "
        " . join(' ', @$extra_joins) . "
        JOIN medium ON medium.release = release.id
        JOIN track ON track.medium = medium.id
        LEFT JOIN release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day,
          musicbrainz_collate(release.name)
      ) s
      ORDER BY date_year, date_month, date_day,
        musicbrainz_collate(name)
    ";

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_by_recordings
{
    my ($self, @ids) = @_;
    return () unless @ids;

    my $query =
        "SELECT DISTINCT ON (release.id, track.recording) " . $self->_columns . ",
                track.recording, track.position
           FROM release
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
          WHERE track.recording IN (" . placeholders(@ids) . ")";

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        $map{ $row->{recording} } ||= [];
        push @{ $map{ $row->{recording} } },
            [ $self->_new_from_row($row),
              $self->c->model('Track')->_new_from_row({
                  position => $row->{position}
              }) ];
    }

    return %map;
}

sub find_by_country
{
    my ($self, $country_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "release_event.country = ?";
    push @$params, $country_id;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day, area.name AS country_name
        FROM " . $self->_table . "
        JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
        " . join(' ', @$extra_joins) . "
        LEFT JOIN (
          SELECT release, country, date_year, date_month, date_day
          FROM release_country
        ) release_event ON release_event.release = release.id
        LEFT JOIN area ON area.id = release_event.country
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day,
          country_name, barcode, musicbrainz_collate(release.name)
      ) release
      ORDER BY date_year, date_month, date_day,
        country_name, barcode, musicbrainz_collate(name)";

    $self->query_to_list_limited($query, $params, $limit, $offset);
}

sub find_for_cdtoc
{
    my ($self, $artist_id, $track_count, $limit, $offset) = @_;

    my $query = "
      SELECT *
      FROM (
        SELECT DISTINCT ON (release.id)
          " . $self->_columns . ",
          date_year, date_month, date_day
        FROM " . $self->_table . "
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
          AND (medium_format.id IS NULL OR medium_format.has_discids)
        ORDER BY release.id, release.release_group,
          date_year, date_month, date_day, musicbrainz_collate(release.name)
      ) s
      ORDER BY release_group,
          date_year, date_month, date_day, musicbrainz_collate(name)";

    $self->query_to_list_limited($query, [$track_count, $artist_id], $limit, $offset);
}

sub find_gid_for_track
{
    my ($self, $track_id) = @_;

    # A track is not a user visible entity, this function is called by
    # the track controller to issue a redirect to the release page
    # on which the track appears.  So only the release MBID is needed.

    my $query =
        "SELECT release.gid
           FROM release
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
          WHERE track.id = ?";

    return $self->sql->select_single_value($query, $track_id);
}

sub load_with_medium_for_recording
{
    my ($self, $recording_id, $limit, $offset, %args) = @_;

    my ($conditions, $extra_joins, $params) = _where_filter($args{filter});

    push @$conditions, "track.recording = ?";
    push @$params, $recording_id;

    my $query = "
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
        " . join(' ', @$extra_joins) . "
        WHERE " . join(" AND ", @$conditions) . "
        ORDER BY release.id, date_year, date_month, date_day,
          musicbrainz_collate(release.name)
      ) s
      ORDER BY date_year, date_month, date_day,
        musicbrainz_collate(r_name)";

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
    my ($self, @medium_ids) = @_;

    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE release.id IN (
                    SELECT release FROM medium
                     WHERE medium.id = any(?)
                )';

    $self->query_to_list($query, [\@medium_ids]);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = "";
    my $also_select = "";

    my $order_by = order_by($order, "date", {
        "date" => sub {
            return "date_year, date_month, date_day, musicbrainz_collate(name)"
        },
        "title" => sub {
            return "musicbrainz_collate(name), date_year, date_month, date_day"
        },
        "country" => sub {
            $extra_join = "LEFT JOIN area ON release_event.country = area.id";
            $also_select = "area.name AS country_name";
            return "country_name, date_year, date_month, date_day";
        },
        "artist" => sub {
            $extra_join = "JOIN artist_credit ac ON ac.id = release.artist_credit";
            $also_select = "ac.name AS ac_name";
            return "musicbrainz_collate(ac_name), musicbrainz_collate(name)";
        },
        "label" => sub {
            $extra_join = "LEFT OUTER JOIN
                (SELECT release, array_agg(musicbrainz_collate(label.name)) AS labels FROM release_label
                    JOIN label ON release_label.label = label.id
                    GROUP BY release) rl
                ON rl.release = release.id";
            $also_select = "rl.labels AS labels";
            return "labels, musicbrainz_collate(name)";
        },
        "catno" => sub {
            $extra_join = "LEFT OUTER JOIN
                (SELECT release, array_agg(catalog_number) AS catnos from release_label
                  WHERE catalog_number IS NOT NULL GROUP BY release) rl
                ON rl.release = release.id";
            $also_select = "catnos";
            return "catnos, musicbrainz_collate(name)";
        },
        "format" => sub {
            $extra_join = "JOIN medium ON medium.release = release.id
                           LEFT JOIN medium_format ON medium.format = medium_format.id";
            $also_select = "medium_format.name AS medium_format_name";
            return "medium_format_name, musicbrainz_collate(name)";
        },
        "tracks" => sub {
            $extra_join = "JOIN
                (SELECT medium.release, sum(track_count) AS total_track_count
                    FROM medium
                    GROUP BY medium.release) medium
                ON medium.release = release.id";
            $also_select = "total_track_count";
            return "total_track_count, musicbrainz_collate(name)";
        },
        "barcode" => sub {
            return "length(barcode), barcode, musicbrainz_collate(name)"
        },
    });

    # Date and release event information should always be included.
    if ($also_select ne "") {
        $also_select .= ", ";
    }
    $also_select .= "date_year, date_month, date_day";

    $extra_join = "LEFT JOIN release_event ON release_event.release = release.id " . $extra_join;

    return ($order_by, $extra_join, $also_select);
}

sub _insert_hook_after_each {
    my ($self, $created, $release) = @_;

    $self->set_release_events(
        $created->{id}, _release_events_from_spec($release->{events} // [])
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

    $self->set_release_events(
        $release_id, _release_events_from_spec($update->{events})
    ) if $update->{events};

    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('release', $row, { id => $release_id }) if %$row;

    if ($update->{events} || $update->{name}) {
        $self->c->model('Series')->reorder_for_entities('release', $release_id);
    }

    if ($update->{events} || $update->{release_group_id}) {
        my $release_group_id = $update->{release_group_id} // $self->sql->select_single_value(
            'SELECT release_group FROM release WHERE id = ?', $release_id
        );
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
                 SELECT medium.id, medium.position, medium.track_count
                 FROM medium
                 WHERE release IN (' . placeholders(@old_ids) . ')
             ) s
             LEFT JOIN medium new_medium ON
                 (new_medium.position = s.position AND new_medium.release = ?)
             WHERE new_medium.track_count <> s.track_count
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
        my $track_count = $mediums[0]->track_count;
        next if grep { $_->track_count != $track_count } @mediums;
        # group recordings by track position
        $recording_by_position{$m_pos} = {};
        for my $medium (@mediums) {
            for my $tr ($medium->all_tracks) {
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
        my $q = "WITH new_positions (medium, position) AS " .
                "(VALUES " . join(', ', ('(?::integer,?::integer)') x keys %positions_by_medium) .") " .
                "UPDATE medium SET release = ?, position = new_positions.position " .
                "FROM new_positions WHERE medium.id = new_positions.medium";
        $self->sql->do($q, %positions_by_medium, $new_id);

        if ($update_names) {
            foreach my $id (map { $_->{id} } @existing_mediums) {
                next unless exists $names{$id};
                $self->sql->do('UPDATE medium SET name = ? WHERE id = ?', $names{$id}, $id);
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
                        oldmed.id AS old_id
                   FROM medium newmed, medium oldmed
                  WHERE newmed.release = ?
                    AND oldmed.release IN (' . placeholders(@old_ids) . ')
                    AND newmed.position = oldmed.position',
                $new_id, @old_ids
            )
        };
        for my $merge (@merges) {
            $self->c->model('Medium')->merge($merge->{new_id}, $merge->{old_id});
            $self->c->model('MediumCDTOC')->merge_mediums(
                $merge->{new_id},
                $merge->{old_id}
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
             FROM (VALUES ' . join(', ', ("(?::uuid, ?)") x @barcodes) . ') change (release, barcode)
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
      FROM ' . $self->_table . '
      JOIN cover_art_archive.cover_art ON (cover_art.release = release.id)
      JOIN cover_art_archive.cover_art_type
        ON (cover_art.id = cover_art_type.id)
      JOIN edit_release ON edit_release.release = release.id
      JOIN edit ON edit.id = edit_release.edit
      WHERE cover_art_type.type_id = ?
        AND cover_art.ordering = 1
        AND edit.type = ?
      ORDER BY edit.id DESC
      LIMIT 10';

    my $FRONT = 1;
    $self->query_to_list($query, [$FRONT, $EDIT_RELEASE_CREATE], sub {
        my ($model, $row) = @_;

        my $release = $model->_new_from_row($row);
        my $mbid = $release->gid;
        my $caa_id = $row->{cover_art_id};

        {
            release => $release,
            artwork => Artwork->new(
                id => $caa_id,
                release => $release,
            ),
        };
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

    my $query = "
      SELECT *
      FROM release_event
      LEFT JOIN area ON release_event.country = area.id
      WHERE release = any(?)
      ORDER BY
        date_year ASC NULLS LAST,
        date_month ASC NULLS LAST,
        date_day ASC NULLS LAST,
        musicbrainz_collate(area.name) ASC NULLS LAST
    ";

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
    my ($self, $release_id, $events) = @_;

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
