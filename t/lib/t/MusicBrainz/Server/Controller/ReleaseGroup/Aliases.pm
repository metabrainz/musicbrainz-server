package t::MusicBrainz::Server::Controller::ReleaseGroup::Aliases;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether release group aliases are correctly listed on the
release group alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Release group alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/release-group/ecc33260-454c-11de-8a39-0800200c9a66/aliases',
        'Fetched release group aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains(
        'Test RG 1 Alias 1',
        'Alias page lists the first alias',
    );
    $mech->text_contains(
        'Release group name',
        'Alias page lists the first alias type',
    );
    $mech->text_contains(
        'Test RG 1 Alias 2',
        'Alias page lists the second alias',
    );
    $mech->text_contains(
        'Search hint',
        'Alias page lists the first alias type',
    );

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/release-group/ecc33260-454c-11de-8a39-0800200c9a66',
        'albumReleaseType' => 'http://schema.org/AlbumRelease',
        'byArtist' => {
            '@type' => ['Person', 'MusicGroup'],
            '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
            'name' => 'Test Artist'
        },
        'creditedTo' => 'Test Artist',
        # Search hint should not appear on JSON-LD
        'alternateName' => ['Test RG 1 Alias 1'],
        'albumProductionType' => 'http://schema.org/StudioAlbum',
        'name' => 'Test RG 1',
        '@type' => 'MusicAlbum',
        '@context' => 'http://schema.org'
    };
};

1;
