use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my $c = MusicBrainz::Server::Test->create_test_context;

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/actions/release_editor',
    verbose  => 1,
    startup  => sub {
        MusicBrainz::Server::Test->prepare_test_server();
        MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
        MusicBrainz::Server::Test->prepare_test_database($c, '+release_editor');
        MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
        MusicBrainz::Server::Test->prepare_raw_test_database($c);
    },
    teardown => sub { get('/logout') }
} );

$tests->run;
