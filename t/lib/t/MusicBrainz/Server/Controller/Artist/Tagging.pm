package t::MusicBrainz::Server::Controller::Artist::Tagging;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

# Test tagging
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'tag.tags' => 'World Music, Jazz',
    }
);
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
html_ok($mech->content);

$mech->content_contains('world music');
$mech->content_contains('jazz');

};

1;
