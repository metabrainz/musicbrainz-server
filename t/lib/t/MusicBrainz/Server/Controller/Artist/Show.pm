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
    'deathDate' => '2009-03-04',
    'deathPlace' => {
        'name' => 'United Kingdom',
        '@type' => 'Country',
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed'
    },
    'birthDate' => '2008-01-02',
    'name' => 'Test Artist',
    'sameAs' => 'http://musicbrainz.org/artist/089302a3-dda1-4bdf-b996-c2e941b5c41f',
    'location' => {
        '@type' => 'Country',
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        'name' => 'United Kingdom'
    },
    'alternateName' => ['Seekrit Identity'],
    '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
    '@context' => 'http://schema.org',
    'birthPlace' => {
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom'
    },
    'album' => [
        {
            'albumProductionType' => 'http://schema.org/StudioAlbum',
            '@type' => 'MusicAlbum',
            '@id' => 'http://musicbrainz.org/release-group/ecc33260-454c-11de-8a39-0800200c9a66',
            'name' => 'Test RG 1',
            'creditedTo' => 'Test Artist',
            'byArtist' => {
                '@type' => ['Person', 'MusicGroup'],
                '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
                'name' => 'Test Artist',
                'sameAs' => 'http://musicbrainz.org/artist/089302a3-dda1-4bdf-b996-c2e941b5c41f',
            },
            'albumReleaseType' => 'http://schema.org/AlbumRelease'
        },
        {
            '@type' => 'MusicAlbum',
            'albumProductionType' => 'http://schema.org/StudioAlbum',
            '@id' => 'http://musicbrainz.org/release-group/7348f3a0-454e-11de-8a39-0800200c9a66',
            'name' => 'Test RG 2',
            'creditedTo' => 'Test Artist',
            'albumReleaseType' => 'http://schema.org/AlbumRelease',
            'byArtist' => {
                'name' => 'Test Artist',
                '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
                '@type' => ['Person', 'MusicGroup'],
                'sameAs' => 'http://musicbrainz.org/artist/089302a3-dda1-4bdf-b996-c2e941b5c41f',
            }
        }
    ],
    'performsAs' => {
        '@id' => 'http://musicbrainz.org/artist/089302a3-dda1-4bdf-b996-c2e941b5c41f',
        '@type' => 'MusicGroup',
        'name' => 'Seekrit Identity',
    },
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
        VALUES (1, 103, 2001, 2002), (2, 103, 1999, 2002),
               (3, 103, 1999, 2002), (4, 103, 2005, NULL);

    INSERT INTO l_artist_artist (id, link, entity0, entity1, entity0_credit)
        VALUES (1, 1, 2, 1, 'A.'), (2, 2, 3, 1, 'B.'),
               (3, 3, 3, 1, 'B.'), (4, 4, 3, 1, 'B.');

    INSERT INTO link_attribute (link, attribute_type)
        VALUES (2, 229), (3, 125), (4, 229);
EOSQL

    $mech->get_ok('/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9');
    page_test_jsonld $mech => {
        'name' => 'Group',
        '@type' => 'MusicGroup',
        '@id' => 'http://musicbrainz.org/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9',
        'member' => [
            {
                'roleName' => [],
                'endDate' => '2002',
                'startDate' => '2001',
                '@type' => 'OrganizationRole',
                'member' => {
                    'name' => 'Person A',
                    '@type' => 'MusicGroup',
                    '@id' => 'http://musicbrainz.org/artist/2a62773a-cdbf-44c6-a700-50f931504054'
                }
            },
            {
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/efac67ce-33ae-4949-8fc8-3d2aeafcbefb',
                    'name' => 'Person B',
                    '@type' => 'MusicGroup'
                },
                'endDate' => '2002',
                '@type' => 'OrganizationRole',
                'startDate' => '1999',
                'roleName' => ['guitar','drums']
            },
            {
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/efac67ce-33ae-4949-8fc8-3d2aeafcbefb',
                    'name' => 'Person B',
                    '@type' => 'MusicGroup'
                },
                '@type' => 'OrganizationRole',
                'startDate' => '2005',
                'roleName' => 'guitar'
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
        '@type' => 'MusicGroup',
        '@id' => 'http://musicbrainz.org/artist/dcb48a49-b17d-49b9-aee5-4f168d8004d9',
        'track' => [
            {
                'duration' => 'PT05M00S',
                '@id' => 'http://musicbrainz.org/recording/7af3d92f-5ef4-4ed4-bbbb-728928984d9c',
                'name' => 'R1',
                '@type' => 'MusicRecording'
            },
            {
                'duration' => 'PT04M10S',
                '@id' => 'http://musicbrainz.org/recording/67f09ef6-0704-4841-935c-01c5b247574c',
                'name' => 'R2',
                '@type' => 'MusicRecording'
            }
        ],
        '@context' => 'http://schema.org'
    };
};

test 'Embedded JSON-LD sameAs & performsAs' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+snoop-lion-slash-dogg');

    $mech->get_ok('/artist/960db060-0ba8-4f6c-9770-49b81dc6e5ea');
    page_test_jsonld $mech => {
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/artist/960db060-0ba8-4f6c-9770-49b81dc6e5ea',
        '@type' => ['Person', 'MusicGroup'],
        'alternateName' => ['Calvin Broadus', 'Snoop Dogg'],
        'birthDate' => '1971-10-20',
        'birthPlace' => {
            '@id' => 'http://musicbrainz.org/area/e183ffae-1d35-4c78-b552-957535e40af1',
            '@type' => 'City',
            'name' => 'Long Beach'
        },
        'location' => {
            '@id' => 'http://musicbrainz.org/area/489ce91b-6658-3307-9877-795b68554c98',
            '@type' => 'Country',
            'name' => 'United States'
        },
        'name' => 'Snoop Lion',
        'performsAs' => {
            '@id' => 'http://musicbrainz.org/artist/f90e8b26-9e52-4669-a5c9-e28529c47894',
            '@type' => ['Person', 'MusicGroup'],
            'name' => 'Snoop Dogg',
        },
        'sameAs' => [
            'http://en.wikipedia.org/wiki/Snoop_Dogg',
            'http://musicbrainz.org/artist/965f5705-6eb1-49a1-b312-cd3d65bcc7c9',
            'http://musicbrainz.org/artist/f90e8b26-9e52-4669-a5c9-e28529c47894',
            'http://snooplion.com/',
            'http://www.discogs.com/artist/2859872',
            'http://www.wikidata.org/entity/Q6096',
            'https://www.allmusic.com/artist/mn0002979185',
        ]
    };
};

test 'Embedded JSON-LD dates & origins for people' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mozart');

    $mech->get_ok('/artist/b972f589-fb0e-474e-b64a-803b0364fa75');
    page_test_jsonld $mech => {
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/artist/b972f589-fb0e-474e-b64a-803b0364fa75',
        '@type' => ['Person', 'MusicGroup'],
        'birthDate' => '1756-01-27',
        'birthPlace' => {
            '@id' => 'http://musicbrainz.org/area/f0590317-8b42-4498-a2e4-34cc5562fcf8',
            '@type' => 'City',
            'name' => 'Salzburg',
        },
        'deathDate' => '1791-12-05',
        'deathPlace' => {
            '@id' => 'http://musicbrainz.org/area/afff1a94-a98b-4322-8874-3148139ab6da',
            '@type' => 'City',
            'name' => 'Wien',
        },
        'location' => {
            '@id' => 'http://musicbrainz.org/area/caac77d1-a5c8-3e6e-8e27-90b44dcc1446',
            '@type' => 'Country',
            'name' => 'Austria',
        },
        'name' => 'Wolfgang Amadeus Mozart',
        'sameAs' => [
            'http://en.wikipedia.org/wiki/Wolfgang_Amadeus_Mozart',
            'http://musicmoz.org/Composition/Composers/M/Mozart,_Wolfgang_Amadeus/',
            'http://rateyourmusic.com/artist/wolfgang_amadeus_mozart',
            'http://soundtrackcollector.com/composer/30/',
            'http://vgmdb.net/artist/174',
            'http://viaf.org/viaf/263782738',
            'http://viaf.org/viaf/32197206',
            'http://www.discogs.com/artist/95546',
            'http://www.wikidata.org/entity/Q254',
            'https://www.allmusic.com/artist/mn0000026350',
            'https://www.bbc.co.uk/music/artists/b972f589-fb0e-474e-b64a-803b0364fa75',
            'https://www.imdb.com/name/nm0003665/',
            'https://www.last.fm/music/Wolfgang+Amadeus+Mozart',
        ],
    };
};

test 'Embedded JSON-LD for groups' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+the-beatles');

    $mech->get_ok('/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d');
    page_test_jsonld $mech => {
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d',
        '@type' => 'MusicGroup',
        'dissolutionDate' => '1970-04-10',
        'foundingDate' => '1957-03',
        'groupOrigin' => {
            '@id' => 'http://musicbrainz.org/area/c249c30e-88ab-4b2f-a745-96a25bd7afee',
            '@type' => 'City',
            'name' => 'Liverpool',
        },
        'location' => {
            '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
            '@type' => 'Country',
            'name' => 'United Kingdom',
        },
        'member' => [
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1962-08-16',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/0d4ab0f9-bbda-4ab1-ae2c-f772ffcfbea9',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Pete Best'
                },
                'roleName' => 'drums',
                'startDate' => '1960-08-12',
            },
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1970-04-10',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/300c4c73-33ac-4255-9d57-4e32627f5e13',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Ringo Starr'
                },
                'roleName' => 'drums',
                'startDate' => '1962-08',
            },
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1970-04-10',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/42a8f507-8412-4611-854f-926571049fa0',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'George Harrison',
                },
                'roleName' => ['guitar', 'lead vocals'],
                'startDate' => '1958-04',
            },
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1962',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/49a51491-650e-44b3-8085-2f07ac2986dd',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Stuart Sutcliffe',
                },
                'roleName' => 'bass guitar',
                'startDate' => '1960-01',
            },
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1970-04-10',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/4d5447d7-c61c-4120-ba1b-d7f471d385b9',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'John Lennon',
                },
                'roleName' => ['guitar', 'lead vocals'],
            },
            {
                '@type' => 'OrganizationRole',
                'endDate' => '1970-04-10',
                'member' => {
                    '@id' => 'http://musicbrainz.org/artist/ba550d0e-adac-4864-b88b-407cab5e76af',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Paul McCartney',
                },
                'roleName' => ['bass guitar', 'lead vocals'],
                'startDate' => '1957-07',
            }
        ],
        'name' => 'The Beatles',
        'sameAs' => [
            'http://en.wikipedia.org/wiki/The_Beatles',
            'http://musicmoz.org/Bands_and_Artists/B/Beatles,_The/',
            'http://rateyourmusic.com/artist/the_beatles',
            'http://viaf.org/viaf/141205608',
            'http://www.45cat.com/artist/the-beatles',
            'http://www.discogs.com/artist/82730',
            'http://www.secondhandsongs.com/artist/41',
            'http://www.thebeatles.com/',
            'http://www.whosampled.com/The-Beatles/',
            'http://www.wikidata.org/entity/Q1299',
            'https://www.allmusic.com/artist/mn0000754032',
            'https://www.bbc.co.uk/music/artists/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d',
            'https://www.imdb.com/name/nm1397313/',
            'https://www.last.fm/music/The+Beatles',
        ],
    };
};

1;
