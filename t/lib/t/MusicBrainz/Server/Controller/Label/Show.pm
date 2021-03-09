package t::MusicBrainz::Server::Controller::Label::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190", 'fetch label index');
html_ok($mech->content);
$mech->title_like(qr/Warp Records/, 'title has label name');
$mech->content_like(qr/Warp Records/, 'content has label name');
$mech->content_like(qr/Sheffield based electronica label/, 'disambiguation comments');
$mech->content_like(qr/1989-02-03/, 'has start date');
$mech->content_like(qr/2008-05-19/, 'has end date');
$mech->content_like(qr/United Kingdom/, 'has area');
$mech->content_like(qr/Production/, 'has label type');
$mech->content_like(qr/Test annotation 2/, 'has annotation');

# Check releases
$mech->content_like(qr/Arrival/, 'has release title');
$mech->content_like(qr/ABC-123/, 'has catalog of first release');
$mech->content_like(qr/ABC-123-X/, 'has catalog of second release');
$mech->content_like(qr/2009-05-08/, 'has release date');
$mech->content_like(qr{GB}, 'has country in release list');
$mech->content_like(qr{/release/f34c079d-374e-4436-9448-da92dedef3ce}, 'links to correct release');

page_test_jsonld $mech => {
    '@context' => 'http://schema.org',
    'releasePublished' => [
        {
            'name' => 'Aerial',
            '@id' => 'http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
            '@type' => 'MusicRelease'
        },
        {
            '@id' => 'http://musicbrainz.org/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b',
            '@type' => 'MusicRelease',
            'name' => 'Aerial'
        },
        {
            'name' => 'Arrival',
            '@id' => 'http://musicbrainz.org/release/f34c079d-374e-4436-9448-da92dedef3ce',
            '@type' => 'MusicRelease'
        }
    ],
    'artistSigned' => [
        {
            '@type' => 'Role',
            'artistSigned' => {
                '@id' => 'http://musicbrainz.org/artist/fa263cb3-205f-4a7f-91e1-94e3df52abe8',
                '@type' => ['Person', 'MusicGroup'],
                'name' => 'Jimmy Edgar',
            },
            'endDate' => '2008',
        },
        {
            '@type' => 'Role',
            'artistSigned' => {
                '@id' => 'http://musicbrainz.org/artist/e4787c4e-0b1a-48bd-b9a0-b0427391d293',
                '@type' => ['Person', 'MusicGroup'],
                'name' => 'patten',
            },
            'startDate' => '2013-11-05',
        },
    ],
    'foundingLocation' => {
        'name' => 'United Kingdom',
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country'
    },
    'name' => 'Warp Records',
    'foundingDate' => '1989-02-03',
    'dissolutionDate' => '2008-05-19',
    'sameAs' => 'http://musicbrainz.org/label/efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592',
    '@id' => 'http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
    '@type' => 'MusicLabel'
};

};

1;
