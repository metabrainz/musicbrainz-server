use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/lib";

use MusicBrainz::Server::Test;
use Catalyst::Test 'MusicBrainz::Server';
use Test::Aggregate::Nested;

my ($res, $c) = ctx_request('/');

my $tests = Test::Aggregate::Nested->new( {
    dirs     => 't/controllers',
    verbose  => 1,
} );

$tests->run;
