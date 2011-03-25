package t::MusicBrainz::Server::Controller::Artist::Ratings;
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
MusicBrainz::Server::Test->prepare_raw_test_database($c, '
INSERT INTO artist_tag_raw (artist, editor, tag) VALUES (3, 1, 1), (3, 2, 1);
INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (3, 1, 20);
INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (3, 2, 100);
');

# Test ratings
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/ratings', 'get artist ratings');
html_ok($mech->content);
$mech->content_contains('new_editor');
{
    local $TODO = 'MBS-1440';
    $mech->content_contains('20 - ');
}
$mech->content_lacks('alice');
$mech->content_lacks('100');
$mech->content_contains('1 private rating not listed');

};

1;
