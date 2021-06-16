#!/usr/bin/env perl
use strict;
use warnings;

use feature 'switch';

use Moose;
use FindBin;
use Getopt::Long;
use lib "$FindBin::Bin/../lib";
use Carp qw( croak );
use Encode qw( encode );
use MusicBrainz::Script::EntityDump qw( edits get_core_entities_by_gids );
use MusicBrainz::Server::Context;

no warnings 'experimental::smartmatch';

my $database = 'READWRITE';
my $aliases = 0;
my $annotations = 0;
# collections, relationships, subscriptions
my $extra_data = 0;
my $ratings = 0;
my $tags = 0;

GetOptions(
    'database=s'    => \$database,
    'aliases!'      => \$aliases,
    'annotations!'  => \$annotations,
    'extra-data!'   => \$extra_data,
    'ratings!'      => \$ratings,
    'tags!'         => \$tags,
) or exit 2;

$MusicBrainz::Script::EntityDump::dump_aliases = $aliases;
$MusicBrainz::Script::EntityDump::dump_annotations = $annotations;
$MusicBrainz::Script::EntityDump::follow_extra_data = $extra_data;
$MusicBrainz::Script::EntityDump::dump_ratings = $ratings;
$MusicBrainz::Script::EntityDump::dump_tags = $tags;
# release_coverart rows conflict with those added by the a_ins_release
# trigger. A better alternative may be to use INSERT ... ON CONFLICT DO
# UPDATE for these.
@MusicBrainz::Script::EntityDump::skip_tables = qw(
    release_coverart
);

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

$MusicBrainz::Script::EntityDump::handle_inserts = sub {
    my ($c, $schema, $table, $rows) = @_;

    my @columns = $c->sql->get_ordered_columns("$schema.$table");
    my $columns_string = join ', ', @columns;

    my $tuples_string = join ",\n", map {
        my $row = $_;

        my $values_string = join ', ', map {
            quote_column($c->sql->get_column_type_name("$schema.$table", $_), $row->{$_})
        } @columns;

        "\t($values_string)";
    } @{$rows};

    print encode('utf-8', "INSERT INTO $schema.$table ($columns_string) VALUES\n${tuples_string};\n");
};

sub dump_release_groups {
    my ($c, $gids) = @_;

    print 'ALTER TABLE medium DISABLE TRIGGER ALL;';

    my $rows = get_core_entities_by_gids($c, 'release_group', $gids);

    my $release_ids = $c->sql->select_single_column_array(
        'SELECT release.id FROM release WHERE release_group = any(?) ORDER BY release.id',
        pluck('id', $rows)
    );

    releases($c, $release_ids);

    print 'ALTER TABLE medium ENABLE TRIGGER ALL;';
}

our %DUMP_METHODS = (
    edit => \&edits,
    release_group => \&dump_release_groups,
);

sub main {
    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $database,
    );

    my ($entity_type, @ids) = @ARGV;
    my $arguments_string = $entity_type . ' ' . join(' ', @ids);

    print <<~"EOSQL";
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

    $dump_method->($c, \@ids);

    print <<~'EOSQL';
        -- Restore triggers.
        CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link
            FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
        EOSQL

}

main();
