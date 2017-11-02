package MusicBrainz::Script::EntityDump;

use strict;
use warnings;

use base 'Exporter';
use feature 'state';
use MusicBrainz::Script::Utils qw( get_primary_keys );
use MusicBrainz::Server::Constants qw( %ENTITIES );

our @EXPORT_OK = qw(
    get_core_entities
    get_core_entities_by_gids
);

our @link_path;

# Should be set by users of this package.
our $handle_inserts = sub {};
our $follow_extra_data = 1;
our %path_ids;

sub pluck {
    my ($prop, $values) = @_;
    [map { $_->{$prop} } @$values];
}

sub handle_rows {
    my ($c, $table) = @_;

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
        $handle_inserts->($c, $table, \@new_rows);
    }
};

sub get_rows {
    my ($c, $table, $column, $values) = @_;

    return unless @$values;

    my $column_type = $c->sql->get_column_type_name($table, $column);
    my @values = grep { defined } @{$values};

    return unless @values;

    return $c->sql->select_list_of_hashes(
        "SELECT * FROM $table WHERE $column = any(?) ORDER BY $column",
        \@values,
    );
}

sub tags {
    my ($c, $entity_type, $ids) = @_;

    my $table = "${entity_type}_tag";
    my $rows = get_rows($c, $table, $entity_type, $ids);

    handle_rows($c, 'tag', 'id', pluck('tag', $rows));
    handle_rows($c, $table, $rows);
}

sub artist_credits {
    my ($c, $ids) = @_;

    my $rows = get_rows($c, 'artist_credit', 'id', $ids);
    my $name_rows = get_rows($c, 'artist_credit_name', 'artist_credit', $ids);

    artists($c, pluck('artist', $name_rows));
    handle_rows($c, 'artist_credit', $rows);
    handle_rows($c, 'artist_credit_name', $name_rows);
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

        my $results = $c->sql->select_list_of_hashes(
            "SELECT $table.*
               FROM $table
               JOIN link ON link.id = $table.link
               JOIN link_type ON link_type.id = link.link_type
              WHERE $column = any(?)
                AND link_type.${column}_cardinality = 0
              ORDER BY $table.id",
            $entity_ids
        );

        get_core_entities(
            $c,
            $target_type,
            pluck($target_column, $results),
        );

        my $link_ids = pluck('link', $results);
        handle_rows($c, 'link', 'id', $link_ids);
        handle_rows($c, 'link_attribute', 'link', $link_ids);
        handle_rows($c, 'link_attribute_text_value', 'link', $link_ids);

        handle_rows($c, $table, $results);
    }
}

sub core_entity {
    my ($c, $entity_type, $ids, $callback) = @_;

    local @link_path = (@link_path, $entity_type);

    my $last_part;
    $last_part = ($path_ids{$_} //= {}) for @link_path;
    $last_part->{_ids}{$_} = 1 for @{$ids};

    my $rows = get_rows($c, $entity_type, 'id', $ids);
    my $entity_properties = $ENTITIES{$entity_type};

    if ($entity_properties->{artist_credits}) {
        artist_credits($c, pluck('artist_credit', $rows));
    }

    $callback //= \&handle_rows;
    $callback->($c, $entity_type, $rows);

    if ($entity_properties->{aliases}) {
        handle_rows($c, "${entity_type}_alias", $entity_type, pluck('id', $rows));
    }

    if ($entity_properties->{tags}) {
        tags($c, $entity_type, $ids);
    }

    return $rows;
}

sub areas {
    my ($c, $ids) = @_;

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

        get_core_entities($c, 'release_group', pluck('release_group', $rows));
        handle_rows($c, 'release_status', 'id', pluck('status', $rows));
        handle_rows($c, 'script', 'id', pluck('script', $rows));

        handle_rows($c, $entity_type, $rows);

        handle_rows($c, 'release_unknown_country', 'release', $ids);

        my $release_country_rows = get_rows($c, 'release_country', 'release', $ids);
        areas($c, pluck('country', $release_country_rows));
        handle_rows($c, 'release_country', $release_country_rows);

        my $release_label_rows = get_rows($c, 'release_label', 'release', $ids);
        labels($c, pluck('label', $release_label_rows));
        handle_rows($c, 'release_label', $release_label_rows);

        my $medium_rows = get_rows($c, 'medium', 'release', $ids);
        my $medium_ids = pluck('id', $medium_rows);

        handle_rows($c, 'medium_format', 'id', pluck('format', $medium_rows));
        handle_rows($c, 'medium', $medium_rows);

        my $cdtoc_rows = get_rows($c, 'medium_cdtoc', 'medium', $medium_ids);
        handle_rows($c, 'cdtoc', 'id', pluck('cdtoc', $cdtoc_rows));
        handle_rows($c, 'medium_cdtoc', $cdtoc_rows);

        my $track_rows = get_rows($c, 'track', 'medium', $medium_ids);
        my $recording_ids = pluck('recording', $track_rows);
        recordings($c, $recording_ids);
        relationships($c, 'recording', $recording_ids);
        artist_credits($c, pluck('artist_credit', $track_rows));
        handle_rows($c, 'track', $track_rows);

        my $cover_art_rows = get_rows($c, 'cover_art_archive.cover_art', 'release', $ids);
        handle_rows($c, 'edit', 'id', pluck('edit', $cover_art_rows));
        handle_rows($c, 'cover_art_archive.image_type', 'mime_type', pluck('mime_type', $cover_art_rows));
        handle_rows($c, 'cover_art_archive.cover_art', $cover_art_rows);
    });
}

sub works {
    my ($c, $ids) = @_;

    core_entity($c, 'work', $ids, sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, $entity_type, $rows);
    });
}

our %CORE_ENTITY_METHODS = (
    area => \&areas,
    artist => \&artists,
    label => \&labels,
    place => \&places,
    recording => \&recordings,
    release => \&releases,
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

    my %relationship_entities;

    my $follow_path;
    $follow_path = sub {
        my ($path_part, $depth, @path) = @_;

        if ($depth) {
            my @ids = keys %{ $path_part->{_ids} };
            my $part_type = $path[-1];

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

    for my $type (keys %relationship_entities) {
        my @ids = keys %{ $relationship_entities{$type} };
        relationships($c, $type, \@ids);
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
