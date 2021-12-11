package t::MusicBrainz::Server::Controller::ReleaseGroup::Show;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );
use utf8;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce', 'fetch release group');
html_ok($mech->content);
$mech->title_like(qr/Arrival/, 'title has release group name');
$mech->content_like(qr/Arrival/, 'content has release group name');
$mech->content_like(qr/Album/, 'has release group type');
$mech->content_like(qr/ABBA/, 'has artist credit credit');
$mech->content_like(qr{/release-group/234c079d-374e-4436-9448-da92dedef3ce}, 'link back to release group');
$mech->content_like(qr{/artist/a45c079d-374e-4436-9448-da92dedef3cf}, 'link to artist');
$mech->content_like(qr/Test annotation 5/, 'has annotation');

page_test_jsonld $mech => {
    '@context' => 'http://schema.org',
    'albumProductionType' => 'http://schema.org/StudioAlbum',
    'byArtist' => {
        'name' => 'ABBA',
        '@id' => 'http://musicbrainz.org/artist/a45c079d-374e-4436-9448-da92dedef3cf',
        '@type' => 'MusicGroup'
    },
    'albumRelease' => {
        'name' => 'Arrival',
        '@type' => 'MusicRelease',
        '@id' => 'http://musicbrainz.org/release/f34c079d-374e-4436-9448-da92dedef3ce'
    },
    'albumReleaseType' => 'http://schema.org/AlbumRelease',
    'name' => 'Arrival',
    '@id' => 'http://musicbrainz.org/release-group/234c079d-374e-4436-9448-da92dedef3ce',
    'creditedTo' => 'ABBA',
    '@type' => 'MusicAlbum',
    'sameAs' => 'http://musicbrainz.org/release-group/77637e8c-be66-46ea-87b3-73addc722fc9'
};

$mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5', 'fetch Aerial release group');
html_ok($mech->content);
$mech->content_like(qr/Aerial/);
$mech->content_like(qr/2×CD/, 'correct medium format');
$mech->content_like(qr/7 \+ 9/, 'correct track count');

$mech->content_like(qr{/release/f205627f-b70a-409d-adbe-66289b614e80}, 'has uk release');
$mech->content_like(qr{United Kingdom}, 'has uk release');
$mech->content_like(qr{2005-11-07}, 'has uk release');
$mech->content_like(qr{Warp Records}, 'has uk label');
$mech->content_like(qr{343 960 2}, 'has uk label');
$mech->content_like(qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'has uk label');
$mech->content_like(qr{0827969777220}, 'has uk barcode');

$mech->content_like(qr{/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b}, 'has us release');
$mech->content_like(qr{United States}, 'has us release');
$mech->content_like(qr{2005-11-08}, 'has us release');
$mech->content_like(qr{Warp Records}, 'has uk label');
$mech->content_like(qr{82796 97772 2}, 'has uk label');
$mech->content_like(qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'has uk label');
$mech->content_like(qr{0094634396028}, 'has the us barcode');

page_test_jsonld $mech => {
    'albumRelease' => [
        {
            '@type' => 'MusicRelease',
            'name' => 'Aerial',
            '@id' => 'http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
            'duration' => 'PT1H20M05S',
        },
        {
            '@id' => 'http://musicbrainz.org/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b',
            'name' => 'Aerial',
            '@type' => 'MusicRelease',
            'duration' => 'PT1H20M05S',
        }
    ],
    'albumProductionType' => 'http://schema.org/StudioAlbum',
    'byArtist' => {
        '@type' => ['Person', 'MusicGroup'],
        '@id' => 'http://musicbrainz.org/artist/4b585938-f271-45e2-b19a-91c634b5e396',
        'name' => 'Kate Bush'
    },
    '@context' => 'http://schema.org',
    'name' => 'Aerial',
    '@id' => 'http://musicbrainz.org/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5',
    'albumReleaseType' => 'http://schema.org/AlbumRelease',
    'creditedTo' => 'Kate Bush',
    '@type' => 'MusicAlbum'
};

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce', 'fetch release group');
$mech->content_contains('/release_group/merge_queue?add-to-merge=1',
                        'has link to merge release groups');

$mech->content_contains('/release-group/234c079d-374e-4436-9448-da92dedef3ce/edits',
    'has a link to view editing history for the release group');

};

1;
