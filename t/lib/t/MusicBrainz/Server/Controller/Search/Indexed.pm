package t::MusicBrainz::Server::Controller::Search::Indexed;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$mech->get_ok('/search?query=Love&type=artist', 'perform artist search');
html_ok($mech->content);
$mech->content_contains('784 results', 'has result count');
$mech->content_contains('L.O.V.E.', 'has correct search result');
$mech->content_contains('Love, Laura', 'has artist sortname');
$mech->content_contains('/artist/406bca37-056f-405e-a974-624864c9f641', 'has link to artist');

};

1;
