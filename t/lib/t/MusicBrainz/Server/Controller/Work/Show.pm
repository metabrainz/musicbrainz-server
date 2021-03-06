package t::MusicBrainz::Server::Controller::Work::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce");
    html_ok($mech->content);
    $mech->content_like(qr/Dancing Queen/, 'work title');
    $mech->content_like(qr/Composition/, 'work type');
    $mech->content_like(qr{/work/745c079d-374e-4436-9448-da92dedef3ce}, 'link back to work');
    $mech->content_like(qr/T-000.000.001-0/, 'iswc');
    $mech->content_like(qr{Test annotation 6}, 'annotation');

    page_test_jsonld $mech => {
        '@type' => 'MusicComposition',
        'iswcCode' => 'T-000.000.001-0',
        'sameAs' => 'http://musicbrainz.org/work/28e73402-5666-4d74-80ab-c3734dc699ea',
        '@context' => 'http://schema.org',
        'name' => 'Dancing Queen',
        '@id' => 'http://musicbrainz.org/work/745c079d-374e-4436-9448-da92dedef3ce'
    };

    # Missing
    $mech->get('/work/dead079d-374e-4436-9448-da92dedef3ce', 'work not found');
    is($mech->status(), 404);

    # Invalid UUID
    $mech->get('/work/xxxx079d-374e-4436-9448-da92dedef3ce', 'bad request');
    is($mech->status(), 400);
};

test 'Embedded JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+controller_work');

    $mech->get_ok('/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@type' => 'MusicComposition',
        '@id' => 'http://musicbrainz.org/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e',
        'name' => 'W1',
        'recordedAs' => {
            '@type' => 'MusicRecording',
            '@id' => 'http://musicbrainz.org/recording/aeb9b50a-e14a-4330-a2e6-7c8a311a9822',
            'name' => 'R',
            'duration' => 'PT05M00S'
        },
        'sameAs' => 'http://musicbrainz.org/work/a30a4245-a7ec-4979-8b1e-b549f2782239',
        '@context' => 'http://schema.org',
        'musicArrangement' => [
            {
                '@id' => 'http://musicbrainz.org/work/a72c9be6-5ef9-4bdf-afa1-6a3db697ff62',
                'name' => 'W4',
                '@type' => 'MusicComposition'
            },
            {
              '@id' => 'http://musicbrainz.org/work/5c089ef8-ada9-4dc0-a2bc-f4d7e84df840',
              '@type' => 'MusicComposition',
              'name' => 'W5',
            },
        ],
        'publisher' => {
            '@type' => 'MusicGroup',
            '@id' => 'http://musicbrainz.org/artist/e46bb5a2-f4df-44a1-aafe-d07f4c998ba0',
            'name' => 'A'
        },
        'composer' => [
            {
                '@id' => 'http://musicbrainz.org/artist/e46bb5a2-f4df-44a1-aafe-d07f4c998ba0',
                '@type' => 'MusicGroup',
                'name' => 'A',
            },
            {
                '@id' => 'http://musicbrainz.org/artist/213d688f-2a10-463a-86b8-d50a1ae624ee',
                '@type' => 'MusicGroup',
                'name' => 'B',
            },
        ],
        'iswcCode' => ['T-000.000.001-0', 'T-000.000.002-0'],
        'lyricist' => {
            'name' => 'A',
            '@id' => 'http://musicbrainz.org/artist/e46bb5a2-f4df-44a1-aafe-d07f4c998ba0',
            '@type' => 'MusicGroup'
        },
        'includedComposition' => [
            {
                '@type' => 'MusicComposition',
                '@id' => 'http://musicbrainz.org/work/aff4e1f7-d3dd-4621-bd4c-25d1b87bb286',
                'name' => 'W2'
            },
            {
                '@type' => 'MusicComposition',
                '@id' => 'http://musicbrainz.org/work/11d4a39f-ee76-459f-aaf5-b84131d867f2',
                'name' => 'W3'
            },
        ],
        'inLanguage' => 'en'
    };

    $mech->get_ok('/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e?direction=2&link_type_id=278');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@type' => 'MusicComposition',
        '@id' => 'http://musicbrainz.org/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e',
        'name' => 'W1',
        'recordedAs' => {
            '@type' => 'MusicRecording',
            '@id' => 'http://musicbrainz.org/recording/aeb9b50a-e14a-4330-a2e6-7c8a311a9822',
            'name' => 'R',
            'duration' => 'PT05M00S'
        },
        'sameAs' => 'http://musicbrainz.org/work/a30a4245-a7ec-4979-8b1e-b549f2782239',
        '@context' => 'http://schema.org',
        'iswcCode' => ['T-000.000.001-0', 'T-000.000.002-0'],
        'inLanguage' => 'en'
    };
};

1;
