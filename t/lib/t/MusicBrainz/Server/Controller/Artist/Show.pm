package t::MusicBrainz::Server::Controller::Artist::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok("/artist/745c079d-374e-4436-9448-da92dedef3ce", 'fetch artist index page');
html_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has artist name');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/Artist, Test/, 'content has artist sort name');
$mech->content_like(qr/Yet Another Test Artist/, 'disambiguation comments');
$mech->content_like(qr/2008-01-02/, 'has start date');
$mech->content_like(qr/2009-03-04/, 'has end date');
$mech->content_like(qr/Person/, 'has artist type');
$mech->content_like(qr/Male/, 'has gender');
$mech->content_like(qr/United Kingdom/, 'has area');
$mech->content_like(qr/Test annotation 1/, 'has annotation');
$mech->content_like(qr/More annotation/, 'displays the full annotation');

$mech->content_like(qr/3\.5<\/span>/s);
$mech->content_like(qr/see all ratings/);
$mech->content_like(qr/Last updated on 2009-07-09/);

# Header links
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/works', 'link to artist works');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'link to artist recordings');

# Basic test for release groups
$mech->content_like(qr/Test RG 1/, 'release group 1');
$mech->content_like(qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66}, 'release group 1');

$mech->content_like(qr/Test RG 2/, 'release group 2');
$mech->content_like(qr{/release-group/7348f3a0-454e-11de-8a39-0800200c9a66}, 'release group 2');

page_test_jsonld $mech => {
    '@type' => ['Person', 'MusicGroup'],
    'deathPlace' => {
        'name' => 'United Kingdom',
        '@type' => 'Country',
        '@id' => 'https://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed'
    },
    'birthDate' => '2009-03-04',
    'name' => 'Test Artist',
    'location' => {
        '@type' => 'Country',
        '@id' => 'https://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        'name' => 'United Kingdom'
    },
    'foundingDate' => '2009-03-04',
    'groupOrigin' => {
        'name' => 'United Kingdom',
        '@id' => 'https://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country'
    },
    'alternateName' => ['Seekrit Identity'],
    '@id' => 'https://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
    '@context' => 'http://schema.org',
    'birthPlace' => {
        '@id' => 'https://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom'
    },
    'album' => [
        {
            'albumProductionType' => 'http://schema.org/StudioAlbum',
            '@type' => 'MusicAlbum',
            '@id' => 'https://musicbrainz.org/release-group/ecc33260-454c-11de-8a39-0800200c9a66',
            'name' => 'Test RG 1',
            'creditedTo' => 'Test Artist',
            'byArtist' => {
                '@type' => ['Person', 'MusicGroup'],
                '@id' => 'https://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
                'name' => 'Test Artist'
            },
            'albumReleaseType' => 'http://schema.org/AlbumRelease'
        },
        {
            '@type' => 'MusicAlbum',
            'albumProductionType' => 'http://schema.org/StudioAlbum',
            '@id' => 'https://musicbrainz.org/release-group/7348f3a0-454e-11de-8a39-0800200c9a66',
            'name' => 'Test RG 2',
            'creditedTo' => 'Test Artist',
            'albumReleaseType' => 'http://schema.org/AlbumRelease',
            'byArtist' => {
                'name' => 'Test Artist',
                '@id' => 'https://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
                '@type' => ['Person', 'MusicGroup']
            }
        }
    ]
};

$mech->get('/artist/2775611341');
is($mech->status(), 404, 'too-large integer 404s');

};

test 'Embedded JSON-LD `member` property' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
    INSERT INTO artist (id, gid, name, sort_name)
        VALUES (1, 'dcb48a49-b17d-49b9-aee5-4f168d8004d9', 'Group', 'Group'),
               (2, '2a62773a-cdbf-44c6-a700-50f931504054', 'Person A', 'Person A'),
               (3, 'efac67ce-33ae-4949-8fc8-3d2aeafcbefb', 'Person B', 'Person B');

    INSERT INTO link (id, link_type, begin_date_year, end_date_year)
        VALUES (1, 103, 2001, 2002), (2, 103, 1999, 2002);

    INSERT INTO l_artist_artist (id, link, entity0, entity1, entity0_credit)
        VALUES (1, 1, 2, 1, 'A.'), (2, 2, 3, 1, 'B.');
EOSQL

    $mech->get_ok('/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9');
    page_test_jsonld $mech => {
        'name' => 'Group',
        'alternateName' => [],
        '@type' => 'MusicGroup',
        '@id' => 'https://musicbrainz.org/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9',
        'member' => [
            {
                'roleName' => [],
                'endDate' => '2002',
                'startDate' => '2001',
                '@type' => 'OrganizationRole',
                'member' => {
                    'name' => 'Person A',
                    '@type' => 'MusicGroup',
                    '@id' => 'https://musicbrainz.org/artist/2a62773a-cdbf-44c6-a700-50f931504054'
                }
            },
            {
                'member' => {
                    '@id' => 'https://musicbrainz.org/artist/efac67ce-33ae-4949-8fc8-3d2aeafcbefb',
                    'name' => 'Person B',
                    '@type' => 'MusicGroup'
                },
                'endDate' => '2002',
                '@type' => 'OrganizationRole',
                'startDate' => '1999',
                'roleName' => []
            }
        ],
        '@context' => 'http://schema.org'
    };
};

test 'Embedded JSON-LD `track` property (for artists with only recordings)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
    INSERT INTO artist (id, gid, name, sort_name)
        VALUES (1, 'dcb48a49-b17d-49b9-aee5-4f168d8004d9', 'Group', 'Group');

    INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'G.R.O.U.P.', 1);

    INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
        VALUES (1, 0, 1, 'G.R.O.U.P.', '');

    INSERT INTO recording (id, gid, name, artist_credit, length)
        VALUES (1, '7af3d92f-5ef4-4ed4-bbbb-728928984d9c', 'R1', 1, 300000),
               (2, '67f09ef6-0704-4841-935c-01c5b247574c', 'R2', 1, 250000);
EOSQL

    $mech->get_ok('/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9');
    page_test_jsonld $mech => {
        'name' => 'Group',
        'alternateName' => [],
        '@type' => 'MusicGroup',
        '@id' => 'https://musicbrainz.org/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9',
        'track' => [
            {
                'duration' => 'PT05M00S',
                '@id' => 'https://musicbrainz.org/recording/7af3d92f-5ef4-4ed4-bbbb-728928984d9c',
                'name' => 'R1',
                '@type' => 'MusicRecording'
            },
            {
                'duration' => 'PT04M10S',
                '@id' => 'https://musicbrainz.org/recording/67f09ef6-0704-4841-935c-01c5b247574c',
                'name' => 'R2',
                '@type' => 'MusicRecording'
            }
        ],
        '@context' => 'http://schema.org'
    };
};

1;
