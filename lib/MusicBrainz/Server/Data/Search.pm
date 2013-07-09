package MusicBrainz::Server::Data::Search;

use Moose;
use Class::MOP;
use JSON;
use Sql;
use Readonly;
use Data::Page;
use URI::Escape qw( uri_escape_utf8 );
use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Entity::ArtistType;
use MusicBrainz::Server::Entity::AreaType;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::Gender;
use MusicBrainz::Server::Entity::ISRC;
use MusicBrainz::Server::Entity::ISWC;
use MusicBrainz::Server::Entity::LabelType;
use MusicBrainz::Server::Entity::Language;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Entity::ReleaseGroupType;
use MusicBrainz::Server::Entity::Script;
use MusicBrainz::Server::Entity::SearchResult;
use MusicBrainz::Server::Entity::WorkType;
use MusicBrainz::Server::Exceptions;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Tag;
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Constants qw( $DARTIST_ID $DLABEL_ID );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use DateTime::Format::ISO8601;
use feature "switch";

extends 'MusicBrainz::Server::Data::Entity';

Readonly my %TYPE_TO_DATA_CLASS => (
    artist        => 'MusicBrainz::Server::Data::Artist',
    area          => 'MusicBrainz::Server::Data::Area',
    label         => 'MusicBrainz::Server::Data::Label',
    recording     => 'MusicBrainz::Server::Data::Recording',
    release       => 'MusicBrainz::Server::Data::Release',
    release_group => 'MusicBrainz::Server::Data::ReleaseGroup',
    work          => 'MusicBrainz::Server::Data::Work',
    tag           => 'MusicBrainz::Server::Data::Tag',
    editor        => 'MusicBrainz::Server::Data::Editor'
);

use Sub::Exporter -setup => {
    exports => [qw( escape_query alias_query )]
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

    if ($type eq "artist" || $type eq "label") {

        $deleted_entity = ($type eq "artist") ? $DARTIST_ID : $DLABEL_ID;

        my $extra_columns = '';
        $extra_columns .= 'entity.label_code, entity.area,' if $type eq 'label';
        $extra_columns .= 'entity.gender, entity.area, entity.begin_area, entity.end_area,' if $type eq 'artist';

        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.comment,
                aname.name AS name,
                asort_name.name AS sort_name,
                entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day,
                entity.ended,
                $extra_columns
                MAX(rank) AS rank
            FROM
                (
                    SELECT id, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank
                    FROM ${type}_name, plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                LEFT JOIN ${type}_alias AS alias ON alias.name = r.id
                JOIN ${type} AS entity ON (r.id = entity.name OR r.id = entity.sort_name OR alias.${type} = entity.id)
                JOIN ${type}_name AS aname ON entity.name = aname.id
                JOIN ${type}_name AS asort_name ON entity.sort_name = asort_name.id
                WHERE entity.id != ?
            GROUP BY
                $extra_columns entity.id, entity.gid, entity.comment, aname.name, asort_name.name, entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended
            ORDER BY
                rank DESC, sort_name, name
            OFFSET
                ?
        ";

        $hard_search_limit = $offset * 2;
    }
    elsif ($type eq "recording" || $type eq "release" || $type eq "release_group") {
        my $type2 = $type;
        $type2 = "track" if $type eq "recording";
        $type2 = "release" if $type eq "release_group";

        my $extra_columns = "";
        $extra_columns .= 'entity.type AS primary_type_id,'
            if ($type eq 'release_group');

        $extra_columns = "entity.length,"
            if ($type eq "recording");

        $extra_columns .= 'entity.language, entity.script, entity.barcode, entity.release_group,'
            if ($type eq 'release');

        my $extra_ordering = '';
        $extra_columns .= 'entity.artist_credit AS artist_credit_id,';
        $extra_ordering = ', entity.artist_credit';

        my ($join_sql, $where_sql)
            = ("JOIN ${type} entity ON r.id = entity.name", '');

        if ($type eq 'release' && $where && exists $where->{track_count}) {
            $join_sql .= ' JOIN medium ON medium.release = entity.id';
            $where_sql = 'WHERE medium.track_count = ?';
            push @where_args, $where->{track_count};
        }
        elsif ($type eq 'recording') {
            if ($where && exists $where->{artist})
            {
                $join_sql .= " JOIN artist_credit ON artist_credit.id = entity.artist_credit"
                    ." JOIN artist_name ON artist_credit.name = artist_name.id";
                $where_sql = 'WHERE artist_name.name LIKE ?';
                push @where_args, "%".$where->{artist}."%";
            }
        }

        $query = "
            SELECT DISTINCT
                entity.id,
                entity.gid,
                entity.comment,
                $extra_columns
                r.name,
                r.rank
            FROM
                (
                    SELECT id, name, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank
                    FROM ${type2}_name, plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                $join_sql
                $where_sql
            ORDER BY
                r.rank DESC, r.name
                $extra_ordering
            OFFSET
                ?
        ";
        $hard_search_limit = int($offset * 1.2);
    }

    elsif ($type eq "work") {

        $query = "
            SELECT
                entity.id,
                entity.gid,
                r.name,
                entity.type AS type_id,
                entity.language AS language_id,
                MAX(rank) AS rank
            FROM
                (
                    SELECT id, name, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank
                    FROM ${type}_name, plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
                    ORDER BY rank DESC
                    LIMIT ?
                ) as r
                LEFT JOIN ${type}_alias AS alias ON alias.name = r.id
                JOIN ${type} AS entity ON (r.id = entity.name OR alias.${type} = entity.id)
                JOIN ${type}_name AS aname ON entity.name = aname.id
            GROUP BY
                entity.id, entity.gid, r.name, type_id, language_id
            ORDER BY
                rank DESC, r.name
            OFFSET
                ?
        ";

        $hard_search_limit = $offset * 2;
    }

    # Could be merged with artist/label once name tables are killed
    elsif ($type eq "area") {

        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.name,
                entity.sort_name,
                entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day,
                entity.ended,
                MAX(rank) AS rank
            FROM
                (
                    SELECT name, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank
                    FROM
                        (SELECT name              FROM ${type}       UNION ALL
                         SELECT sort_name AS name FROM ${type}       UNION ALL
                         SELECT name              FROM ${type}_alias UNION ALL
                         SELECT sort_name AS name FROM ${type}_alias) names,
                        plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                LEFT JOIN ${type}_alias AS alias ON (alias.name = r.name OR alias.sort_name = r.name)
                JOIN ${type} AS entity ON (r.name = entity.name OR r.name = entity.sort_name OR alias.${type} = entity.id)
            GROUP BY
                entity.id, entity.gid, entity.name, entity.sort_name, entity.type,
                entity.begin_date_year, entity.begin_date_month, entity.begin_date_day,
                entity.end_date_year, entity.end_date_month, entity.end_date_day, entity.ended
            ORDER BY
                rank DESC, sort_name, name
            OFFSET
                ?
        ";

        $hard_search_limit = $offset * 2;
    }

    elsif ($type eq "tag") {
        $query = "
            SELECT id, name, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank
            FROM tag, plainto_tsquery('mb_simple', ?) AS query
            WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
            ORDER BY rank DESC, tag.name
            OFFSET ?
        ";
        $use_hard_search_limit = 0;
    }
    elsif ($type eq 'editor') {
        $query = "SELECT id, name, ts_rank_cd(to_tsvector('mb_simple', name), query, 2) AS rank,
                    email
                  FROM editor, plainto_tsquery('mb_simple', ?) AS query
                  WHERE to_tsvector('mb_simple', name) @@ query OR name = ?
                  ORDER BY rank DESC
                  OFFSET ?";
        $use_hard_search_limit = 0;
    }

    if ($use_hard_search_limit) {
        $hard_search_limit += $limit * 3;
    }

    my $fuzzy_search_limit = 10000;
    my $search_timeout = 60 * 1000;

    $self->sql->auto_commit;
    $self->sql->do('SET SESSION gin_fuzzy_search_limit TO ?', $fuzzy_search_limit);
    $self->sql->auto_commit;
    $self->sql->do('SET SESSION statement_timeout TO ?', $search_timeout);

    my @query_args = ();
    push @query_args, $hard_search_limit if $use_hard_search_limit;
    push @query_args, $deleted_entity if $deleted_entity;
    push @query_args, @where_args;
    push @query_args, $offset;

    $self->sql->select($query, $query_str, $query_str, @query_args);

    my @result;
    my $pos = $offset + 1;
    while ($limit--) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $res = MusicBrainz::Server::Entity::SearchResult->new(
            position => $pos++,
            score => int(100 * $row->{rank}),
            entity => $TYPE_TO_DATA_CLASS{$type}->_new_from_row($row)
        );
        push @result, $res;
    }
    my $hits = $self->sql->row_count + $offset;
    $self->sql->finish;

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
    'status'         => '',
    'label-code'     => 'label_code',
);

# Fix up the key names so that the data returned from the JSON service
# matches up with the data returned from the DB for easy object creation
sub schema_fixup
{
    my ($self, $data, $type) = @_;

    return unless (ref($data) eq 'HASH');

    if (exists $data->{id} && $type eq 'freedb')
    {
        $data->{discid} = $data->{id};
        delete $data->{name};
    }

    # Special case to handle the ids
    $data->{gid} = $data->{id};
    $data->{id} = 1;

    foreach my $k (keys %mapping)
    {
        if (exists $data->{$k})
        {
            $data->{$mapping{$k}} = $data->{$k} if ($mapping{$k});
            delete $data->{$k};
        }
    }

    if ($type eq 'artist' && exists $data->{type})
    {
        $data->{type} = MusicBrainz::Server::Entity::ArtistType->new( name => $data->{type} );
    }
    if ($type eq 'area' && exists $data->{type})
    {
        $data->{type} = MusicBrainz::Server::Entity::AreaType->new( name => $data->{type} );
    }
    if (($type eq 'artist' || $type eq 'label' || $type eq 'area') && exists $data->{'life-span'})
    {
        $data->{begin_date} = MusicBrainz::Server::Entity::PartialDate->new($data->{'life-span'}->{begin})
            if (exists $data->{'life-span'}->{begin});
        $data->{end_date} = MusicBrainz::Server::Entity::PartialDate->new($data->{'life-span'}->{end})
            if (exists $data->{'life-span'}->{end});
    }
    if ($type eq 'area') {
        for my $prop (qw( iso_3166_1 iso_3166_2 iso_3166_3 )) {
            my $json_subprop = $prop . '-code';
            $json_subprop =~ s/_/-/g;
            my $json_prop = $json_subprop . '-list';
            if (exists $data->{$json_prop}) {
                $data->{$prop} = $data->{$json_prop}->{$json_subprop};
                delete $data->{$json_prop};
            }
        }
    }
    if ($type eq 'artist' || $type eq 'label') {
        for my $prop (qw( area begin_area end_area )) {
            my $json_prop = $prop;
            $json_prop =~ s/_/-/;
            if (exists $data->{$json_prop})
            {
                my $area = delete $data->{$json_prop};
                $area->{gid} = $area->{id};
                $area->{id} = 1;
                $data->{$prop} = MusicBrainz::Server::Entity::Area->new($area);
            }
        }
    }
    if($type eq 'artist' && exists $data->{gender}) {
        $data->{gender} = MusicBrainz::Server::Entity::Gender->new( name => ucfirst($data->{gender}) );
    }
    if ($type eq 'label' && exists $data->{type})
    {
        $data->{type} = MusicBrainz::Server::Entity::LabelType->new( name => $data->{type} );
    }
    if ($type eq 'release-group' && exists $data->{type})
    {
        $data->{primary_type} = MusicBrainz::Server::Entity::ReleaseGroupType->new( name => $data->{type} );
    }
    if ($type eq 'cdstub' && exists $data->{gid})
    {
        $data->{discid} = $data->{gid};
        delete $data->{gid};
        $data->{title} = $data->{name};
        delete $data->{name};
    }
    if ($type eq 'annotation' && exists $data->{entity})
    {
        my $parent_type = $data->{type};
        $parent_type =~ s/-/_/g;
        my $entity_model = $self->c->model( type_to_model($parent_type) )->_entity_class;
        $data->{parent} = $entity_model->new( { name => $data->{name}, gid => $data->{entity} });
        delete $data->{entity};
        delete $data->{type};
    }
    if ($type eq 'freedb' && exists $data->{name})
    {
        $data->{title} = $data->{name};
        delete $data->{name};
    }
    if (($type eq 'cdstub' || $type eq 'freedb')
        && (exists $data->{"track-list"} && exists $data->{"track-list"}->{count}))
    {
        if (exists $data->{barcode})
        {
            $data->{barcode} = MusicBrainz::Server::Entity::Barcode->new( $data->{barcode} );
        }

        $data->{track_count} = $data->{"track-list"}->{count};
        delete $data->{"track-list"}->{count};
    }
    if ($type eq 'release')
    {
        if (exists $data->{"release-event-list"} &&
            exists $data->{"release-event-list"}->{"release-event"})
        {
            $data->{events} = [];
            for my $release_event_data (@{$data->{"release-event-list"}->{"release-event"}})
            {
                my $release_event = MusicBrainz::Server::Entity::ReleaseEvent->new(
                    country => defined($release_event_data->{area}) ?
                        MusicBrainz::Server::Entity::Area->new( gid => $release_event_data->{area}->{id},
                                                                iso_3166_1 => $release_event_data->{area}->{"iso-3166-1-code-list"}->{"iso-3166-1-code"},
                                                                name => $release_event_data->{area}->{name},
                                                                sort_name => $release_event_data->{area}->{'sort-name'} )
                        : undef,
                    date => MusicBrainz::Server::Entity::PartialDate->new( $release_event_data->{date} ));

                push @{$data->{events}}, $release_event;
            }
            delete $data->{"release-event-list"};
        }
        if (exists $data->{barcode})
        {
            $data->{barcode} = MusicBrainz::Server::Entity::Barcode->new( $data->{barcode} );
        }
        if (exists $data->{"text-representation"} &&
            exists $data->{"text-representation"}->{language})
        {
            $data->{language} = MusicBrainz::Server::Entity::Language->new( {
                iso_code_3 => $data->{"text-representation"}->{language}
            } );
        }
        if (exists $data->{"text-representation"} &&
            exists $data->{"text-representation"}->{script})
        {
            $data->{script} = MusicBrainz::Server::Entity::Script->new(
                    { iso_code => $data->{"text-representation"}->{script} }
            );
        }
        if (exists $data->{"medium-list"} &&
            exists $data->{"medium-list"}->{medium})
        {
            $data->{mediums} = [];
            for my $medium_data (@{$data->{"medium-list"}->{medium}})
            {
                my $medium = MusicBrainz::Server::Entity::Medium->new(
                    track_count => $medium_data->{"track-list"}->{"count"});

                push @{$data->{mediums}}, $medium;
            }
            delete $data->{"medium-list"};
        }
    }
    if ($type eq 'recording' &&
        exists $data->{"release-list"} &&
        exists $data->{"release-list"}->{release}->[0] &&
        exists $data->{"release-list"}->{release}->[0]->{"medium-list"} &&
        exists $data->{"release-list"}->{release}->[0]->{"medium-list"}->{medium})
    {
        my @releases;

        foreach my $release (@{$data->{"release-list"}->{release}})
        {
            my $medium = MusicBrainz::Server::Entity::Medium->new(
                position  => $release->{"medium-list"}->{medium}->[0]->{"position"},
                track_count => $release->{"medium-list"}->{medium}->[0]->{"track-list"}->{"count"},
                tracks => [ MusicBrainz::Server::Entity::Track->new(
                    position => $release->{"medium-list"}->{medium}->[0]->{"track-list"}->{"offset"} + 1,
                    recording => MusicBrainz::Server::Entity::Recording->new(
                        gid => $data->{gid}
                    )
                ) ]
            );
            my $release_group = MusicBrainz::Server::Entity::ReleaseGroup->new(
                primary_type => MusicBrainz::Server::Entity::ReleaseGroupType->new(
                    name => $release->{"release-group"}->{type} || ''
                )
            );
            push @releases, MusicBrainz::Server::Entity::Release->new(
                gid     => $release->{id},
                name    => $release->{title},
                mediums => [ $medium ],
                release_group => $release_group
            );
        }
        $data->{_extra} = \@releases;
    }

    if ($type eq 'recording' && exists $data->{'isrc-list'}) {
        $data->{isrcs} = [
            map { MusicBrainz::Server::Entity::ISRC->new( isrc => $_->{id} ) } @{ $data->{'isrc-list'}{'isrc'} }
        ];
    }

    if (exists $data->{"relation-list"} &&
        exists $data->{"relation-list"}->[0] &&
        exists $data->{"relation-list"}->[0]->{"relation"})
    {
        my @relationships;

        foreach my $rel_group (@{ $data->{"relation-list"} })
        {
            my $entity_type = $rel_group->{'target-type'};

            foreach my $rel (@{ $rel_group->{"relation"} })
            {
                my %entity = %{ $rel->{$entity_type} };

                # The search server returns the MBID in the 'id' attribute, so we
                # need to rename that.
                $entity{gid} = delete $entity{id};

                my $entity = $self->c->model( type_to_model ($entity_type) )->
                    _entity_class->new (%entity);

                push @relationships, MusicBrainz::Server::Entity::Relationship->new(
                    entity1 => $entity,
                    link => MusicBrainz::Server::Entity::Link->new(
                        type => MusicBrainz::Server::Entity::LinkType->new(
                            name => $rel->{type}
                        )
                    )
                );
            }
        }

        $data->{relationships} = \@relationships;
    }


    foreach my $k (keys %{$data})
    {
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

    if (exists $data->{'artist_credit'})
    {
        my @credits;
        foreach my $namecredit (@{$data->{"artist_credit"}->{"name-credit"}})
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
        if (exists $data->{relationships}) {
            my %relationship_map = partition_by { $_->entity1->gid }
                @{ $data->{relationships} };

            $data->{writers} = [
                map {
                    my @relationships = @{ $relationship_map{$_} };
                    {
                        entity => $relationships[0]->entity1,
                            roles  => [ map { $_->link->type->name } @relationships ]
                        }
                } keys %relationship_map
            ];
        }

        if(exists $data->{type}) {
            $data->{type} = MusicBrainz::Server::Entity::WorkType->new( name => $data->{type} );
        }

        if (exists $data->{language}) {
            $data->{language} = MusicBrainz::Server::Entity::Language->new({
                iso_code_3 => $data->{language}
            });
        }

        if(exists $data->{'iswc-list'}) {
            $data->{iswcs} = [
                map {
                    MusicBrainz::Server::Entity::ISWC->new( iswc => $_ )
                } @{ $data->{'iswc-list'}{iswc} }
            ]
        }
    }
}

# Escape special characters in a Lucene search query
sub escape_query
{
    my $str = shift;

    return "" unless $str;

    $str =~  s/([+\-&|!(){}\[\]\^"~*?:\\\/])/\\$1/g;
    return $str;
}

# add alias/sortname queries for entity
sub alias_query
{
    my ($type, $query) = @_;

    return "$type:\"$query\"^1.6 " .
        "(+sortname:\"$query\"^1.6 -$type:\"$query\") " .
        "(+alias:\"$query\" -$type:\"$query\" -sortname:\"$query\") " .
        "(+($type:($query)^0.8) -$type:\"$query\" -sortname:\"$query\" -alias:\"$query\") " .
        "(+(sortname:($query)^0.8) -$type:($query) -sortname:\"$query\" -alias:\"$query\") " .
        "(+(alias:($query)^0.4) -$type:($query) -sortname:($query) -alias:\"$query\")";
}

sub external_search
{
    my ($self, $type, $query, $limit, $page, $adv, $ua) = @_;

    my $entity_model = $self->c->model( type_to_model($type) )->_entity_class;
    Class::MOP::load_class($entity_model);
    my $offset = ($page - 1) * $limit;

    $query = uri_escape_utf8($query);
    $type =~ s/release_group/release-group/;
    my $search_url = sprintf("http://%s/ws/2/%s/?query=%s&offset=%s&max=%s&fmt=json&dismax=%s",
                                 DBDefs->LUCENE_SERVER,
                                 $type,
                                 $query,
                                 $offset,
                                 $limit,
                                 $adv ? 'false' : 'true',
                                 );

    if (DBDefs->_RUNNING_TESTS)
    {
        $ua = MusicBrainz::Server::Test::mock_search_server($type);
    }
    else
    {
        $ua = LWP::UserAgent->new if (!defined $ua);
    }

    $ua->timeout (5);
    $ua->env_proxy;

    # Dispatch the search request.
    my $response = $ua->get($search_url);
    unless ($response->is_success)
    {
        return { code => $response->code, error => $response->content };
    }
    elsif ($response->status_line eq "200 Assumed OK")
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
        my $data = JSON->new->utf8->decode($response->content);

        my @results;
        my $xmltype = $type;
        $xmltype =~ s/freedb/freedb-disc/;
        my $pos = 0;
        my $last_updated = $data->{created} ?
            DateTime::Format::ISO8601->parse_datetime($data->{created}) :
            undef;

        foreach my $t (@{$data->{"$xmltype-list"}->{$xmltype}})
        {
            $self->schema_fixup($t, $type);
            push @results, MusicBrainz::Server::Entity::SearchResult->new(
                    position => $pos++,
                    score  => $t->{score},
                    entity => $entity_model->new($t),
                    extra  => $t->{_extra} || []   # Not all data fits into the object model, this is for those cases
                );
        }
        my ($total_hits) = $data->{"$xmltype-list"}->{count};

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

        my $pager = Data::Page->new;
        $pager->current_page($page);
        $pager->entries_per_page($limit);
        $pager->total_entries($total_hits);

        return { pager => $pager, offset => $offset, results => \@results, last_updated => $last_updated };
    }
}

sub combine_rules
{
    my ($inputs, %rules) = @_;

    my @parts;
    for my $key (keys %rules) {
        my $spec = $rules{$key};
        my $parameter = $spec->{parameter} || $key;
        next unless exists $inputs->{$parameter};

        my $input = $inputs->{$parameter};
        next if exists $spec->{check} && !$spec->{check}->($input);

        $input = escape_query($input) if $spec->{escape};
        my $process = $spec->{process} || sub { shift };
        $input = $process->($input);
        $input = join(' AND ', split /\s+/, $input) if $spec->{split};

        my $predicate = $spec->{predicate} || sub { "$key:($input)" };
        push @parts, $predicate->($input);
    }

    return join(' AND ', map { "($_)" } @parts);
}

sub xml_search
{
    my ($self, %options) = @_;

    my $die = sub {
        MusicBrainz::Server::Exceptions::InvalidSearchParameters->throw( message => shift );
    };

    my $query   = $options{query};
    my $limit   = $options{limit} || 25;
    my $offset  = $options{offset} || 0;
    my $type    = $options{type} or $die->('type is a required parameter');
    my $version = $options{version} || 2;

    $type =~ s/release_group/release-group/;

    unless ($query) {
        given ($type) {
            when ('artist') {
                my $name = escape_query($options{name}) or $die->('name is a required parameter');
                $name =~ tr/A-Z/a-z/;
                $name =~ s/\s*(.*?)\s*$/$1/;
                $query = "artist:($name)(sortname:($name) alias:($name) !artist:($name))";
            }
            when ('label') {
                my $term = escape_query($options{name}) or $die->('name is a required parameter');
                $term =~ tr/A-Z/a-z/;
                $term =~ s/\s*(.*?)\s*$/$1/;
                $query = "label:($term)(sortname:($term) alias:($term) !label:($term))";
            }

            when ('release') {
                $query = combine_rules(
                    \%options,
                    DEFAULT => {
                        parameter => 'title',
                        escape    => 1,
                        process => sub {
                            my $term = shift;
                            $term =~ s/\s*(.*?)\s*$/$1/;
                            $term =~ tr/A-Z/a-z/;
                            $term;
                        },
                        split     => 1,
                        predicate => sub { shift }
                    },
                    arid => {
                        parameter => 'artistid',
                        escape    => 1
                    },
                    artist => {
                        parameter => 'artist',
                        escape    => 1,
                        split     => 1,
                        process   => sub { my $term = shift; $term =~ s/\s*(.*?)\s*$/$1/; $term }
                    },
                    type => {
                        parameter => 'releasetype',
                    },
                    status => {
                        parameter => 'releasestatus',
                        check     => sub { shift() =~ /^\d+$/ },
                        process   => sub { shift() . '^0.0001' }
                    },
                    tracks => {
                        parameter => 'count',
                        check     => sub { shift > 0 },
                    },
                    discids => {
                        check     => sub { shift > 0 },
                    },
                    date   => {},
                    asin   => {},
                    lang   => {},
                    script => {}
                );
            }

            when ('release-group') {
                $query = combine_rules(
                    \%options,
                    DEFAULT => {
                        parameter => 'title',
                        escape    => 1,
                        process => sub {
                            my $term = shift;
                            $term =~ s/\s*(.*?)\s*$/$1/;
                            $term =~ tr/A-Z/a-z/;
                            $term;
                        },
                        split     => 1,
                        predicate => sub { shift }
                    },
                    arid => {
                        parameter => 'artistid',
                        escape    => 1
                    },
                    artist => {
                        parameter => 'artist',
                        escape    => 1,
                        split     => 1,
                        process   => sub { my $term = shift; $term =~ s/\s*(.*?)\s*$/$1/; $term }
                    },
                    type => {
                        parameter => 'releasetype',
                        check     => sub { shift =~ /^\d+$/ },
                        process   => sub { my $type = shift; return $type . '^.0001' }
                    },
                );
            }

            when ('recording') {
                $query = combine_rules(
                    \%options,
                    DEFAULT => {
                        parameter => 'title',
                        escape    => 1,
                        process => sub {
                            my $term = shift;
                            $term =~ s/\s*(.*?)\s*$/$1/;
                            $term =~ tr/A-Z/a-z/;
                            $term;
                        },
                        predicate => sub { shift },
                        split     => 1,
                    },
                    arid => {
                        parameter => 'artistid',
                        escape    => 1
                    },
                    artist => {
                        parameter => 'artist',
                        escape    => 1,
                        split     => 1,
                        process   => sub { my $term = shift; $term =~ s/\s*(.*?)\s*$/$1/; $term }
                    },
                    reid => {
                        parameter => 'releaseid',
                        escape    => 1
                    },
                    release => {
                        parameter => 'release',
                        process   => sub { my $term = shift; $term =~ s/\s*(.*?)\s*$/$1/; $term; },
                        split     => 1,
                        escape    => 1
                    },
                    duration => {
                        predicate => sub {
                            my $dur = int(shift() / 2000);
                            return "qdur:$dur OR qdur:(" . ($dur - 1) . ") OR qdur:(" . ($dur + 1) . ")";
                        }
                    },
                    tnum => {
                        parameter => 'tracknumber',
                        check => sub { shift() >= 0 },
                    },
                    type   => { parameter => 'releasetype' },
                    tracks => { parameter => 'count' },
                );
            }
        }
    }

    $query = uri_escape_utf8($query);
    my $search_url = sprintf("http://%s/ws/%d/%s/?query=%s&offset=%s&max=%s&fmt=xml",
                                 DBDefs->LUCENE_SERVER,
                                 $version,
                                 $type,
                                 $query,
                                 $offset,
                                 $limit,);

    my $ua = LWP::UserAgent->new;
    $ua->timeout (5);
    $ua->env_proxy;

    # Dispatch the search request.
    my $response = $ua->get($search_url);
    unless ($response->is_success)
    {
        die $response;
    }
    else
    {
        return $response->decoded_content;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Search

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
