package t::MusicBrainz::Server::Controller::WS::2::Search;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use JSON::XS qw( decode_json );
use LWP::UserAgent::Mockable;
use Test::More;
use Test::Routine;

with 't::Mechanize';

test 'MBS-14455: WS/2 search is filtered on depth' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::MAX_SEARCH_RESULTS = sub { 500 };

    # limit 25 + offset 476 = depth 501 > 500
    $mech->get('/ws/2/artist?query=Duo&limit=25&offset=476');
    is($mech->status, HTTP_BAD_REQUEST, 'Deep WS/2 search gives a bad request error');
    $mech->content_contains('Must retrieve at most 500 search results, not 501.',
        'Deep WS/2 search gives an explanatory message.');

    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        my $response = HTTP::Response->new;
        $response->code(HTTP_OK);
        $response->content(<<~'EOF');
            {
              "offset": 0,
              "count": 1755,
              "artists": [
                {
                  "id": "3931e712-b43a-4271-b8e6-dd70a74c1d57",
                  "type": "Group",
                  "type-id": "e431f5f6-b5d2-343d-8b36-72607fffb74b",
                  "score": 87,
                  "name": "Duo",
                  "sort-name": "Duo",
                  "life-span": {
                    "ended": null
                  }
                }
              ]
            }
            EOF
        return $response;
    });

    # limit 25 + offset 475 = 500
    $mech->get_ok('/ws/2/artist?query=Duo&limit=25&offset=475',
                  'Maxed out WS/2 search still works');

    # limit 25 + offset 0 = 25 < 500
    $mech->get_ok('/ws/2/artist?query=Duo&limit=25&offset=0&fmt=json',
                  'First page of WS/2 search still works');
    is(decode_json($mech->content)->{count}, 1755,
        'First page of WS/2 search still counts uncapped total hits');

    LWP::UserAgent::Mockable->finished;
};

1;
