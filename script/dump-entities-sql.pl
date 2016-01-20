#!/usr/bin/env perl
use strict;
use warnings;

use feature 'state';
use feature 'switch';

use FindBin;
use lib "$FindBin::Bin/../lib";
use Carp qw( croak );
use Data::Compare qw( Compare );
use Encode qw( encode );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Context;

no warnings 'experimental::smartmatch';

sub pluck {
    my ($prop, $values) = @_;
    [map { $_->{$prop} } @$values];
}

sub quote_column {
    my ($type, $data) = @_;

    return "NULL" unless defined $data;

    croak "no type" unless defined $type;

    my $ret;

    given ($type) {
        when (/^integer\[\]/) { $ret = "'{" . join(",", @$data) . "}'"; }
        when (/^integer/) { $ret = $data; }
        when (/^smallint/) { $ret = $data; }
        default {
            $data =~ s/'/''/g;
            $ret = "'$data'";
        }
    }

    return $ret;
}

sub print_inserts {
    my ($c, $table, $rows) = @_;

    state $seen_values = {};

    my $seen_table_values = ($seen_values->{$table} //= {});

    return unless keys @$rows;

    my @columns = sort keys %{$rows->[0]};
    my $columns_string = join ', ', @columns;

    my @tuple_strings = grep { $_ } map {
        my $row = $_;

        my $values_string = join ', ', map {
            quote_column($c->sql->get_column_type_name($table, $_), $row->{$_})
        } @columns;

        $values_string = "\t($values_string)";

        if (exists $seen_table_values->{$values_string}) {
            undef;
        } else {
            $seen_table_values->{$values_string} = 1;
            $values_string;
        }
    } @$rows;

    return unless @tuple_strings;

    my $tuples_string = join ",\n", @tuple_strings;
    print encode('utf-8', "INSERT INTO $table ($columns_string) VALUES\n${tuples_string};\n");
}

sub get_rows {
    my ($c, $table, $column, $values) = @_;

    return unless @$values;

    my $column_type = $c->sql->get_column_type_name($table, $column);
    my $condition;

    if (scalar(@$values) > 1) {
        my $values_string = join(', ', map { quote_column($column_type, $_) } grep { defined } @$values);

        return unless $values_string;

        $condition = "$column IN ($values_string)";
    } else {
        $condition = "$column = " . quote_column($column_type, $values->[0]);
    }

    return $c->sql->select_list_of_hashes("SELECT * FROM $table WHERE $condition ORDER BY $column");
}

sub print_rows {
    my ($c, $table, $column, $values) = @_;

    my $rows = get_rows($c, $table, $column, $values);
    print_inserts($c, $table, $rows);
}

sub tags {
    my ($c, $entity_type, $ids) = @_;

    my $table = "${entity_type}_tag";
    my $rows = get_rows($c, $table, $entity_type, $ids);

    print_rows($c, 'tag', 'id', pluck('tag', $rows));
    print_inserts($c, $table, $rows);
}

sub artist_credits {
    my ($c, $ids) = @_;

    my $rows = get_rows($c, 'artist_credit', 'id', $ids);
    my $name_rows = get_rows($c, 'artist_credit_name', 'artist_credit', $ids);

    artists($c, pluck('artist', $name_rows), link_path => ['artist_credit']);
    print_inserts($c, 'artist_credit', $rows);
    print_inserts($c, 'artist_credit_name', $name_rows);
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
        print_rows($c, 'link', 'id', $link_ids);
        print_rows($c, 'link_attribute', 'link', $link_ids);
        print_rows($c, 'link_attribute_text_value', 'link', $link_ids);

        print_inserts($c, $table, $results);
    }
}

sub core_entity {
    my ($c, $entity_type, $ids, %opts) = @_;

    my $rows = get_rows($c, $entity_type, 'id', $ids);
    my $entity_properties = $ENTITIES{$entity_type};

    if ($entity_properties->{artist_credits}) {
        artist_credits($c, pluck('artist_credit', $rows));
    }

    my $callback = $opts{callback} // \&print_inserts;
    $callback->($c, $entity_type, $rows);

    if ($entity_properties->{aliases}) {
        print_rows($c, "${entity_type}_alias", $entity_type, pluck('id', $rows));
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

        print_rows($c, 'area', 'id', [map { @{$_}{qw(area begin_area end_area)} } @$rows]);
        print_inserts($c, $entity_type, $rows);
    });
}

sub recordings {
    my ($c, $ids, %opts) = @_;

    my $link_path = $opts{link_path} // [];

    core_entity($c, 'recording', $ids, %opts, callback => sub {
        print_inserts(@_);

        print_rows($c, 'isrc', 'recording', $ids);

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
        print_rows($c, 'release_status', 'id', pluck('status', $rows));
        print_rows($c, 'script', 'id', pluck('script', $rows));

        print_inserts($c, $entity_type, $rows);

        print_rows($c, 'release_unknown_country', 'release', $ids);

        my $release_country_rows = get_rows($c, 'release_event', 'release', $ids);
        get_core_entities($c, 'area', pluck('country', $release_country_rows), link_path => ['release']);
        print_inserts($c, 'release_country', $release_country_rows);

        my $release_label_rows = get_rows($c, 'release_label', 'release', $ids);
        get_core_entities($c, 'label', pluck('label', $release_label_rows), link_path => ['release']);
        print_inserts($c, 'release_label', $release_label_rows);

        my $medium_rows = get_rows($c, 'medium', 'release', $ids);
        my $medium_ids = pluck('id', $medium_rows);

        print_rows($c, 'medium_format', 'id', pluck('format', $medium_rows));
        print_inserts($c, 'medium', $medium_rows);

        my $cdtoc_rows = get_rows($c, 'medium_cdtoc', 'medium', $medium_ids);
        print_rows($c, 'cdtoc', 'id', pluck('cdtoc', $cdtoc_rows));
        print_inserts($c, 'medium_cdtoc', $cdtoc_rows);

        my $track_rows = get_rows($c, 'track', 'medium', $medium_ids);
        recordings($c, pluck('recording', $track_rows), %opts);
        artist_credits($c, pluck('artist_credit', $track_rows));
        print_inserts($c, 'track', $track_rows);

        my $cover_art_rows = get_rows($c, 'cover_art_archive.cover_art', 'release', $ids);
        print_rows($c, 'edit', 'id', pluck('edit', $cover_art_rows));
        print_rows($c, 'cover_art_archive.image_type', 'mime_type', pluck('mime_type', $cover_art_rows));
        print_inserts($c, 'cover_art_archive.cover_art', $cover_art_rows);
    });
}

sub works {
    my ($c, $ids, %opts) = @_;

    my $link_path = $opts{link_path} // [];
    my @via_release = ('release', 'recording');

    core_entity($c, 'work', $ids, %opts, callback => sub {
        my ($c, $entity_type, $rows) = @_;

        print_inserts($c, $entity_type, $rows);

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

sub dump_release_groups {
    my ($c, $gids) = @_;

    print 'ALTER TABLE medium DISABLE TRIGGER ALL;';

    my $rows = get_core_entities_by_gids($c, 'release_group', $gids);

    my $release_ids = $c->sql->select_single_column_array(
        'SELECT release FROM release_group WHERE id = any(?) ORDER BY release',
        pluck('id', $rows)
    );

    releases($c, $release_ids);

    print 'ALTER TABLE medium ENABLE TRIGGER ALL;';
}

our %DUMP_METHODS = (
    release_group => \&dump_release_groups,
);

sub main {
    my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');

    my ($entity_type, @gids) = @ARGV;
    my $arguments_string = $entity_type . ' ' . join(' ', @gids);

    print <<"EOSQL";
-- Automatically generated, do not edit.
-- $arguments_string

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

EOSQL

    my $dump_method = $DUMP_METHODS{$entity_type} // sub {
        my ($c, $gids) = @_;
        get_core_entities_by_gids($c, $entity_type, $gids);
    };

    $dump_method->($c, \@gids);

    print <<'EOSQL';

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
EOSQL

}

main();
