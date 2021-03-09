package t::MusicBrainz::Server::Controller::Release::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80', 'fetch release');
html_ok($mech->content);
$mech->title_like(qr/Aerial/, 'title has release name');
$mech->content_like(qr/Aerial/, 'content has release name');
$mech->content_like(qr/Kate Bush/, 'release artist credit');
$mech->content_like(qr/Test Artist/, 'artist credit on the last track');
$mech->content_contains('343 960 2', 'has catalog number');
$mech->content_contains('Warp Records', 'contains label name');
$mech->content_contains('/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
                        'has a link to the label');

page_test_jsonld $mech => {
    'catalogNumber' => '343 960 2',
    '@id' => 'http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
    'releaseOf' => {
        'name' => 'Aerial',
        'byArtist' => {
            '@id' => 'http://musicbrainz.org/artist/4b585938-f271-45e2-b19a-91c634b5e396',
            '@type' => ['Person', 'MusicGroup'],
            'name' => 'Kate Bush',
        },
        'creditedTo' => 'Kate Bush',
        'albumReleaseType' => 'http://schema.org/AlbumRelease',
        'albumProductionType' => 'http://schema.org/StudioAlbum',
        '@id' => 'http://musicbrainz.org/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5',
        '@type' => 'MusicAlbum'
    },
    'name' => 'Aerial',
    'musicReleaseFormat' => 'http://schema.org/CDFormat',
    'recordLabel' => {
        'name' => 'Warp Records',
        '@id' => 'http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
        '@type' => 'MusicLabel'
    },
    '@type' => 'MusicRelease',
    'gtin14' => '0094634396028',
    'creditedTo' => 'Kate Bush',
    'track' => [
        {
            'duration' => 'PT04M54S',
            'name' => 'King of the Mountain',
            '@id' => 'http://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
            'trackNumber' => '1.1',
            'contributor' => [
                {
                    '@type' => 'OrganizationRole',
                    'contributor' => {
                        '@id' => 'http://musicbrainz.org/artist/2fed031c-0e89-406e-b9f0-3d192637907a',
                        'name' => 'Test Alias',
                        '@type' => 'MusicGroup'
                    },
                    'roleName' => 'guitar'
                },
                {
                    'roleName' => 'guitar',
                    '@type' => 'OrganizationRole',
                    'contributor' => {
                        '@id' => 'http://musicbrainz.org/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                        'name' => 'Test Alias',
                        '@type' => 'MusicGroup'
                    }
                },
            ],
            '@type' => 'MusicRecording',
            'isrcCode' => 'DEE250800230'
        },
        {
            '@id' => 'http://musicbrainz.org/recording/659f405b-b4ee-4033-868a-0daa27784b89',
            'duration' => 'PT06M10S',
            'name' => "\x{3c0}",
            '@type' => 'MusicRecording',
            'trackNumber' => '1.2',
            'contributor' => [
                {
                    '@type' => 'OrganizationRole',
                    'contributor' => {
                        '@type' => 'MusicGroup',
                        '@id' => 'http://musicbrainz.org/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                        'name' => 'Test Alias'
                    },
                    'roleName' => 'plucked string instruments'
                }
            ]
        },
        {
            'trackNumber' => '1.3',
            '@type' => 'MusicRecording',
            'duration' => 'PT04M19S',
            'name' => 'Bertie',
            '@id' => 'http://musicbrainz.org/recording/ae674299-2824-4500-9516-653ac1bc6f80'
        },
        {
            'trackNumber' => '1.4',
            '@type' => 'MusicRecording',
            'duration' => 'PT05M59S',
            'name' => 'Mrs. Bartolozzi',
            '@id' => 'http://musicbrainz.org/recording/b1d58a57-a0f3-4db8-aa94-868cdc7bc3bb'
        },
        {
            'trackNumber' => '1.5',
            '@type' => 'MusicRecording',
            'duration' => 'PT05M33S',
            'name' => 'How to Be Invisible',
            '@id' => 'http://musicbrainz.org/recording/44f52946-0c98-47ba-ba60-964774db56f0'
        },
        {
            'duration' => 'PT04M56S',
            'name' => 'Joanni',
            '@id' => 'http://musicbrainz.org/recording/07614140-8bb8-4db9-9dcc-0917c3a8471b',
            'trackNumber' => '1.6',
            '@type' => 'MusicRecording'
        },
        {
            '@id' => 'http://musicbrainz.org/recording/1eb4f672-5ee3-454f-9a67-db85a4478fea',
            'duration' => 'PT06M12S',
            'name' => 'A Coral Room',
            '@type' => 'MusicRecording',
            'trackNumber' => '1.7'
        },
        {
            'name' => 'Prelude',
            'duration' => 'PT01M26S',
            '@id' => 'http://musicbrainz.org/recording/91028302-a466-4557-a19b-a26584564daa',
            'trackNumber' => '2.1',
            '@type' => 'MusicRecording'
        },
        {
            '@type' => 'MusicRecording',
            'trackNumber' => '2.2',
            '@id' => 'http://musicbrainz.org/recording/9560a5ac-d980-41fe-be7f-a6cb4a0cd91b',
            'name' => 'Prologue',
            'duration' => 'PT05M42S'
        },
        {
            'trackNumber' => '2.3',
            '@type' => 'MusicRecording',
            'duration' => 'PT04M50S',
            'name' => 'An Architect\'s Dream',
            '@id' => 'http://musicbrainz.org/recording/2ed42694-7b28-433e-9cf0-1e14a25babfe'
        },
        {
            'duration' => 'PT01M36S',
            'name' => 'The Painter\'s Link',
            '@id' => 'http://musicbrainz.org/recording/3bf4cbea-f963-4d75-bac5-351a29c60575',
            'trackNumber' => '2.4',
            '@type' => 'MusicRecording'
        },
        {
            '@id' => 'http://musicbrainz.org/recording/33137503-0ebf-4b6b-a7ce-cc71df5865df',
            'duration' => 'PT05M59S',
            'name' => 'Sunset',
            '@type' => 'MusicRecording',
            'trackNumber' => '2.5'
        },
        {
            '@id' => 'http://musicbrainz.org/recording/2c89d9f6-fd0e-4e79-a654-828fbcf4656d',
            'name' => 'Aerial Tal',
            'duration' => 'PT01M01S',
            '@type' => 'MusicRecording',
            'trackNumber' => '2.6'
        },
        {
            'duration' => 'PT05M01S',
            'name' => 'Somewhere in Between',
            '@id' => 'http://musicbrainz.org/recording/61b13b9d-e839-4ea9-8453-208eaafb75bf',
            'trackNumber' => '2.7',
            '@type' => 'MusicRecording'
        },
        {
            'trackNumber' => '2.8',
            '@type' => 'MusicRecording',
            'name' => 'Nocturn',
            'duration' => 'PT08M35S',
            '@id' => 'http://musicbrainz.org/recording/d328d709-609c-4b88-90be-95815f041524'
        },
        {
            '@type' => 'MusicRecording',
            'trackNumber' => '2.9',
            '@id' => 'http://musicbrainz.org/recording/1539ac10-5081-4469-b8f2-c5896132724e',
            'name' => 'Aerial',
            'duration' => 'PT07M53S'
        }
    ],
    '@context' => 'http://schema.org',
    'hasReleaseRegion' => [
        {
            'releaseCountry' => {
                '@type' => 'Country',
                '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                'name' => 'United Kingdom'
            },
            'releaseDate' => '2005-11-07',
            '@type' => 'CreativeWorkReleaseRegion'
        }
    ],
    'duration' => 'PT1H20M05S'
};

};

1;
