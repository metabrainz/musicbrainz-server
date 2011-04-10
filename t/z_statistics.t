use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test;

BEGIN { use_ok 'MusicBrainz::Server::Data::Statistics' }

my $c = MusicBrainz::Server::Test->create_test_context;

$c->model('Statistics')->recalculate_all;

done_testing;
