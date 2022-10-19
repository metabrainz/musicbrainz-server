package t::MusicBrainz::Server::Controller::TagLookup;
use utf8;
use strict;
use warnings;

use HTTP::Response;
use LWP::UserAgent::Mockable;
use Test::Routine;

use MusicBrainz::Server::Test qw( html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c);
    $test->$orig(@args);
};

with 't::Context', 't::Mechanize';

test 'Can perform tag lookups with artist and release titles' => sub {
    my $test = shift;

    # We want to make sure the nag will be shown on the main MB website
    no warnings qw( redefine );
    use DBDefs;
    local *DBDefs::WEB_SERVER = sub { 'musicbrainz.org' };

    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content(
<<EOF
{
  "created": "2015-01-12T22:18:04.27Z",
  "count": 20859,
  "offset": 0,
  "releases": [
    {
      "id": "10e8bb74-4466-4f3e-80c4-73fdc907d196",
      "score": "100",
      "count": 1,
      "title": "LOVE",
      "status": "Official",
      "text-representation": {
        "language": "jpn",
        "script": "Jpan"
      },
      "artist-credit": [
        {
          "artist": {
            "id": "f8d6e5df-069e-4b8d-9a13-cc7e0a558dd1",
            "name": "\u4e2d\u5cf6\u7f8e\u5609",
            "sort-name": "Nakashima, Mika",
            "aliases": [
              {
                "sort-name": "\u306a\u304b\u3057\u307e \u307f\u304b",
                "name": "\u306a\u304b\u3057\u307e \u307f\u304b",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "\u306a\u304b\u3057\u307e\u307f\u304b",
                "name": "\u306a\u304b\u3057\u307e\u307f\u304b",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "Nakashima, Mika",
                "name": "Mika Nakashima",
                "locale": "en",
                "type": "Artist name",
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "Nakachima Mika",
                "name": "Nakachima Mika",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "Nakashima Mika",
                "name": "Nakashima Mika",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "NANA starring Nakashima Mika",
                "name": "NANA starring Nakashima Mika",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "\u4e2d\u5c9b\u7f8e\u5609",
                "name": "\u4e2d\u5c9b\u7f8e\u5609",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              },
              {
                "sort-name": "\u4e2d\u5cf6 \u7f8e\u5609",
                "name": "\u4e2d\u5cf6 \u7f8e\u5609",
                "locale": null,
                "type": null,
                "primary": null,
                "begin-date": null,
                "end-date": null
              }
            ]
          }
        }
      ],
      "release-group": {
        "id": "5ae986f7-78bc-386e-91f3-e315d7774954",
        "primary-type": "Album"
      },
      "date": "2003-11-06",
      "country": "JP",
      "release-events": [
        {
          "date": "2003-11-06",
          "area": {
            "id": "2db42837-c832-3c27-b4a3-08198f75693c",
            "name": "Japan",
            "sort-name": "Japan",
            "iso-3166-1-codes": [
              "JP"
            ]
          }
        }
      ],
      "barcode": "4547403002546",
      "asin": "B0000CD7LO",
      "label-info": [
        {
          "catalog-number": "AICL-1494",
          "label": {
            "id": "d766cf2e-d31e-4fad-9511-b27013594d7e",
            "name": "Sony Music Associated Records"
          }
        }
      ],
      "track-count": 13,
      "media": [
        {
          "format": "CD",
          "disc-count": 1,
          "track-count": 13
        }
      ]
    }
  ]
}
EOF
        );
        return $response;
    });

    $test->mech->get_ok('/taglookup?artist=中島+美嘉!&release=love', 'performed tag lookup');
    html_ok($test->mech->content);
    $test->mech->content_contains('中島', 'has correct artist result');
    $test->mech->content_contains('LOVE', 'has correct release result');
    $test->mech->content_contains('Make a donation now', 'has nag screen');

    LWP::UserAgent::Mockable->finished;
};

1;
