package t::MusicBrainz::Server::Controller::CDStub::Browse;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );
use Hook::LexWrap;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

{
    # This test is dependent on the current time to generate the 'x years ago'
    # content. I'm using a lexically scoped wrapper around Date::Calc::Today in
    # order to 'lock' the date to 2012/01/01. -- ocharles
    # See https://metacpan.org/pod/Hook::LexWrap#Lexically-scoped-wrappers
    my $wrapper = wrap 'Date::Calc::Today',
        post => sub {
            $_[-1] = [2012, 1, 1];
        };

    $mech->get_ok('/cdstub/browse', 'fetch top cdstubs page');

    $wrapper->DESTROY;
}


html_ok($mech->content);

$mech->title_like(qr/Top CD Stubs/, 'title is correct');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/, 'content has disc id');
$mech->content_like(qr/Added 12 years ago/, 'content has added timestamp');
$mech->content_like(qr/last modified 11 years ago/, 'content has last modified timestamp');

};

1;
