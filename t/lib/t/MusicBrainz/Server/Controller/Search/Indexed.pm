package t::MusicBrainz::Server::Controller::Search::Indexed;
use HTTP::Response;
use LWP::UserAgent::Mockable;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content(
<<EOF
{
  "offset": 0,
  "count": 784,
  "artists": [
    {
      "id": "e414a176-b978-492f-b6bc-9fd4c89df221",
      "type": "Group",
      "score": "97",
      "name": "L.O.V.E.",
      "sort-name": "L.O.V.E.",
      "life-span": {
        "ended": null
      },
      "aliases": [
        {
          "sort-name": "Eko Fresh & Valezka",
          "name": "Eko Fresh & Valezka",
          "locale": null,
          "type": null,
          "primary": null,
          "begin-date": null,
          "end-date": null
        },
        {
          "sort-name": "Eko & Valezka",
          "name": "Eko & Valezka",
          "locale": null,
          "type": null,
          "primary": null,
          "begin-date": null,
          "end-date": null
        }
      ],
      "tags": [
        {
          "count": 1,
          "name": "chinga"
        }
      ]
    },
    {
      "id": "53299fed-ec27-464f-94eb-5fda2db2902a",
      "type": "Person",
      "score": "65",
      "name": "Laura Love",
      "sort-name": "Love, Laura",
      "gender": "female",
      "country": "US",
      "area": {
        "id": "489ce91b-6658-3307-9877-795b68554c98",
        "name": "United States",
        "sort-name": "United States"
      },
      "life-span": {
        "begin": "1960",
        "ended": null
      },
      "tags": [
        {
          "count": 1,
          "name": "folk"
        }
      ]
    },
    {
      "id": "406bca37-056f-405e-a974-624864c9f641",
      "score": "62",
      "name": "Sunset Love",
      "sort-name": "Sunset Love",
      "life-span": {
        "ended": null
      }
    }
  ]
}
EOF
        );
        return $response;
    });

    $mech->get_ok('/search?query=Love&type=artist', 'perform artist search');
    html_ok($mech->content);
    $mech->content_contains('784 results', 'has result count');
    $mech->content_contains('L.O.V.E.', 'has correct search result');
    $mech->content_contains('Love, Laura', 'has artist sortname');
    $mech->content_contains('/artist/406bca37-056f-405e-a974-624864c9f641', 'has link to artist');

    LWP::UserAgent::Mockable->finished;
};

1;
