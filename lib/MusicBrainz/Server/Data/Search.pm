package MusicBrainz::Server::Data::Search;

use Carp;
use Try::Tiny;
use Moose;
use Class::Load qw( load_class );
use JSON;
use Sql;
use Readonly;
use Data::Page;
use URI::Escape qw( uri_escape_utf8 );
use List::AllUtils qw( any partition_by );
use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::AreaType;
use MusicBrainz::Server::Entity::ArtistType;
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::Event;
use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Entity::ISRC;
use MusicBrainz::Server::Entity::ISWC;
use MusicBrainz::Server::Entity::Instrument;
use MusicBrainz::Server::Entity::InstrumentType;
use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Entity::LabelType;
use MusicBrainz::Server::Entity::Language;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::Place;
use MusicBrainz::Server::Entity::PlaceType;
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Entity::MediumFormat;
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::ReleaseLabel;
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Entity::ReleaseGroupType;
use MusicBrainz::Server::Entity::ReleaseGroupSecondaryType;
use MusicBrainz::Server::Entity::ReleaseStatus;
use MusicBrainz::Server::Entity::ReleasePackaging;
use MusicBrainz::Server::Entity::Script;
use MusicBrainz::Server::Entity::Series;
use MusicBrainz::Server::Entity::SeriesOrderingType;
use MusicBrainz::Server::Entity::SeriesType;
use MusicBrainz::Server::Entity::SearchResult;
use MusicBrainz::Server::Entity::WorkLanguage;
use MusicBrainz::Server::Entity::WorkType;
use MusicBrainz::Server::Exceptions;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Data::Event;
use MusicBrainz::Server::Data::Instrument;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Series;
use MusicBrainz::Server::Data::Tag;
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Constants qw( entities_with $DARTIST_ID $DLABEL_ID );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::ExternalUtils qw( get_chunked_with_retry );
use DateTime::Format::ISO8601;
use feature 'switch';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Data::Entity';

use Sub::Exporter -setup => {
    exports => [qw( escape_query )]
};

sub search
{
    my ($self, $type, $query_str, $limit, $offset, $where) = @_;
    return ([], 0) unless $query_str && $type;

    $offset ||= 0;

    my $query;
    my $use_hard_search_limit = 1;
    my $hard_search_limit;
    my $deleted_entity = undef;

    my @where_args;

    if ($type eq 'artist') {

        my $where_deleted = 'WHERE entity.id != ?';
        $deleted_entity = $DARTIST_ID;

        my $extra_columns = 'entity.gender, entity.area, entity.begin_area, entity.end_area,' if $type eq 'artist';

        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.name,
                entity.comment,
                entity.sort_name,
                entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day,
                entity.ended,
                $extra_columns
                MAX(rank) AS rank
            FROM
                (
                    SELECT name, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank
                    FROM
                        (SELECT name              FROM ${type}       UNION ALL
                         SELECT sort_name AS name FROM ${type}       UNION ALL
                         SELECT name              FROM ${type}_alias UNION ALL
                         SELECT sort_name AS name FROM ${type}_alias) names,
                        plainto_tsquery('mb_simple', mb_lower(?)) AS query
                    WHERE mb_simple_tsvector(name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                LEFT JOIN ${type}_alias AS alias ON (alias.name = r.name OR alias.sort_name = r.name)
                JOIN ${type} AS entity ON (r.name = entity.name OR r.name = entity.sort_name OR alias.${type} = entity.id)
                $where_deleted
            GROUP BY
                entity.id, entity.gid, entity.comment, entity.name, entity.sort_name, entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended
            ORDER BY
                rank DESC, sort_name, name, entity.gid
            OFFSET
                ?
        ";

        $hard_search_limit = $offset * 2;
    }
    elsif ($type ~~ [qw(recording release release_group)]) {
        my $extra_columns = '';
        $extra_columns .= 'entity.type AS primary_type_id,'
            if ($type eq 'release_group');

        $extra_columns = 'entity.length, entity.video,'
            if ($type eq 'recording');

        $extra_columns .= 'entity.language, entity.script, entity.barcode,
                           entity.release_group, entity.status,'
            if ($type eq 'release');

        my $extra_ordering = '';
        $extra_columns .= 'entity.artist_credit AS artist_credit_id,';
        $extra_ordering = ', entity.artist_credit';

        my ($join_sql, $where_sql)
            = (
                "LEFT JOIN ${type}_alias AS alias ON (alias.name = r.name OR alias.sort_name = r.name)
                JOIN ${type} entity ON (r.name = entity.name OR alias.${type} = entity.id)",
                ''
            );

        if ($type eq 'release' && $where && exists $where->{track_count}) {
            $join_sql .= ' JOIN medium ON medium.release = entity.id';
            $where_sql = 'WHERE track_count_matches_cdtoc(medium, ?)';
            push @where_args, $where->{track_count};
        }
        elsif ($type eq 'recording') {
            if ($where && exists $where->{artist})
            {
                $join_sql .= ' JOIN artist_credit ON artist_credit.id = entity.artist_credit';
                $where_sql = 'WHERE artist_credit.name LIKE ?';
                push @where_args, '%'.$where->{artist}.'%';
            }
        }
        my $extra_groupby_columns = $extra_columns =~ s/[^ ,]+ AS //gr;

        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.name,
                entity.comment,
                $extra_columns
                MAX(rank) AS rank
            FROM
                (
                    SELECT name, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank
                    FROM
                        (SELECT name              FROM ${type}       UNION ALL
                         SELECT name              FROM ${type}_alias UNION ALL
                         SELECT sort_name AS name FROM ${type}_alias) names,
                        plainto_tsquery('mb_simple', mb_lower(?)) AS query
                    WHERE mb_simple_tsvector(name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                $join_sql
                $where_sql
            GROUP BY
                $extra_groupby_columns entity.id, entity.gid, entity.name, entity.comment
            ORDER BY
                rank DESC, entity.name
                ${extra_ordering}, entity.gid
            OFFSET
                ?
        ";

        $hard_search_limit = int($offset * 1.2);
    }

    elsif ($type ~~ [qw(area event instrument label place series work)]) {
        my $where_deleted = 'WHERE entity.id != ?';
        if ($type eq 'label') {
            $deleted_entity = $DLABEL_ID;
        } else {
            $where_deleted = '';
        }

        my $extra_columns = '';
        $extra_columns .= 'entity.address, entity.area, entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended,' if $type eq 'place';
        $extra_columns .= 'entity.description,' if $type eq 'instrument';
        $extra_columns .= 'iso_3166_1s.codes AS iso_3166_1, iso_3166_2s.codes AS iso_3166_2, iso_3166_3s.codes AS iso_3166_3,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended,' if $type eq 'area';
        $extra_columns .= 'entity.label_code, entity.area, entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended,' if $type eq 'label';
        $extra_columns .= 'entity.ordering_type,' if $type eq 'series';
        $extra_columns .= 'entity.time, entity.cancelled, entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended,' if $type eq 'event';

        my $extra_groupby_columns = $extra_columns =~ s/[^ ,]+ AS //gr;

        my $extra_joins = '';
        if ($type eq 'area') {
            $extra_joins .= 'LEFT JOIN (SELECT area, array_agg(code) AS codes FROM iso_3166_1 GROUP BY area) iso_3166_1s ON iso_3166_1s.area = entity.id ' .
                            'LEFT JOIN (SELECT area, array_agg(code) AS codes FROM iso_3166_2 GROUP BY area) iso_3166_2s ON iso_3166_2s.area = entity.id ' .
                            'LEFT JOIN (SELECT area, array_agg(code) AS codes FROM iso_3166_3 GROUP BY area) iso_3166_3s ON iso_3166_3s.area = entity.id';
        }

        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.name,
                entity.comment,
                entity.type,
                $extra_columns
                MAX(rank) AS rank
            FROM
                (
                    SELECT name, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank
                    FROM
                        (SELECT name              FROM ${type}       UNION ALL
                         SELECT name              FROM ${type}_alias UNION ALL
                         SELECT sort_name AS name FROM ${type}_alias) names,
                        plainto_tsquery('mb_simple', mb_lower(?)) AS query
                    WHERE mb_simple_tsvector(name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                LEFT JOIN ${type}_alias AS alias ON (alias.name = r.name OR alias.sort_name = r.name)
                JOIN ${type} AS entity ON (r.name = entity.name OR alias.${type} = entity.id)
                $extra_joins
                $where_deleted
            GROUP BY
                $extra_groupby_columns entity.id, entity.gid, entity.name, entity.comment, entity.type
            ORDER BY
                rank DESC, entity.name, entity.gid
            OFFSET
                ?
        ";

        $hard_search_limit = $offset * 2;
    }

    elsif ($type eq 'genre') {

        $query = q{
            SELECT
                entity.id,
                entity.gid,
                entity.name,
                entity.comment,
                MAX(rank) AS rank
            FROM
                (
                    SELECT name, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank
                    FROM genre,
                        plainto_tsquery('mb_simple', mb_lower(?)) AS query
                    WHERE mb_simple_tsvector(name) @@ query
                    ORDER BY rank DESC
                ) AS r
                JOIN genre AS entity ON r.name = entity.name
            GROUP BY
                entity.id, entity.gid, entity.name, entity.comment
            ORDER BY
                rank DESC, entity.name, entity.gid
            OFFSET
                ?
            };

        $use_hard_search_limit = 0;
    }

    elsif ($type eq 'tag') {
        $query = q{
            SELECT tag.id, tag.name, genre.id AS genre_id,
                   ts_rank_cd(mb_simple_tsvector(tag.name), query, 2) AS rank
            FROM tag LEFT JOIN genre USING (name), plainto_tsquery('mb_simple', mb_lower(?)) AS query
            WHERE mb_simple_tsvector(tag.name) @@ query
            ORDER BY rank DESC, tag.name
            OFFSET ?
            };

        $use_hard_search_limit = 0;
    }
    elsif ($type eq 'editor') {
        $query = q{
            SELECT id, name, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank,
            email
            FROM editor, plainto_tsquery('mb_simple', mb_lower(?)) AS query
            WHERE mb_simple_tsvector(name) @@ query
            ORDER BY rank DESC
            OFFSET ?
            };

        $use_hard_search_limit = 0;
    }

    if ($use_hard_search_limit) {
        $hard_search_limit += $limit * 3;
    }

    my $fuzzy_search_limit = 10000;
    my @query_args = ();
    push @query_args, $hard_search_limit if $use_hard_search_limit;
    push @query_args, $deleted_entity if $deleted_entity;
    push @query_args, @where_args;
    push @query_args, $offset;

    my @result;
    my $pos = $offset + 1;
    my @rows;

    Sql::run_in_transaction(sub {
        $self->sql->do('SET LOCAL gin_fuzzy_search_limit TO ?', $fuzzy_search_limit);
        @rows = @{ $self->sql->select_list_of_hashes($query, $query_str, @query_args) };
    }, $self->sql);

    for my $row (@rows) {
        last unless ($limit--);

        my $model = 'MusicBrainz::Server::Data::' . type_to_model($type);

        my $res = MusicBrainz::Server::Entity::SearchResult->new(
            position => $pos++,
            score => int(1000 * $row->{rank}),
            entity => $model->_new_from_row($row)
        );
        push @result, $res;
    }

    my $hits = @rows + $offset;

    return (\@result, $hits);

}

# ---------------- External (Indexed) Search ----------------------

# The XML schema uses a slightly different terminology for things
# and the schema defines how data is passed between the main
# server and the search server. In order to shove the dat back into
# the object model, we need to do some ugly ass tweaking....

# The mapping of XML/JSON centric terms to object model terms.
my %mapping = (
    'disambiguation' => 'comment',
    'sort-name'      => 'sort_name',
    'title'          => 'name',
    'artist-credit'  => 'artist_credit',
    'label-code'     => 'label_code',
);

sub schema_fixup_type {
    my ($self, $data, $type) = @_;
    if (defined $data->{type} && $type ~~ [ entities_with(['type', 'simple']) ]) {
        my $model = 'MusicBrainz::Server::Entity::' . type_to_model($type) . 'Type';
        $data->{type} = $model->new( name => $data->{type} );
    }
    return $data;
}

# Fix up the key names so that the data returned from the JSON service
# matches up with the data returned from the DB for easy object creation
sub schema_fixup
{
    my ($self, $data, $type) = @_;

    return unless (ref($data) eq 'HASH');

    # Special case to handle the ids
    $data->{gid} = $data->{id};
    $data->{id} = 1;

    # MusicBrainz::Server::Entity::Role::Taggable expects 'tags' to contain an ArrayRef[AggregatedTag].
    # If tags are required in search results they will need to be listed under a different key value.
    delete $data->{tags};

    foreach my $k (keys %mapping)
    {
        if (defined $data->{$k})
        {
            $data->{$mapping{$k}} = $data->{$k} if ($mapping{$k});
            delete $data->{$k};
        }
    }

    $data = $self->schema_fixup_type($data, $type);

    if ($type eq 'place' && defined $data->{coordinates})
    {
        $data->{coordinates} = MusicBrainz::Server::Entity::Coordinates->new( $data->{coordinates} );
    }
    if (($type ~~ [qw(artist event label area place)]) && defined $data->{'life-span'})
    {
        $data->{begin_date} = MusicBrainz::Server::Entity::PartialDate->new($data->{'life-span'}->{begin})
            if (defined $data->{'life-span'}->{begin});
        $data->{end_date} = MusicBrainz::Server::Entity::PartialDate->new($data->{'life-span'}->{end})
            if (defined $data->{'life-span'}->{end});
        $data->{ended} = $data->{'life-span'}->{ended} == 1
            if defined $data->{'life-span'}->{ended};
    }
    if ($type eq 'area') {
        for my $prop (qw( iso_3166_1 iso_3166_2 iso_3166_3 )) {
            my $json_prop = ($prop =~ tr/_/-/r) . '-codes';
            if (defined $data->{$json_prop}) {
                $data->{$prop} = $data->{$json_prop};
                delete $data->{$json_prop};
            }
        }
    }
    if ($type eq 'artist' || $type eq 'label' || $type eq 'place') {
        for my $prop (qw( area begin_area end_area )) {
            my $json_prop = $prop =~ tr/_/-/r;
            if (defined $data->{$json_prop})
            {
                my $area = delete $data->{$json_prop};
                $area = $self->schema_fixup_type($area, 'area');
                $area->{gid} = $area->{id};
                $area->{id} = 1;
                $data->{$prop} = MusicBrainz::Server::Entity::Area->new($area);
            }
        }
    }
    if ($type eq 'artist' && defined $data->{gender}) {
        $data->{gender} = MusicBrainz::Server::Entity::Gender->new( name => ucfirst($data->{gender}) );
    }
    if ($type eq 'cdstub' && defined $data->{gid})
    {
        $data->{barcode} = MusicBrainz::Server::Entity::Barcode->new($data->{barcode});
        $data->{comment} = (delete $data->{comment}) // '';
        $data->{discid} = delete $data->{gid};
        $data->{title} = delete $data->{name};
        $data->{track_count} = delete $data->{count};
        delete $data->{id};
    }
    if ($type eq 'annotation' && defined $data->{entity})
    {
        my $parent_type = $data->{type};
        $parent_type =~ s/-/_/g;
        my $entity_model = $self->c->model( type_to_model($parent_type) )->_entity_class;
        $data->{parent} = $entity_model->new( { name => $data->{name}, gid => $data->{entity} });
        delete $data->{entity};
        delete $data->{type};
    }
    if ($type eq 'release')
    {
        if (defined $data->{'release-events'})
        {
            $data->{events} = [];
            for my $release_event_data (@{$data->{'release-events'}})
            {
                my $release_event = MusicBrainz::Server::Entity::ReleaseEvent->new(
                    country => defined($release_event_data->{area}) ?
                        MusicBrainz::Server::Entity::Area->new( gid => $release_event_data->{area}->{id},
                                                                iso_3166_1 => $release_event_data->{area}->{'iso-3166-1-codes'},
                                                                name => $release_event_data->{area}->{name} )
                        : undef,
                    date => MusicBrainz::Server::Entity::PartialDate->new( $release_event_data->{date} ));

                push @{$data->{events}}, $release_event;
            }
            delete $data->{'release-events'};
        }
        if (defined $data->{barcode})
        {
            $data->{barcode} = MusicBrainz::Server::Entity::Barcode->new( $data->{barcode} );
        }
        if (defined $data->{'text-representation'} &&
            defined $data->{'text-representation'}->{language})
        {
            $data->{language} = $self->c->model('Language')->find_by_code(
                $data->{'text-representation'}{language}
            );
        }
        if (defined $data->{'text-representation'} &&
            defined $data->{'text-representation'}->{script})
        {
            $data->{script} = $self->c->model('Script')->find_by_code(
                $data->{'text-representation'}{script}
            );
        }

        if ($data->{'label-info'}) {
            $data->{labels} = [
                map {
                    MusicBrainz::Server::Entity::ReleaseLabel->new(
                        label => $_->{label}->{id} &&
                            MusicBrainz::Server::Entity::Label->new(
                                name => $_->{label}->{name},
                                gid => $_->{label}->{id}
                            ),
                        catalog_number => $_->{'catalog-number'}
                    )
                } @{ $data->{'label-info'}}
            ];
        }

        if (defined $data->{'media'})
        {
            $data->{mediums} = [];
            for my $medium_data (@{$data->{'media'}})
            {
                my $format = $medium_data->{format};
                my $medium = MusicBrainz::Server::Entity::Medium->new(
                    track_count => $medium_data->{'track-count'},
                    format => $format &&
                        MusicBrainz::Server::Entity::MediumFormat->new(
                            name => $format
                        )
                );

                push @{$data->{mediums}}, $medium;
            }
            $data->{mediums_loaded} = 1;
            delete $data->{'media'};
        }

        my $release_group = delete $data->{'release-group'};

        $data->{release_group} = MusicBrainz::Server::Entity::ReleaseGroup->new(
            fixup_rg($release_group)
        );

        if ($data->{status}) {
            $data->{status} = MusicBrainz::Server::Entity::ReleaseStatus->new(
                name => delete $data->{status}
            )
        }

        my $packaging = delete $data->{packaging};
        my $packaging_id = delete $data->{'packaging-id'};

        if ($packaging) {
            if (ref($packaging) eq 'HASH') {
                # MB Solr search server v3.1
                $data->{packaging} = MusicBrainz::Server::Entity::ReleasePackaging->new(
                    name => $packaging->{name},
                    defined $packaging->{id} ? (gid => $packaging->{id}) : ()
                )
            } elsif ($packaging_id) {
                # MB Solr search server v3.2? (SOLR-121)
                $data->{packaging} = MusicBrainz::Server::Entity::ReleasePackaging->new(
                    name => $packaging,
                    gid => $packaging_id
                )
            } else {
                # MB Lucene search server
                $data->{packaging} = MusicBrainz::Server::Entity::ReleasePackaging->new(
                    name => $packaging
                )
            }
        }
    }
    if ($type eq 'release-group') {
        fixup_rg($data, $data);
    }
    if ($type eq 'recording' &&
        defined $data->{'releases'} &&
        defined $data->{'releases'}->[0] &&
        defined $data->{'releases'}->[0]->{'media'} &&
        defined $data->{'releases'}->[0]->{'media'}->[0])
    {
        my @releases;

        foreach my $release (@{$data->{'releases'}})
        {
            my $medium = MusicBrainz::Server::Entity::Medium->new(
                position  => $release->{'media'}->[0]->{'position'},
                track_count => $release->{'media'}->[0]->{'track-count'},
                tracks => [ MusicBrainz::Server::Entity::Track->new(
                    position => $release->{'media'}->[0]->{'track-offset'} + 1,
                    recording => MusicBrainz::Server::Entity::Recording->new(
                        gid => $data->{gid}
                    )
                ) ]
            );
            my $release_group = MusicBrainz::Server::Entity::ReleaseGroup->new(
                fixup_rg($release->{'release-group'})
            );
            push @releases, {
                release            => MusicBrainz::Server::Entity::Release->new(
                    gid            => $release->{id},
                    name           => $release->{title},
                    mediums        => [ $medium ],
                    release_group  => $release_group
                ),
                track_position      => $medium->{tracks}->[0]->{position},
                medium_position     => $medium->{position},
                medium_track_count  => $medium->{track_count}
            };
        }
        $data->{_extra} = \@releases;
    }

    if ($type eq 'recording' && defined $data->{'isrcs'}) {
        $data->{isrcs} = [
            map { MusicBrainz::Server::Entity::ISRC->new(
                isrc => (DBDefs->SEARCH_ENGINE eq 'LUCENE') ? $_->{id} : $_
            ) } @{ $data->{'isrcs'} }
        ];
    }

    if ($type eq 'recording') {
        $data->{video} = defined $data->{video} && $data->{video} == 1;
    }

    if (defined $data->{'relations'} &&
        defined $data->{'relations'}->[0])
    {
        my @relationships;

        foreach my $rel (@{ $data->{'relations'} })
        {
            my $target_type;
            for (entities_with(['mbid', 'relatable'], take => 'url')) {
                if (exists $rel->{$_}) {
                    $target_type = $_;
                    last;
                }
            }

            my $entity_type = $target_type;

            my %entity = %{ $rel->{$entity_type} };

            $self->schema_fixup(\%entity, $entity_type);

            # The search server returns the MBID in the 'id' attribute, so we
            # need to delete that. (`schema_fixup` copies it to gid.)
            delete $entity{id};

            my $entity = $self->c->model( type_to_model ($entity_type) )->
                _entity_class->new(%entity);

            push @relationships, MusicBrainz::Server::Entity::Relationship->new(
                entity1 => $entity,
                target => $entity,
                target_type => $entity->entity_type,
                link => MusicBrainz::Server::Entity::Link->new(
                    type => MusicBrainz::Server::Entity::LinkType->new(
                        entity1_type => $entity_type,
                        name => $rel->{type}
                    )
                )
            );
        }

        $data->{relationships} = \@relationships;
    }


    foreach my $k (keys %{$data})
    {
        next if $k eq '_extra';
        if (ref($data->{$k}) eq 'HASH')
        {
            $self->schema_fixup($data->{$k}, $type);
        }
        if (ref($data->{$k}) eq 'ARRAY')
        {
            foreach my $item (@{$data->{$k}})
            {
                $self->schema_fixup($item, $type);
            }
        }
    }

    if (defined $data->{'artist_credit'}) {
        my @credits;
        foreach my $namecredit (@{$data->{'artist_credit'}})
        {
            my $artist = MusicBrainz::Server::Entity::Artist->new($namecredit->{artist});
            push @credits, MusicBrainz::Server::Entity::ArtistCreditName->new( {
                    artist => $artist,
                    name => $namecredit->{name} || $artist->{name},
                    join_phrase => $namecredit->{joinphrase} || '' } );
        }
        $data->{'artist_credit'} = MusicBrainz::Server::Entity::ArtistCredit->new( { names => \@credits } );
    }

    if ($type eq 'work') {
        if (defined $data->{relationships}) {
            my %relationship_map = partition_by { $_->entity1->gid }
                @{ $data->{relationships} };

            $data->{writers} = [
                map {
                    my @relationships = @{ $relationship_map{$_} };
                    {
                        # TODO: Pass the actual credit when SEARCH-585 is fixed
                        credit => '',
                        entity => $relationships[0]->entity1,
                        roles  => [ map { $_->link->type->name } grep { $_->link->type->entity1_type eq 'artist' } @relationships ]
                    }
                } grep {
                    my @relationships = @{ $relationship_map{$_} };
                    any { $_->link->type->entity1_type eq 'artist' } @relationships;
                } keys %relationship_map
            ];
        }

        my @languages = @{ $data->{languages} // [] };
        if (!@languages && defined $data->{language}) {
            push @languages, $data->{language};
        }

        if (@languages) {
            $data->{languages} = [map {
                MusicBrainz::Server::Entity::WorkLanguage->new({
                    language => $self->c->model('Language')->find_by_code($_),
                })
            } @languages];
        }

        if (defined $data->{'iswcs'}) {
            $data->{iswcs} = [
                map {
                    MusicBrainz::Server::Entity::ISWC->new( iswc => $_ )
                } @{ $data->{'iswcs'} }
            ]
        }
    }
}

sub fixup_rg {
    my $release_group = shift;
    my $rg_args = shift // {};
        # can be passed as a parameter for in-place modification

    if ($release_group->{'primary-type'}) {
        $rg_args->{primary_type} =
            MusicBrainz::Server::Entity::ReleaseGroupType->new(
                name => $release_group->{'primary-type'}
            );
    }

    if ($release_group->{'secondary-types'}) {
        $rg_args->{secondary_types} = [
            map {
                MusicBrainz::Server::Entity::ReleaseGroupSecondaryType->new(
                    name => $_
                )
            } @{ $release_group->{'secondary-types'} }
        ]
    }

    return %$rg_args;
}

# Escape special characters in a Lucene search query
sub escape_query
{
    my $str = shift;

    return '' unless defined $str;

    $str =~  s/([+\-&|!(){}\[\]\^"~*?:\\\/])/\\$1/g;
    return $str;
}

sub external_search
{
    my ($self, $type, $query, $limit, $page, $adv) = @_;

    my $entity_model = $self->c->model( type_to_model($type) )->_entity_class;
    load_class($entity_model);
    my $offset = ($page - 1) * $limit;

    $query = uri_escape_utf8($query);
    $type =~ s/release_group/release-group/;

    my $search_url_string;
    if (DBDefs->SEARCH_ENGINE eq 'LUCENE' || DBDefs->SEARCH_SERVER eq DBDefs::Default->SEARCH_SERVER) {
        my $dismax = $adv ? 'false' : 'true';
        $search_url_string = "http://%s/ws/2/%s/?query=%s&offset=%s&max=%s&fmt=jsonnew&dismax=$dismax&web=1";
    } else {
        my $endpoint = 'advanced';
        if (!$adv)
        {
            # Solr has a bug where the dismax end point behaves differently
            # from edismax (advanced) when the query size is 1. This is a fix
            # for that. See https://issues.apache.org/jira/browse/SOLR-12409
            if (split(/[\P{Word}_]+/, $query, 2) == 1) {
                $endpoint = 'basic';
            } else {
                $endpoint = 'select';
            }
        }
        $search_url_string = "http://%s/%s/$endpoint?q=%s&start=%s&rows=%s&wt=mbjson";
     }

    my $search_url = sprintf($search_url_string,
                                 DBDefs->SEARCH_SERVER,
                                 $type,
                                 $query,
                                 $offset,
                                 $limit);

    # Dispatch the search request.
    my $response = get_chunked_with_retry($self->c->lwp, $search_url);
    if (!defined $response) {
        return { code => 500, error => 'We could not fetch the document from the search server. Please try again.' };
    }
    elsif (!$response->is_success)
    {
        return { code => $response->code, error => $response->content };
    }
    elsif ($response->status_line eq '200 Assumed OK')
    {
        if ($response->content =~ /<title>([0-9]{3})/)
        {
            return { code => $1, error => $response->content };
        }
        else
        {
            return { code => 500, error => $response->content };
        }
    }
    else
    {
        my $data;
        try {
            $data = JSON->new->utf8->decode($response->content);
        }
        catch {
            use Data::Dumper;
            croak "Failed to decode JSON search data:\n" .
                  Dumper($response->content) . "\n" .
                  "Exception:\n" . Dumper($_) . "\n" .
                  "Response headers:\n" .
                  Dumper($response->headers->as_string);
        };

        my @results;
        my $xmltype = $type;
        my $pos = 0;
        my $last_updated = $data->{created} ?
            DateTime::Format::ISO8601->parse_datetime($data->{created}) :
            undef;

        # Use types as provided by jsonnew format
        if ($type ~~ [qw(area artist event instrument label place recording release release-group work annotation cdstub editor)]) {
            $xmltype .= 's';
        }

        foreach my $t (@{$data->{$xmltype}})
        {
            $self->schema_fixup($t, $type);
            push @results, MusicBrainz::Server::Entity::SearchResult->new(
                    position => $pos++,
                    score  => $t->{score},
                    entity => $entity_model->new($t),
                    extra  => $t->{_extra} || []   # Not all data fits into the object model, this is for those cases
                );
        }
        my ($total_hits) = $data->{count};

        # If the user searches for annotations, they will get the results in wikiformat - we need to
        # convert this to HTML.
        if ($type eq 'annotation')
        {
            foreach my $result (@results)
            {
                $result->{type} = ref_to_type($result->{entity}->{parent});
            }
        }

        if ($type eq 'work')
        {
            my @entities = map { $_->entity } @results;
            $self->c->model('Work')->load_ids(@entities);
            $self->c->model('Work')->load_recording_artists(@entities);
        }

        if ($type eq 'event')
        {
            my @entities = map { $_->entity } @results;
            $self->c->model('Event')->load_ids(@entities);
            $self->c->model('Event')->load_related_info(@entities);
            $self->c->model('Event')->load_areas(@entities);
        }

        if ($type eq 'release')
        {
            my @entities = map { $_->entity } @results;
            $self->c->model('Release')->load_ids(@entities);
            $self->c->model('Release')->load_meta(@entities);
        }

        if ($type eq 'area')
        {
            my @entities = map { $_->entity } @results;
            $self->c->model('Area')->load_ids(@entities);
            $self->c->model('Area')->load_containment(@entities);
        }

        if ($type eq 'release-group')
        {
            my @entities = map { $_->entity } @results;
            $self->c->model('ReleaseGroup')->load_ids(@entities);
            $self->c->model('Artwork')->load_for_release_groups(@entities);
        }

        my $pager = Data::Page->new;
        $pager->current_page($page);
        $pager->entries_per_page($limit);
        $pager->total_entries($total_hits);

        return { pager => $pager, offset => $offset, results => \@results, last_updated => $last_updated };
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Search

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
