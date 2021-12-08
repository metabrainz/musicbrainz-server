package t::MusicBrainz::Server::Controller::ReleaseGroup::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );
use utf8;

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/release-group/ecc33260-454c-11de-8a39-0800200c9a66/aliases', 'fetch release group');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/release-group/ecc33260-454c-11de-8a39-0800200c9a66',
        'albumReleaseType' => 'http://schema.org/AlbumRelease',
        'byArtist' => {
            '@type' => ['Person', 'MusicGroup'],
            '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
            'name' => 'Test Artist'
        },
        'creditedTo' => 'Test Artist',
        'alternateName' => [
            'Test RG 1 Alias 1',
            'Test RG 1 Alias 2'
        ],
        'albumProductionType' => 'http://schema.org/StudioAlbum',
        'name' => 'Test RG 1',
        '@type' => 'MusicAlbum',
        '@context' => 'http://schema.org'
    };
};

1;
