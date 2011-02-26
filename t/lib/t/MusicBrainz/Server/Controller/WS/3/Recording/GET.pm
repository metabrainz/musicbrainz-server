package t::MusicBrainz::Server::Controller::WS::3::Recording::GET;
use Test::More;
use Test::Routine;

use HTTP::Request::Common;
use MusicBrainz::Server::WebService::2;
use utf8;

with 't::Context';

test 'Get recording' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    my $ws = MusicBrainz::Server::WebService::2->new( c => $c );

    my $res = $ws->mock(GET '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7');
    my $recording = $res->{entity};

    is_deeply($res->{inline} => []);
    isa_ok($recording, 'MusicBrainz::Server::Entity::Recording');
    is($recording->gid, '162630d9-36d2-4a8d-ade1-1c77440b34e7');
    is($recording->name, 'サマーれげぇ!レインボー');
    is($recording->length, 296026);
};

1;
