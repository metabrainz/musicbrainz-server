package t::MusicBrainz::Server::Controller::CDStub::Browse;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

use DateTime;
use Hook::LexWrap;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

{
    # This test is dependent on the current time to generate the 'x years ago'
    # content. I'm using a lexically scoped wrapper around DateTime::now in
    # order to 'lock' the date to 2012/01/01. -- ocharles
    my $wrapper = wrap 'DateTime::now',
        post => sub {
            $_[-1] = DateTime->new( year => 2012, month => 01, day => 01 );
        };

    $mech->get_ok("/cdstub/browse", 'fetch top cdstubs page');
}


html_ok($mech->content);

$mech->title_like(qr/Top CD Stubs/, 'title is correct');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/, 'content has disc id');
$mech->content_like(qr/Added 12&nbsp;years ago/, 'content has added timestamp');
$mech->content_like(qr/last modified 11&nbsp;years ago/, 'content has last modified timestamp');

};

1;
