package t::MusicBrainz::Server::Controller::Release::Aliases;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether release aliases are correctly listed on the release
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Release alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/release/f205627f-b70a-409d-adbe-66289b614e80/aliases',
        'Fetched release aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('Ærial', 'Alias page lists the alias');
    $mech->text_contains('Release name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        'gtin14' => '0094634396028',
        'alternateName' => ["\x{c6}rial"],
        'creditedTo' => 'Kate Bush',
        'recordLabel' => {
            'name' => 'Warp Records',
            '@type' => 'MusicLabel',
            '@id' => 'http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190'
        },
        'releaseOf' => {
            'albumReleaseType' => 'http://schema.org/AlbumRelease',
            'byArtist' => {
                '@id' => 'http://musicbrainz.org/artist/4b585938-f271-45e2-b19a-91c634b5e396',
                '@type' => ['Person', 'MusicGroup'],
                'name' => 'Kate Bush',
            },
            'creditedTo' => 'Kate Bush',
            'name' => 'Aerial',
            '@type' => 'MusicAlbum',
            '@id' => 'http://musicbrainz.org/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5',
            'albumProductionType' => 'http://schema.org/StudioAlbum'
        },
        'hasReleaseRegion' => [
            {
                'releaseCountry' => {
                    '@type' => 'Country',
                    '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                    'name' => 'United Kingdom'
                },
                '@type' => 'CreativeWorkReleaseRegion',
                'releaseDate' => '2005-11-07'
            }
        ],
        '@type' => 'MusicRelease',
        'catalogNumber' => '343 960 2',
        'duration' => 'PT1H20M05S',
        '@id' => 'http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
        'name' => 'Aerial',
        'musicReleaseFormat' => 'http://schema.org/CDFormat',
        '@context' => 'https://schema.org/docs/jsonldcontext.json'
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
