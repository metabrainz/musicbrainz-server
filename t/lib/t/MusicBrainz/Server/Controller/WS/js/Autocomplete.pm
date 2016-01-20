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
        '/artist?q=David&direct=true' =>
            [ {
                "annotation" => '',
                "area" => undef,
                "begin_date" => '',
                "comment" => '',
                "editsPending" => JSON::false,
                "end_date" => '',
                "ended" => JSON::false,
                "entityType" => "artist",
                "gid" => "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                "id" => 5,
                "name" => "David Bowie",
                "primaryAlias" => undef,
                "sortName" => "David Bowie",
                "typeID" => undef,
              }, { "current" => 1, "pages" => 1 } ];

    ws_test 'label autocomplete response',
        '/label?q=Warp&direct=true' =>
            [ {
                "annotation" => '',
                "area" => undef,
                "begin_date" => '',
                "comment" => 'Sheffield based electronica label',
                "editsPending" => JSON::false,
                "end_date" => '',
                "ended" => JSON::false,
                "entityType" => 'label',
                "gid" => '46f0f4cd-8aab-4b33-b698-f459faf64190',
                "id" => 2,
                "name" => 'Warp Records',
                "primaryAlias" => undef,
                "typeID" => 4,
              }, { "current" => 1, "pages" => 1 } ];

};

1;

