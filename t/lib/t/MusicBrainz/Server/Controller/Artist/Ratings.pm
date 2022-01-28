package t::MusicBrainz::Server::Controller::Artist::Ratings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

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
$mech->content_lacks('alice');

my $tx = test_xpath_html($mech->content);
$tx->is('count(//li//span[@class="inline-rating"])', 1, '1 rating is shown');
$tx->is('(//span[@class="current-rating"])[1]', 1, 'user rating is shown');
$tx->is('(//span[@class="current-rating"])[2]', 3.5, 'average rating is shown');

$mech->content_contains('1 private rating not listed');

};

1;
