use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my $c = MusicBrainz::Server::Test->create_test_context;

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/controllers',
    verbose  => 1,
} );

$tests->run;
