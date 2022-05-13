package MusicBrainz::Script::EntityDump;

use strict;
use warnings;

use base 'Exporter';
use feature 'state';
use MusicBrainz::Script::Utils qw( get_primary_keys );
use MusicBrainz::Server::Constants qw(
    $EDITOR_SANITISED_COLUMNS
    %ENTITIES
    entities_with
);

our @EXPORT_OK = qw(
    edits
    get_core_entities
    get_core_entities_by_gids
);

our @link_path;

# Should be set by users of this package.
our $handle_inserts = sub {};
our $dump_aliases = 0;
our $dump_annotations = 0;
our $dump_collections = 0;
our $dump_gid_redirects = 0;
our $dump_meta_tables = 0;
our $dump_ratings = 0;
our $dump_subscriptions = 0;
our $dump_tags = 0;
our $dump_types = 0;
our $follow_extra_data = 0;
our $relationships_cardinality = 0;
our @skip_tables;
# This is a hack that allows us to clear editor.area for areas that weren't
# already dumped. (We don't follow this column because it creates cycles;
# see `sub editors`.)
our %area_ids;
our %path_ids;

sub pluck {
    my ($prop, $values) = @_;
    [map { $_->{$prop} } @$values];
}

sub handle_rows {
    my ($c, $table) = @_;

    state $skip_tables = { map { $_ => 1 } @skip_tables };
    return if exists $skip_tables->{$table};

    my $rows;
    $rows = $_[2] if (@_ == 3);
    $rows = get_rows($c, $table, $_[2], $_[3]) if (@_ == 4);

    return unless defined $rows && @{$rows};

    state $seen_values = {};
    my $seen_table_values = ($seen_values->{$table} //= {});

    (my $schema, $table) = split /\./, $table;
    unless (defined $table) {
        $table = $schema;
        $schema = 'musicbrainz';
    }

    my @primary_keys = sort {
        $a cmp $b
    } get_primary_keys($c, $schema, $table);

    my @new_rows = grep {
        my $key = join "\t", @{$_}{@primary_keys};
        my $is_new = 0;
        unless (exists $seen_table_values->{$key}) {
            $is_new = 1;
            $seen_table_values->{$key} = 1;
        }
        $is_new;
    } @{$rows};

    if (@new_rows) {
        $handle_inserts->($c, $schema, $table, \@new_rows);
    }
};

sub get_rows {
    my ($c, $table, $column, $values) = @_;

    my @values = grep { defined } @{ $values // [] };
    return unless @values;

    return $c->sql->select_list_of_hashes(
        "SELECT * FROM $table WHERE $column = any(?) ORDER BY $column",
        \@values,
    );
}

sub get_new_ids {
    my ($cache_key, $ids) = @_;

    state $root = {};
    my $cache = ($root->{$cache_key} //= {});

    my @new_ids;
    for my $id (@{$ids}) {
        if (defined $id && !exists $cache->{$id}) {
            $cache->{$id} = 1;
            push @new_ids, $id;
        }
    }

    return \@new_ids;
}

sub tags {
    my ($c, $entity_type, $ids) = @_;

    my $table = "${entity_type}_tag";
    my $rows = get_rows($c, $table, $entity_type, $ids);

    my $raw_table = "${table}_raw";
    my $raw_rows = $c->sql->select_list_of_hashes(
        qq{SELECT $raw_table.* FROM $raw_table
             LEFT JOIN editor_preference ep ON (ep.editor = $raw_table.editor AND ep.name = 'public_tags')
            WHERE $raw_table.$entity_type = any(?)
              AND coalesce(ep.value, '1') = '1'
            ORDER BY $raw_table.$entity_type},
        $ids,
    );

    editors($c, pluck('editor', $raw_rows));

    my $tag_ids = pluck('tag', $rows);
    push @{$tag_ids}, @{ pluck('tag', $raw_rows) };
    handle_rows($c, 'tag', 'id', $tag_ids);

    handle_rows($c, $table, $rows);
    handle_rows($c, $raw_table, $raw_rows);
}

sub annotations {
    my ($c, $entity_type, $ids) = @_;

    my $entity_annotation_rows =
        get_rows($c, "${entity_type}_annotation", $entity_type, $ids);
    my $annotation_rows =
        get_rows($c, 'annotation', 'id', pluck('annotation', $entity_annotation_rows));
    editors($c, pluck('editor', $annotation_rows));
    handle_rows($c, 'annotation', $annotation_rows);
    handle_rows($c, "${entity_type}_annotation", $entity_annotation_rows);
}

sub artist_credits {
    my ($c, $ids) = @_;

    $ids = get_new_ids('artist_credit', $ids);
    return unless @{$ids};

    my $rows = get_rows($c, 'artist_credit', 'id', $ids);
    my $name_rows = get_rows($c, 'artist_credit_name', 'artist_credit', $ids);

    artists($c, pluck('artist', $name_rows));
    handle_rows($c, 'artist_credit', $rows);
    handle_rows($c, 'artist_credit_name', $name_rows);
}

sub collections {
    my ($c, $entity_type, $ids) = @_;

    my $entity_collection_rows =
        get_rows($c, "editor_collection_${entity_type}", $entity_type, $ids);

    # Need a custom query here to exclude private collections.
    my $collection_rows = $c->sql->select_list_of_hashes(
        q{SELECT * FROM editor_collection WHERE id = any(?) and public = 't' ORDER BY id},
        pluck('collection', $entity_collection_rows),
    );

    # Filter out private collections from $entity_collection_rows.
    my %ids = map { $_->{id} => 1 } @{$collection_rows};
    $entity_collection_rows = [grep { $ids{$_->{collection}} } @{$entity_collection_rows}];

    editors($c, pluck('editor', $collection_rows));
    handle_rows($c, 'editor_collection', $collection_rows);
    handle_rows($c, "editor_collection_${entity_type}", $entity_collection_rows);
}

sub relationships {
    my ($c, $entity_type, $entity_ids) = @_;

    for my $t ($c->model('Relationship')->generate_table_list($entity_type)) {
        my ($table, $column) = @$t;

        my $target_column = $column eq 'entity0' ? 'entity1' : 'entity0';
        my $target_type = $table;

        if ($column eq 'entity0') {
            $target_type =~ s/l_\Q${entity_type}\E_([a-z_]+)$/$1/;
        } else {
            $target_type =~ s/l_([a-z_]+)_\Q${entity_type}\E$/$1/;
        }

        my $joins = '';
        my $conditions = "WHERE $column = any(?)";
        my @values = ($entity_ids);

        if (defined $relationships_cardinality) {
            $joins .= "JOIN link ON link.id = $table.link\n";
            $joins .= 'JOIN link_type ON link_type.id = link.link_type';
            $conditions .= "\n";
            $conditions .= "AND link_type.${column}_cardinality = ?";
            push @values, $relationships_cardinality;
        }

        my $results = $c->sql->select_list_of_hashes(
            "SELECT $table.*
               FROM $table
             $joins
             $conditions
              ORDER BY $table.id",
            @values,
        );

        get_core_entities(
            $c,
            $target_type,
            pluck($target_column, $results),
        );

        my $link_ids = pluck('link', $results);
        handle_rows($c, 'link', 'id', $link_ids);
        handle_rows($c, 'link_attribute', 'link', $link_ids);
        handle_rows($c, 'link_attribute_credit', 'link', $link_ids);
        handle_rows($c, 'link_attribute_text_value', 'link', $link_ids);

        handle_rows($c, $table, $results);
    }
}

sub core_entity {
    my ($c, $entity_type, $ids, $callback) = @_;

    $ids = get_new_ids($entity_type, $ids);
    return unless @{$ids};

    local @link_path = (@link_path, $entity_type);

    my $last_part;
    $last_part = ($path_ids{$_} //= {}) for @link_path;
    $last_part->{_ids}{$_} = 1 for @{$ids};

    my $rows = get_rows($c, $entity_type, 'id', $ids);
    $ids = pluck('id', $rows);
    my $entity_properties = $ENTITIES{$entity_type};

    if ($entity_properties->{artist_credits}) {
        artist_credits($c, pluck('artist_credit', $rows));
    }

    $callback //= \&handle_rows;
    $callback->($c, $entity_type, $rows);

    if ($dump_meta_tables && $entity_properties->{meta_table}) {
        handle_rows($c, "${entity_type}_meta", 'id', $ids);
    }

    if ($dump_gid_redirects) {
        handle_rows($c, "${entity_type}_gid_redirect", 'new_id', $ids);
    }

    if ($entity_properties->{ipis}) {
        ipis($c, $entity_type, $ids);
    }

    if ($entity_properties->{isnis}) {
        isnis($c, $entity_type, $ids);
    }

    if ($dump_aliases && $entity_properties->{aliases}) {
        handle_rows($c, "${entity_type}_alias", $entity_type, $ids);
    }

    if ($dump_annotations && $entity_properties->{annotations}) {
        annotations($c, $entity_type, $ids);
    }

    if ($dump_ratings && $entity_properties->{ratings}) {
        ratings($c, $entity_type, $ids);
    }

    if ($dump_tags && $entity_properties->{tags}) {
        tags($c, $entity_type, $ids);
    }

    return $rows;
}

sub areas {
    my ($c, $ids) = @_;

    my @ids = grep { defined } @{$ids};
    return unless @ids;

    $area_ids{$_} = 1 for @ids;
    $ids = \@ids;

    core_entity($c, 'area', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, $entity_type, $rows);

        handle_rows($c, 'iso_3166_1', 'area', $ids);
        handle_rows($c, 'iso_3166_2', 'area', $ids);
        handle_rows($c, 'iso_3166_3', 'area', $ids);
    });
}

sub artists {
    my ($c, $ids) = @_;

    core_entity($c, 'artist', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        areas($c, [map { @{$_}{qw(area begin_area end_area)} } @$rows]);
        handle_rows($c, 'artist', $rows);
    });
}

sub edits {
    my ($c, $ids) = @_;

    $ids = get_new_ids('edit', $ids);
    return unless @{$ids};

    my $rows = get_rows($c, 'edit', 'id', $ids);
    editors($c, pluck('editor', $rows));
    handle_rows($c, 'edit', $rows);

    $rows = get_rows($c, 'edit_data', 'edit', $ids);
    handle_rows($c, 'edit_data', $rows);

    $rows = get_rows($c, 'vote', 'edit', $ids);
    editors($c, pluck('editor', $rows));
    handle_rows($c, 'vote', $rows);

    for my $entity_type (entities_with('edit_table')) {
        my $table = "edit_$entity_type";
        my $rows = get_rows($c, $table, 'edit', $ids);

        get_core_entities($c, $entity_type, pluck($entity_type, $rows));

        handle_rows($c, $table, $rows);
    }
}

sub editors {
    my ($c, $ids) = @_;

    $ids = get_new_ids('editor', $ids);
    return unless @{$ids};

    my $editor_rows = $c->sql->select_list_of_hashes(
        "SELECT $EDITOR_SANITISED_COLUMNS FROM editor WHERE id = any(?) ORDER BY id",
        $ids,
    );

    # The editor table's 'area' column creates cycles between several tables,
    # so we only do this for areas that we know have been dumped. While it's
    # true that we can detect cycles in core_entity, that would prevent us
    # from filtering out core entities that have already been followed,
    # because the result of the function would depend on the @link_path.
    my @known_areas = grep { defined $_ && $area_ids{$_} } @{ pluck('area', $editor_rows) };
    areas($c, \@known_areas);

    handle_rows($c, 'editor', $editor_rows);

    handle_rows($c, 'editor_language', 'editor', $ids);
}

sub isnis {
    my ($c, $entity_type, $ids) = @_;

    handle_rows($c, "${entity_type}_isni", $entity_type, $ids);
}

sub ipis {
    my ($c, $entity_type, $ids) = @_;

    handle_rows($c, "${entity_type}_ipi", $entity_type, $ids);
}

sub labels {
    my ($c, $ids) = @_;

    core_entity($c, 'label', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        areas($c, pluck('area', $rows));
        handle_rows($c, 'label', $rows);
    });
}

sub places {
    my ($c, $ids) = @_;

    core_entity($c, 'place', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        areas($c, pluck('area', $rows));
        handle_rows($c, 'place', $rows);
    });
}

sub ratings {
    my ($c, $entity_type, $ids) = @_;

    my $table = "${entity_type}_rating_raw";
    my $rows = $c->sql->select_list_of_hashes(
        qq{SELECT $table.* FROM $table
             LEFT JOIN editor_preference ep ON (ep.editor = $table.editor AND ep.name = 'public_ratings')
            WHERE $table.$entity_type = any(?)
              AND coalesce(ep.value, '1') = '1'
            ORDER BY $table.$entity_type},
        $ids,
    );

    editors($c, pluck('editor', $rows));

    handle_rows($c, $table, $rows);
}

sub recordings {
    my ($c, $ids) = @_;

    core_entity($c, 'recording', $ids, sub {
        handle_rows(@_);

        handle_rows($c, 'isrc', 'recording', $ids);
    });
}

sub releases {
    my ($c, $ids) = @_;

    core_entity($c, 'release', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        release_groups($c, pluck('release_group', $rows));

        if ($dump_types) {
            handle_rows($c, 'release_status', 'id', pluck('status', $rows));
            handle_rows($c, 'script', 'id', pluck('script', $rows));
        }

        handle_rows($c, $entity_type, $rows);

        handle_rows($c, 'release_unknown_country', 'release', $ids);

        my $release_country_rows = get_rows($c, 'release_country', 'release', $ids);
        my $country_ids = pluck('country', $release_country_rows);
        my $country_area_rows = get_rows($c, 'country_area', 'area', $country_ids);
        areas($c, $country_ids);
        handle_rows($c, 'country_area', $country_area_rows);
        handle_rows($c, 'release_country', $release_country_rows);

        my $release_label_rows = get_rows($c, 'release_label', 'release', $ids);
        labels($c, pluck('label', $release_label_rows));
        handle_rows($c, 'release_label', $release_label_rows);

        my $medium_rows = get_rows($c, 'medium', 'release', $ids);
        my $medium_ids = pluck('id', $medium_rows);

        if ($dump_types) {
            handle_rows($c, 'medium_format', 'id', pluck('format', $medium_rows));
        }
        handle_rows($c, 'medium', $medium_rows);

        my $cdtoc_rows = get_rows($c, 'medium_cdtoc', 'medium', $medium_ids);
        handle_rows($c, 'cdtoc', 'id', pluck('cdtoc', $cdtoc_rows));
        handle_rows($c, 'medium_cdtoc', $cdtoc_rows);

        handle_rows($c, 'medium_index', 'medium', $medium_ids);

        my $track_rows = get_rows($c, 'track', 'medium', $medium_ids);
        my $recording_ids = pluck('recording', $track_rows);
        recordings($c, $recording_ids);
        relationships($c, 'recording', $recording_ids);
        artist_credits($c, pluck('artist_credit', $track_rows));
        handle_rows($c, 'track', $track_rows);
        my $work_relationships = get_rows($c, 'l_recording_work', 'entity0', $recording_ids);
        relationships($c, 'work', pluck('entity1', $work_relationships));

        my $cover_art_rows = get_rows($c, 'cover_art_archive.cover_art', 'release', $ids);
        edits($c, pluck('edit', $cover_art_rows));
        if ($dump_types) {
            handle_rows($c, 'cover_art_archive.image_type', 'mime_type', pluck('mime_type', $cover_art_rows));
        }
        handle_rows($c, 'cover_art_archive.cover_art', $cover_art_rows);
    });
}

sub release_groups {
    my ($c, $ids) = @_;

    core_entity($c, 'release_group', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, 'release_group', $rows);

        handle_rows($c, 'release_group_secondary_type_join', 'release_group', $ids);
    });
}

sub subscriptions {
    my ($c, $entity_type, $ids) = @_;

    my $table = "editor_subscribe_${entity_type}";

    my $rows = $c->sql->select_list_of_hashes(
        qq{SELECT $table.* FROM $table
             LEFT JOIN editor_preference ep ON (ep.editor = $table.editor AND ep.name = 'public_subscriptions')
            WHERE $table.$entity_type = any(?)
              AND coalesce(ep.value, '1') = '1'
            ORDER BY $table.$entity_type},
        $ids,
    );

    editors($c, pluck('editor', $rows));
    edits($c, pluck('last_edit_sent', $rows));

    handle_rows($c, $table, $rows);
}

sub works {
    my ($c, $ids) = @_;

    core_entity($c, 'work', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, $entity_type, $rows);

        handle_rows($c, 'iswc', 'work', $ids);
        handle_rows($c, 'work_attribute', 'work', $ids);
        handle_rows($c, 'work_language', 'work', $ids);
    });
}

our %CORE_ENTITY_METHODS = (
    area => \&areas,
    artist => \&artists,
    label => \&labels,
    place => \&places,
    recording => \&recordings,
    release => \&releases,
    release_group => \&release_groups,
    work => \&works,
);

sub get_core_entities {
    my ($c, $entity_type, $ids) = @_;

    local %path_ids = ();

    my $method = $CORE_ENTITY_METHODS{$entity_type} // sub {
        my ($c, $ids) = @_;

        core_entity($c, $entity_type, $ids);
    };

    $method->($c, $ids);

    return unless $follow_extra_data;

    my %collection_entities;
    my %relationship_entities;
    my %subscription_entities;

    my $follow_path;
    $follow_path = sub {
        my ($path_part, $depth, @path) = @_;

        if ($depth) {
            my @ids = keys %{ $path_part->{_ids} };
            my $part_type = $path[-1];
            my $properties = $ENTITIES{$part_type};

            if ($depth == 1) {
                my $_dump_collections =
                    $dump_collections && $properties->{collections};

                my $_dump_subscriptions =
                    $dump_subscriptions &&
                    $properties->{subscriptions} &&
                    $properties->{subscriptions}{entity};

                if ($_dump_collections || $_dump_subscriptions) {
                    for my $id (@ids) {
                        $collection_entities{$part_type}{$id} = 1
                            if $_dump_collections;
                        $subscription_entities{$part_type}{$id} = 1
                            if $_dump_subscriptions;
                    }
                }
            }

            if (@path <= 2 ||
                    # There aren't a lot of these entities relative to the
                    # rest, so just get all of their relationships.
                    ($part_type =~ /^(event|instrument|place|series)$/)) {
                $relationship_entities{$part_type}{$_} = 1 for @ids;
            }
        }

        $depth++;
        for my $key (keys %{$path_part}) {
            if ($key ne '_ids') {
                $follow_path->($path_part->{$key}, $depth, @path, $key);
            }
        }
    };

    $follow_path->(\%path_ids, 0);

    local $follow_extra_data = 0;

    for my $type (keys %collection_entities) {
        my @ids = keys %{ $collection_entities{$type} };
        collections($c, $type, \@ids);
    }

    for my $type (keys %relationship_entities) {
        my @ids = keys %{ $relationship_entities{$type} };
        relationships($c, $type, \@ids);
    }

    for my $type (keys %subscription_entities) {
        my @ids = keys %{ $subscription_entities{$type} };
        subscriptions($c, $type, \@ids);
    }
}

sub get_core_entities_by_gids {
    my ($c, $entity_type, $gids) = @_;

    my $ids = $c->sql->select_single_column_array(
        "SELECT id FROM $entity_type WHERE gid = any(?) ORDER BY id",
        $gids
    );

    get_core_entities($c, $entity_type, $ids);
}

1;
