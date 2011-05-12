use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'MusicBrainz::Script::RebuildCoverArt' }

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context;
MusicBrainz::Server::Test->prepare_test_database($c, '+inserttestdata-with-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+coverart-truncate');
MusicBrainz::Server::Test->prepare_test_database($c, '+coverart');

my $script = MusicBrainz::Script::RebuildCoverArt->new( c => $c );
lives_ok { $script->run };

my $sql = Sql->new($c->dbh);
is($sql->select_single_value('SELECT 1 FROM release_coverart WHERE id = 1 AND cover_art_url IS NOT NULL'), 1);
is($sql->select_single_value('SELECT 1 FROM release_coverart WHERE id = 2 AND cover_art_url IS NOT NULL'), 1);

done_testing;
