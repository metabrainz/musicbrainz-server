package t::MusicBrainz::Server::Data::Search;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use HTTP::Response;
use LWP::UserAgent::Mockable;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Data::Search;

with 't::Context';

our $artist_json = <<EOF;
{
  "created": "2015-01-12T22:00:45.156Z",
  "count": 4437,
  "offset": 0,
  "artists":[
    {
      "id": "34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47",
      "type": "Group",
      "score": "98",
      "name": "Love",
      "sort-name": "Love",
      "country": "US",
      "area": {
        "id": "489ce91b-6658-3307-9877-795b68554c98",
        "name": "United States",
        "sort-name": "United States"
      },
      "disambiguation": "folk-rock/psychedelic band",
      "life-span": {
        "ended": null
      },
      "aliases": [
        {
          "sort-name": "Love (With Arthur Lee)",
          "name": "Love (With Arthur Lee)",
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
          "name": "psychedelic rock"
        },
        {
          "count": 1,
          "name": "psychedelic pop"
        },
        {
          "count": 1,
          "name": "classic pop and rock"
        }
      ]
    }
  ]
}
EOF

test 'Searching artists with area lookup' => sub {
    my $test = shift;
    my $c = $test->c;

    my $data = load_data('artist', $c, $artist_json);
    my $artist = $data->{results}[0]{entity};
    is($artist->area->name, 'United States');
};

test all => sub {
    my $test = shift;

    # artist search
    my $data = load_data('artist', $test->c, $artist_json);

    is(@{ $data->{results} }, 1);

    my $artist = $data->{results}->[0]->{entity};

    ok(defined $artist->name);
    is($artist->name, 'Love');
    is($artist->sort_name, 'Love');
    is($artist->comment, 'folk-rock/psychedelic band');
    is($artist->gid, '34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47');
    is($artist->type->name, 'Group');

    # release_group search
    $data = load_data('release_group', $test->c,
<<EOF
{
  "created": "2015-01-12T22:04:54.11Z",
  "count": 20811,
  "offset": 0,
  "release-groups": [
    {
      "id": "3d0ee264-579f-3615-8888-1c53c7df9786",
      "score": "100",
      "count": 3,
      "title": "Love",
      "primary-type": "Album",
      "artist-credit": [
        {
          "artist": {
            "id": "34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47",
            "name": "Love",
            "sort-name": "Love",
            "disambiguation": "folk-rock/psychedelic band",
            "aliases": [
              {
                "sort-name": "Love (With Arthur Lee)",
                "name": "Love (With Arthur Lee)",
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
      "releases": [
        {
          "id": "14bdb3b0-5885-3503-94be-fa2f02417df6",
          "title": "Love",
          "status": "Official"
        },
        {
          "id": "8f90de5d-7c77-4558-a2a2-c38c09cdd9c6",
          "title": "Love",
          "status": "Official"
        },
        {
          "id": "da103965-b7e7-4618-98f5-3b9599ecc388",
          "title": "Love",
          "status": "Official"
        }
      ]
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);

    my $release_group = $data->{results}->[0]->{entity};

    ok(defined $release_group->name);
    is($release_group->name, 'Love');
    is($release_group->gid, '3d0ee264-579f-3615-8888-1c53c7df9786');
    is($release_group->primary_type->name, 'Album');
    is($release_group->artist_credit->names->[0]->artist->name, 'Love');
    is($release_group->artist_credit->names->[0]->artist->sort_name, 'Love');
    is($release_group->artist_credit->names->[0]->artist->gid, '34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47');
    is($release_group->artist_credit->names->[0]->artist->comment, 'folk-rock/psychedelic band');

    # release search
    $data = load_data('release', $test->c,
<<EOF
{
  "created": "2015-01-12T22:18:04.27Z",
  "count": 27554,
  "offset": 0,
  "releases": [
    {
      "id": "da103965-b7e7-4618-98f5-3b9599ecc388",
      "score": "100",
      "count": 1,
      "title": "Love",
      "status": "Official",
      "text-representation": {
        "language": "eng",
        "script": "Latn"
      },
      "artist-credit": [
        {
          "artist": {
            "id": "34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47",
            "name": "Love",
            "sort-name": "Love",
            "disambiguation": "folk-rock/psychedelic band",
            "aliases": [
              {
                "sort-name": "Love (With Arthur Lee)",
                "name": "Love (With Arthur Lee)",
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
        "id": "3d0ee264-579f-3615-8888-1c53c7df9786",
        "primary-type": "Album"
      },
      "date": "1966-04",
      "country": "US",
      "release-events": [
        {
          "date": "1966-04",
          "area": {
            "id": "489ce91b-6658-3307-9877-795b68554c98",
            "name": "United States",
            "sort-name": "United States",
            "iso-3166-1-codes": [
              "US"
            ]
          }
        }
      ],
      "label-info": [
        {
          "catalog-number": "EKL 4001",
          "label": {
            "id": "873f9f75-af68-4872-98e2-431058e4c9a9",
            "name": "Elektra"
          }
        }
      ],
      "track-count": 14,
      "media": [
        {
          "format": "12\\\\\\" Vinyl",
          "disc-count": 0,
          "track-count": 14
        }
      ]
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);

    my $release = $data->{results}->[0]->{entity};

    is($release->name, 'Love');
    is($release->gid, 'da103965-b7e7-4618-98f5-3b9599ecc388');
    is($release->script->iso_code, 'Latn');
    is($release->language->iso_code_3, 'eng');
    is($release->artist_credit->names->[0]->artist->name, 'Love');
    is($release->artist_credit->names->[0]->artist->sort_name, 'Love');
    is($release->artist_credit->names->[0]->artist->gid, '34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47');
    is($release->mediums->[0]->track_count, 14);

    # recording search
    $data = load_data('recording', $test->c,
<<EOF
{
  "created": "2015-01-12T06:01:11.335Z",
  "count": 510843,
  "offset": 0,
  "recordings": [
    {
      "id": "7f76fc25-5576-4b7d-8401-87660bd3f5f1",
      "score": "100",
      "title": "L.O.V.E.",
      "length": 231666,
      "video": null,
      "artist-credit": [
        {
          "artist": {
            "id": "e414a176-b978-492f-b6bc-9fd4c89df221",
            "name": "L.O.V.E.",
            "sort-name": "L.O.V.E.",
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
            ]
          }
        }
      ],
      "releases": [
        {
          "id": "56f23fac-24e9-4883-b093-b4c94a001a96",
          "title": "Bravo Black Hits, Volume 10",
          "status": "Official",
          "artist-credit": [
            {
              "artist": {
                "id": "89ad4ac3-39f7-470e-963a-56509c546377",
                "name": "Various Artists",
                "sort-name": "Various Artists"
              }
            }
          ],
          "release-group": {
            "id": "29792782-17e6-31db-8256-ab7154bc89b4",
            "primary-type": "Album",
            "secondary-types": [
              "Compilation"
            ]
          },
          "date": "2004-04-19",
          "country": "DE",
          "release-events": [
            {
              "date": "2004-04-19",
              "area": {
                "id": "85752fda-13c4-31a3-bee5-0e5cb1f51dad",
                "name": "Germany",
                "sort-name": "Germany",
                "iso-3166-1-codes": [
                  "DE"
                ]
              }
            }
          ],
          "track-count": 38,
          "media": [
            {
              "position": 1,
              "format": "CD",
              "track": [
                {
                  "id": "27648e75-95e3-3207-b824-78da5a8bd641",
                  "number": "17",
                  "title": "L.O.V.E.",
                  "length": 234533
                }
              ],
              "track-count": 19,
              "track-offset": 16
            }
          ]
        },
        {
          "id": "a72505b6-f3d9-4d95-b80c-e1ed67286f9f",
          "title": "Bravo Hits 45",
          "status": "Official",
          "artist-credit": [
            {
              "artist": {
                "id": "89ad4ac3-39f7-470e-963a-56509c546377",
                "name": "Various Artists",
                "sort-name": "Various Artists"
              }
            }
          ],
          "release-group": {
            "id": "a84861c0-72b3-37b2-bbbc-07c03269abab",
            "primary-type": "Album",
            "secondary-types": [
              "Compilation"
            ]
          },
          "date": "2004-05-21",
          "country": "DE",
          "release-events": [
            {
              "date": "2004-05-21",
              "area": {
                "id": "85752fda-13c4-31a3-bee5-0e5cb1f51dad",
                "name": "Germany",
                "sort-name": "Germany",
                "iso-3166-1-codes": [
                  "DE"
                ]
              }
            }
          ],
          "track-count": 40,
          "media": [
            {
              "position": 1,
              "format": "CD",
              "track": [
                {
                  "id": "89fdd766-b3d7-3e98-abc3-4f708abc2ca3",
                  "number": "9",
                  "title": "L.O.V.E.",
                  "length": 231666
                }
              ],
              "track-count": 20,
              "track-offset": 8
            }
          ]
        },
        {
          "id": "bfaa7806-0628-4e81-a553-b88e379b6c3b",
          "title": "Bravo Hits 45",
          "status": "Official",
          "artist-credit": [
            {
              "artist": {
                "id": "89ad4ac3-39f7-470e-963a-56509c546377",
                "name": "Various Artists",
                "sort-name": "Various Artists"
              }
            }
          ],
          "release-group": {
            "id": "a84861c0-72b3-37b2-bbbc-07c03269abab",
            "primary-type": "Album",
            "secondary-types": [
              "Compilation"
            ]
          },
          "track-count": 40,
          "media": [
            {
              "position": 1,
              "format": "CD",
              "track": [
                {
                  "id": "7f8349dc-ee12-3c65-8459-a0775d061c1b",
                  "number": "9",
                  "title": "L.O.V.E.",
                  "length": 231666
                }
              ],
              "track-count": 20,
              "track-offset": 8
            }
          ]
        }
      ]
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);

    my $recording = $data->{results}->[0]->{entity};
    my $extra = $data->{results}->[0]->{extra};

    is($recording->name, 'L.O.V.E.');
    is($recording->gid, '7f76fc25-5576-4b7d-8401-87660bd3f5f1');
    is($recording->length, 231666);
    is($recording->artist_credit->names->[0]->artist->name, 'L.O.V.E.');
    is($recording->artist_credit->names->[0]->artist->sort_name, 'L.O.V.E.');
    is($recording->artist_credit->names->[0]->artist->gid, 'e414a176-b978-492f-b6bc-9fd4c89df221');

    ok(defined $extra);
    is(@$extra, 3);
    is($extra->[0]->{release}->release_group->primary_type->name, 'Album');
    is($extra->[0]->{release}->name, 'Bravo Black Hits, Volume 10');
    is($extra->[0]->{release}->gid, '56f23fac-24e9-4883-b093-b4c94a001a96');
    is($extra->[0]->{track_position}, 17);
    is($extra->[0]->{medium_track_count}, 19);

    # label search
    $data = load_data('label', $test->c,
<<EOF
{
  "created": "2015-01-12T22:34:44.164Z",
  "count": 196,
  "offset": 0,
  "labels": [
    {
      "id": "e24ca2f9-416e-42bd-a223-bed20fa409d0",
      "type": "Production",
      "score": "100",
      "name": "Love Records",
      "sort-name": "Love Records",
      "disambiguation": "Finnish label",
      "country": "FI",
      "area": {
        "id": "6a264f94-6ff1-30b1-9a81-41f7bfabd616",
        "name": "Finland",
        "sort-name": "Finland"
      },
      "life-span": {
        "begin": "1966",
        "end": "1979",
        "ended": true
      },
      "aliases": [
        {
          "sort-name": "Love",
          "name": "Love",
          "locale": null,
          "type": null,
          "primary": null,
          "begin-date": null,
          "end-date": null
        }
      ]
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);
    my $label = $data->{results}->[0]->{entity};

    is($label->name, 'Love Records');
    is($label->comment, 'Finnish label');
    is($label->gid, 'e24ca2f9-416e-42bd-a223-bed20fa409d0');
    is($label->type->name, 'Production');

    # annotation search
    $data = load_data('annotation', $test->c,
<<EOF
{
  "created": "2015-01-12T22:41:59.973Z",
  "count": 4898,
  "offset": 0,
  "annotations": [
    {
      "type": "release",
      "score": "100",
      "entity": "cbedf2bb-fcfe-44dd-bfe0-beb12df21ae4",
      "name": "Love",
      "text": "Recorded at the Royal Albert Hall, January 24, 1990.\\nThe date on the CD is incorrectly listed as January 16, 1991.\\nSource: http://www.geetarz.org/reviews/clapton/love.htm"
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);

    my $annotation = $data->{results}->[0]->{entity};
    is($annotation->parent->name, 'Love');
    is($annotation->parent->gid, 'cbedf2bb-fcfe-44dd-bfe0-beb12df21ae4');
    is($annotation->text, "Recorded at the Royal Albert Hall, January 24, 1990.\nThe date on the CD is incorrectly listed as January 16, 1991.\nSource: http://www.geetarz.org/reviews/clapton/love.htm");

    # cdstub search
    $data = load_data('cdstub', $test->c,
<<EOF
{
  "created": "2015-01-12T22:35:11.534Z",
  "count": 5950,
  "offset": 0,
  "cdstubs": [
    {
      "id": "BsPKnQO8AqLGwGV4_8RuU9cKYN8-",
      "score": "100",
      "count": 17,
      "title": "Out Here",
      "artist": "Love",
      "barcode": "1774209312"
    }
  ]
}
EOF
    );

    is(@{ $data->{results} }, 1);
    my $cdstub = $data->{results}->[0]->{entity};

    is($cdstub->artist, 'Love');
    is($cdstub->discid, 'BsPKnQO8AqLGwGV4_8RuU9cKYN8-');
    is($cdstub->title, 'Out Here');
    is($cdstub->barcode, '1774209312');
    is($cdstub->track_count, '17');

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

    my @direct = MusicBrainz::Server::Data::Search->new(c => $test->c)->search(
        'release', 'Blonde on blonde', 2, 0, 0);

    my $results = $direct[0];

    is($direct[1], 2, 'two search results');
    is($results->[0]->entity->name, 'Blonde on Blonde', 'exact phrase ranked first');
    is($results->[1]->entity->name, 'Blues on Blonde on Blonde', 'longer phrase ranked second');
};

sub load_data {
    my ($type, $c, $content) = @_;

    ok(type_to_model($type), "$type has a model");

    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content($content);
        return $response;
    });

    my $data = MusicBrainz::Server::Data::Search->new(c => $c)->external_search(
        $type,
        'love',  # "Love" always has tons of hits
        1,       # items per page
        1,       # paging offset
        0,       # advanced search
    );

    LWP::UserAgent::Mockable->finished;
    return $data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
