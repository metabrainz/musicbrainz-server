package MusicBrainz::Script::EntityDump;

use strict;
use warnings;

use base 'Exporter';
use feature 'state';
use Data::Compare qw( Compare );
use MusicBrainz::Script::Utils qw( get_primary_keys );
use MusicBrainz::Server::Constants qw( %ENTITIES );

our @EXPORT_OK = qw(
    get_core_entities
    get_core_entities_by_gids
);

# Should be set by users of this package.
our $handle_inserts = sub {};

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

    artists($c, pluck('artist', $name_rows), link_path => ['artist_credit']);
    handle_rows($c, 'artist_credit', $rows);
    handle_rows($c, 'artist_credit_name', $name_rows);
}

sub relationships {
    my ($c, $entity_type, $entity_ids, %opts) = @_;

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

        $opts{link_path} = [@{$opts{link_path} // []}, $entity_type];

        get_core_entities(
            $c,
            $target_type,
            pluck($target_column, $results),
            %opts
        );

        my $link_ids = pluck('link', $results);
        handle_rows($c, 'link', 'id', $link_ids);
        handle_rows($c, 'link_attribute', 'link', $link_ids);
        handle_rows($c, 'link_attribute_text_value', 'link', $link_ids);

        handle_rows($c, $table, $results);
    }
}

sub core_entity {
    my ($c, $entity_type, $ids, %opts) = @_;

    my $rows = get_rows($c, $entity_type, 'id', $ids);
    my $entity_properties = $ENTITIES{$entity_type};

    if ($entity_properties->{artist_credits}) {
        artist_credits($c, pluck('artist_credit', $rows));
    }

    my $callback = $opts{callback} // \&handle_rows;
    $callback->($c, $entity_type, $rows);

    if ($entity_properties->{aliases}) {
        handle_rows($c, "${entity_type}_alias", $entity_type, pluck('id', $rows));
    }

    if ($entity_properties->{tags}) {
        tags($c, $entity_type, $ids);
    }

    if (scalar(@{$opts{link_path} // []}) == 0) {
        relationships($c, $entity_type, $ids, %opts);
    }

    return $rows;
}

sub artists {
    my ($c, $ids, %opts) = @_;

    core_entity($c, 'artist', $ids, %opts, callback => sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, 'area', 'id', [map { @{$_}{qw(area begin_area end_area)} } @$rows]);
        handle_rows($c, $entity_type, $rows);
    });
}

sub recordings {
    my ($c, $ids, %opts) = @_;

    my $link_path = $opts{link_path} // [];

    core_entity($c, 'recording', $ids, %opts, callback => sub {
        handle_rows(@_);

        handle_rows($c, 'isrc', 'recording', $ids);

        if (Compare($link_path, ['release']) || Compare($link_path, ['release_group', 'release'])) {
            relationships($c, 'recording', $ids, %opts);
        }
    });
}

sub releases {
    my ($c, $ids, %opts) = @_;

    core_entity($c, 'release', $ids, %opts, callback => sub {
        my ($c, $entity_type, $rows) = @_;

        get_core_entities($c, 'release_group', pluck('release_group', $rows), link_path => ['release']);
        handle_rows($c, 'release_status', 'id', pluck('status', $rows));
        handle_rows($c, 'script', 'id', pluck('script', $rows));

        handle_rows($c, $entity_type, $rows);

        handle_rows($c, 'release_unknown_country', 'release', $ids);

        my $release_country_rows = get_rows($c, 'release_event', 'release', $ids);
        get_core_entities($c, 'area', pluck('country', $release_country_rows), link_path => ['release']);
        handle_rows($c, 'release_country', $release_country_rows);

        my $release_label_rows = get_rows($c, 'release_label', 'release', $ids);
        get_core_entities($c, 'label', pluck('label', $release_label_rows), link_path => ['release']);
        handle_rows($c, 'release_label', $release_label_rows);

        my $medium_rows = get_rows($c, 'medium', 'release', $ids);
        my $medium_ids = pluck('id', $medium_rows);

        handle_rows($c, 'medium_format', 'id', pluck('format', $medium_rows));
        handle_rows($c, 'medium', $medium_rows);

        my $cdtoc_rows = get_rows($c, 'medium_cdtoc', 'medium', $medium_ids);
        handle_rows($c, 'cdtoc', 'id', pluck('cdtoc', $cdtoc_rows));
        handle_rows($c, 'medium_cdtoc', $cdtoc_rows);

        my $track_rows = get_rows($c, 'track', 'medium', $medium_ids);
        recordings($c, pluck('recording', $track_rows), %opts);
        artist_credits($c, pluck('artist_credit', $track_rows));
        handle_rows($c, 'track', $track_rows);

        my $cover_art_rows = get_rows($c, 'cover_art_archive.cover_art', 'release', $ids);
        handle_rows($c, 'edit', 'id', pluck('edit', $cover_art_rows));
        handle_rows($c, 'cover_art_archive.image_type', 'mime_type', pluck('mime_type', $cover_art_rows));
        handle_rows($c, 'cover_art_archive.cover_art', $cover_art_rows);
    });
}

sub works {
    my ($c, $ids, %opts) = @_;

    my $link_path = $opts{link_path} // [];
    my @via_release = ('release', 'recording');

    core_entity($c, 'work', $ids, %opts, callback => sub {
        my ($c, $entity_type, $rows) = @_;

        handle_rows($c, $entity_type, $rows);

        if (Compare($link_path, \@via_release) || Compare($link_path, ['release_group', @via_release])) {
            relationships($c, 'work', $ids, %opts);
        }
    });
}

our %CORE_ENTITY_METHODS = (
    artist => \&artists,
    recording => \&recordings,
    release => \&releases,
    work => \&works,
);

sub get_core_entities {
    my ($c, $entity_type, $ids, %opts) = @_;

    my $method = $CORE_ENTITY_METHODS{$entity_type} // sub {
        my ($c, $ids, %opts) = @_;

        core_entity($c, $entity_type, $ids, %opts);
    };

    $method->($c, $ids, %opts);
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
