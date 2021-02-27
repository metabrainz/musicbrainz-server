package t::MusicBrainz::Server::Controller::Release::CoverArt;
use DBDefs;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');

    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/cover-art', 'fetch release aliases tab');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@context' => 'http://schema.org',
        'releaseOf' => {
            '@type' => 'MusicAlbum',
            'albumProductionType' => 'http://schema.org/StudioAlbum',
            'byArtist' => {
                'name' => 'Artist',
                '@id' => 'http://musicbrainz.org/artist/945c079d-374e-4436-9448-da92dedef3cf',
                '@type' => 'MusicGroup',
            },
            'creditedTo' => 'Artist',
            '@id' => 'http://musicbrainz.org/release-group/54b9d183-7dab-42ba-94a3-7388a66604b8',
            'name' => 'Release'
        },
        'name' => 'Release',
        'creditedTo' => 'Artist',
        '@id' => 'http://musicbrainz.org/release/14b9d183-7dab-42ba-94a3-7388a66604b8',
        '@type' => 'MusicRelease',
        'image' => {
            'contentUrl' => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . '/release/14b9d183-7dab-42ba-94a3-7388a66604b8/12345.jpg',
            'representativeOfPage' => 'True',
            '@type' => 'ImageObject',
            'encodingFormat' => 'jpg',
            'thumbnail' => [
                {
                    '@type' => 'ImageObject',
                    'contentUrl' => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . '/release/14b9d183-7dab-42ba-94a3-7388a66604b8/12345-250.jpg',
                    'encodingFormat' => 'jpg'
                },
                {
                    'encodingFormat' => 'jpg',
                    'contentUrl' => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . '/release/14b9d183-7dab-42ba-94a3-7388a66604b8/12345-500.jpg',
                    '@type' => 'ImageObject'
                }
            ]
        }
    };
};

1;
