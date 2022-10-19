package t::MusicBrainz::Server::Controller::WS::2::JSON::Authenticated;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'lookup rating for user' => sub {

  my $test = shift;
  my $c = $test->c;

  MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
  MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
    INSERT INTO editor (id, name, password, ha1)
      VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478');
    INSERT INTO artist_rating_raw (artist, editor, rating)
      VALUES (265420, 1, 80)
    SQL

  ws_test_json 'ratings lookup for user rejected without authentication',
  '/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist' =>
      {
        help => 'For usage, please see: https://musicbrainz.org/development/mmd',
        error => 'You are not authorized to access this resource.',
      }, { response_code => 401 };

  ws_test_json 'ratings lookup for user succeeds after authentication',
  '/rating?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist' =>
      {
        'user-rating' => {
          value => 80,
        },
      }, { username => 'new_editor', password => 'password' };
};

test 'lookup tag for user' => sub {

  my $test = shift;
  my $c = $test->c;

  MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
  MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    SELECT setval('tag_id_seq', (SELECT MAX(id) FROM tag));
    INSERT INTO editor (id, name, password, ha1)
      VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478');
    INSERT INTO artist_tag (artist, count, last_updated, tag)
      VALUES (265420, 1, '2011-01-18 15:21:33.71184+00', 104);
    INSERT INTO artist_tag_raw (artist, editor, tag, is_upvote)
      VALUES (265420, 1, 104, 't')
  SQL

  ws_test_json 'tag lookup for user rejected without authentication',
  '/tag?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist' =>
      {
        help => 'For usage, please see: https://musicbrainz.org/development/mmd',
        error => 'You are not authorized to access this resource.',
      }, { response_code => 401 };

  ws_test_json 'tag lookup for user succeeds after authentication',
  '/tag?id=802673f0-9b88-4e8a-bb5c-dd01d68b086f&entity=artist' =>
      {
        'user-tags' => [
          {name => 'japanese'}
        ],
      }, { username => 'new_editor', password => 'password' };
};

1;
