package MusicBrainz::Script::SampleDataDump;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

use DBDefs;
use File::Copy qw( copy );
use List::AllUtils qw( natatime );
use Moose;
use MusicBrainz::Script::DatabaseDump;
use MusicBrainz::Script::EntityDump qw(
    get_core_entities
    get_core_entities_by_gids
);
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Log qw( log_info );
use Readonly;

with 'MooseX::Runnable';
with 'MooseX::Getopt';

has database => (
    is => 'ro',
    isa => 'Str',
    default => 'READWRITE',
    traits => ['Getopt'],
    documentation => 'database to dump from (default: READWRITE)',
);

has output_dir => (
    is => 'ro',
    isa => 'Str',
    default => q(.),
    traits => ['Getopt'],
    cmd_flag => 'output-dir',
    documentation => 'location where the dump is outputted (default: .)',
);

Readonly our @DUMP_ALL => qw(
    alternative_release_type
    area_alias_type
    area_attribute_type
    area_attribute_type_allowed_value
    area_type
    artist_alias_type
    artist_attribute_type
    artist_attribute_type_allowed_value
    artist_type
    cover_art_archive.art_type
    cover_art_archive.image_type
    editor_collection_type
    event_alias_type
    event_attribute_type
    event_attribute_type_allowed_value
    event_type
    gender
    genre
    genre_alias
    genre_alias_type
    instrument
    instrument_alias_type
    instrument_attribute_type
    instrument_attribute_type_allowed_value
    instrument_type
    label_alias_type
    label_attribute_type
    label_attribute_type_allowed_value
    label_type
    language
    link_attribute_type
    link_creditable_attribute_type
    link_text_attribute_type
    link_type
    link_type_attribute_type
    medium_attribute_type
    medium_attribute_type_allowed_format
    medium_attribute_type_allowed_value
    medium_attribute_type_allowed_value_allowed_format
    medium_format
    orderable_link_type
    place_alias_type
    place_attribute_type
    place_attribute_type_allowed_value
    place_type
    recording_alias_type
    recording_attribute_type
    recording_attribute_type_allowed_value
    release_alias_type
    release_attribute_type
    release_attribute_type_allowed_value
    release_group_alias_type
    release_group_attribute_type
    release_group_attribute_type_allowed_value
    release_group_primary_type
    release_group_secondary_type
    release_packaging
    release_status
    script
    series_alias_type
    series_attribute_type
    series_attribute_type_allowed_value
    series_ordering_type
    series_type
    work_alias_type
    work_attribute_type
    work_attribute_type_allowed_value
    work_type
);

my $mbdump_handle;
my $sample_dump;
my %table_map;

$MusicBrainz::Script::EntityDump::dump_aliases = 1;
$MusicBrainz::Script::EntityDump::dump_annotations = 1;
$MusicBrainz::Script::EntityDump::dump_collections = 1;
$MusicBrainz::Script::EntityDump::dump_edits = 1;
$MusicBrainz::Script::EntityDump::dump_gid_redirects = 1;
$MusicBrainz::Script::EntityDump::dump_meta_tables = 1;
$MusicBrainz::Script::EntityDump::dump_ratings = 1;
$MusicBrainz::Script::EntityDump::dump_subscriptions = 1;
$MusicBrainz::Script::EntityDump::dump_tags = 1;
$MusicBrainz::Script::EntityDump::dump_types = 1;
$MusicBrainz::Script::EntityDump::follow_extra_data = 1;
$MusicBrainz::Script::EntityDump::relationships_cardinality = undef;
@MusicBrainz::Script::EntityDump::skip_tables = @DUMP_ALL;

$MusicBrainz::Script::EntityDump::handle_inserts = sub {
    my ($c, $schema, $table, $rows) = @_;

    $table_map{$table} = 1;

    $mbdump_handle->dump_rows($schema, $table, $rows);
};

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
        fresh_connector => 1,
    );

    my $mbdump = MusicBrainz::Script::DatabaseDump->new(
        c => $c,
        compression => 'xz',
        output_dir => $self->output_dir,
        isolation_level => 'READ COMMITTED',
    );
    $mbdump_handle = $mbdump;
    $sample_dump = $self;

    my $sample_artist_gids = [
        # Nine Inch Nails
        'b7ffd2af-418f-4be2-bdd1-22f8b48613da',
        # Kanye West
        '164f0d73-1234-4e2c-8743-d77bf2191051',
        # Пётр Ильич Чайковский
        '9ddd7abc-9e1b-471d-8031-583bc6bc8be9',
    ];

    my $total = scalar @{$sample_artist_gids};
    get_core_entities_by_gids($c, 'artist', $sample_artist_gids);
    log_info { "Dumped $total/$total artists" };

    my $sample_artist_ids = $c->sql->select_single_column_array(
        'SELECT id FROM artist WHERE gid = any(?)',
        $sample_artist_gids,
    );

    my $standalone_recordings = $c->sql->select_single_column_array(q{
        SELECT r.id FROM recording r
          JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
         WHERE acn.artist = any(?)
           AND NOT EXISTS (SELECT 1 FROM track t WHERE t.recording = r.id)
    }, $sample_artist_ids);

    $total = scalar @{$standalone_recordings};
    get_core_entities($c, 'recording', $standalone_recordings);
    log_info { "Dumped $total/$total standalone recordings" };

    my $sample_releases = $c->sql->select_single_column_array(q{
        SELECT r.id FROM release r
          JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
         WHERE acn.artist = any($1)
        UNION
        SELECT r.id FROM release r
          JOIN medium m ON m.release = r.id
          JOIN track t ON t.medium = m.id
          JOIN artist_credit_name acn ON acn.artist_credit = t.artist_credit
         WHERE acn.artist = any($1)
        UNION
        SELECT r.id FROM release r
          JOIN medium m ON m.release = r.id
          JOIN track t ON t.medium = m.id
          JOIN recording rec ON rec.id = t.recording
          JOIN artist_credit_name acn ON acn.artist_credit = rec.artist_credit
         WHERE acn.artist = any($1)
    }, $sample_artist_ids);

    my $it = natatime 50, @{$sample_releases};
    my $count = 0;
    $total = scalar @{$sample_releases};
    while (my @ids = $it->()) {
        get_core_entities($c, 'release', \@ids);
        $count += scalar @ids;
        log_info { "Dumped $count/$total releases" };
    }

    for my $table (@DUMP_ALL) {
        $mbdump->dump_table($table);
    }

    copy(DBDefs->MB_SERVER_ROOT . '/admin/COPYING-CCShareAlike',
         $mbdump->export_dir . '/COPYING') or die $!;

    my @all_tables = sort { $a cmp $b } (@DUMP_ALL, keys %table_map);
    $mbdump->make_tar('mbdump-sample.tar.xz', @all_tables);

    $mbdump->end_dump;
    undef $mbdump_handle;
    undef $sample_dump;
    return 0;
}

1;
