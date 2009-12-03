use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my ($res, $c) = ctx_request('/');

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/actions/user',
    verbose  => 1,
    setup    => sub {
        # Use setup here as tests currently modify the user
        MusicBrainz::Server::Test->prepare_test_server();
        MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
        MusicBrainz::Server::Test->prepare_raw_test_database($c);
    },
    teardown => sub { get('/logout') }
} );

$tests->run;
