package t::MusicBrainz::Server::Controller::WS::js::Release;
use Test::More;
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;
use Test::JSON import => [ 'is_valid_json' ];

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $c = $test->c;
    my $json = JSON::Any->new( utf8 => 1 );

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header ("Accept" => "application/json");

    my $url = '/ws/js/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=recordings+rels';

    $mech->get_ok($url, 'fetching');
    is_valid_json ($mech->content, "validating (is_valid_json)");

    my $data = $json->decode ($mech->content);

    is ($data->{mediums}->[0]->{position}, 1, "first disc has position 1");

    my $rels = $data->{mediums}->[0]->{tracks}->[0]->{recording}->{relationships};
    my $vocal_performance = $rels->{artist}->{vocal}->[0];

    is_deeply ($vocal_performance, {
        "direction" => "backward",
        "target" => {
            "comment" => "",
            "id" => "9496",
            "gid" => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            "sortname" => "BoA",
            "name" => "BoA"
        },
        "verbose_phrase" => "vocal",
        "ended" => 0,
        "edits_pending" => 0,
        "attributes" => {
            "guest" => 1,
        },
        "link_type" => 158,
        "id" => 6751,
    }, "BoA performed vocals");

    is_deeply ($data->{mediums}->[0]->{tracks}->[1]->{recording}->{relationships},
               {}, "No relationships on second track");
};

1;
