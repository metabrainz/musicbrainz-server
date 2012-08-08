package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupArtist;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'errors' => sub {

    use Test::JSON import => [ 'is_valid_json', 'is_json' ];

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header ("Accept" => "application/json");
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=coffee');
    is ($mech->status, 400);

    is_valid_json ($mech->content);
    is_json ($mech->content, encode_json ({
        error => "coffee is not a valid inc parameter for the artist resource."
    }));

    $mech->get('/ws/2/artist/00000000-1111-2222-3333-444444444444');
    is ($mech->status, 404);
    is_valid_json ($mech->content);
    is_json ($mech->content, encode_json ({ error => "Not Found" }));
};

test 'basic artist lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a' => encode_json (
        {
            id => "472bc127-8861-45e8-bc9e-31e8dd32de7a",
            name => "Distance",
            "sort-name" => "Distance",
            type => "Person",
            disambiguation => "UK dubstep artist Greg Sanders",
            country => JSON::null,
        });
};

test 'basic artist lookup, inc=aliases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic artist lookup, inc=aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' => encode_json (
        {
            id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
            name => "BoA",
            "sort-name" => "BoA",
            country => JSON::null,
            disambiguation => JSON::null,
            type => "Person",
            "life-span" => { "begin" => "1986-11-05", "ended" => JSON::false },
            aliases => [
                { name => "Beat of Angel", "sort-name" => "Beat of Angel" },
                { name => "BoA Kwon", "sort-name" => "BoA Kwon" },
                { name => "Kwon BoA", "sort-name" => "Kwon BoA" },
                { name => "ボア", "sort-name" => "ボア" },
                { name => "보아", "sort-name" => "보아" },
                ],
        });

};

1;

