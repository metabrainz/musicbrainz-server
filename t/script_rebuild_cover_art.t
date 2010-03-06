use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'MusicBrainz::Script::RebuildCoverArt' }

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context;
MusicBrainz::Server::Test->prepare_test_database($c, '+coverart');

my $script = MusicBrainz::Script::RebuildCoverArt->new( c => $c );
lives_ok { $script->run };

done_testing;
