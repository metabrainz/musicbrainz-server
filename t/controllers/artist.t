use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my $c = MusicBrainz::Server::Test->create_test_context;

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/actions/artist',
    verbose  => 1,
    startup  => sub {
        MusicBrainz::Server::Test->prepare_test_server();
        MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');
        MusicBrainz::Server::Test->prepare_raw_test_database($c, '
TRUNCATE artist_tag_raw CASCADE;
TRUNCATE artist_rating_raw CASCADE;
INSERT INTO artist_tag_raw (artist, editor, tag) VALUES (3, 1, 1), (3, 2, 1);
INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (3, 1, 4);
');
    },
    teardown => sub { get('/logout') }
} );

$tests->run;
