use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my ($res, $c) = ctx_request('/');

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/actions/recording',
    verbose  => 1,
    startup  => sub {
        MusicBrainz::Server::Test->prepare_test_server();
        MusicBrainz::Server::Test->prepare_test_database($c);
        MusicBrainz::Server::Test->prepare_raw_test_database($c);
    },
    teardown => sub { get('/logout') }
} );

$tests->run;
