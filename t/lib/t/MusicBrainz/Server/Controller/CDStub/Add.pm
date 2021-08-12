package t::MusicBrainz::Server::Controller::CDStub::Add;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

use MusicBrainz::Server::Entity::CDTOC;

with 't::Mechanize', 't::Context';

test 'Trying to add a CD stub where a real disc ID exists redirects' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdtoc');

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc(
        '1 7 171327 150 22179 49905 69318 96240 121186 143398'
    );
    my $discid = $cdtoc->discid;

    $mech->get_ok(
        '/cdstub/add?toc=' . $cdtoc->toc,
        'fetch top cdstubs page'
    );

    like($mech->uri, qr{/cdtoc/$discid}, 'on /cdtoc page');
};

1;
