package t::MusicBrainz::Server::Controller::WS::js::Autocomplete;
use Test::Routine;

with 't::Mechanize', 't::Context';

use JSON;
use MusicBrainz::Server::Test ws_test => {
    version => 'js'
};

test all => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    ws_test 'artist autocomplete response',
        '/artist?q=David&direct=true' => encode_json (
            [ {
                "comment" => '',
                "id" => 5,
                "gid" => "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                "name" => "David Bowie",
                "sortname" => "David Bowie",
              }, { "current" => 1, "pages" => 1 } ]);

    ws_test 'label autocomplete response',
        '/label?q=Warp&direct=true' => encode_json (
            [ {
                "comment" => "Sheffield based electronica label",
                "id" => 2,
                "gid" => "46f0f4cd-8aab-4b33-b698-f459faf64190",
                "name" => "Warp Records",
                "sortname" => "Warp Records",
              }, { "current" => 1, "pages" => 1 } ]);

};

1;

