package t::MusicBrainz::Server::Controller::Artist::Relationships;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test relationships
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/relationships', 'get artist relationships');
html_ok($mech->content);
{
    local $TODO = 'The new appearences listing loses this detail';
    $mech->content_contains('guitar');
}
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce');

};

1;
