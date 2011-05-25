use strict;
use warnings;
use Test::More;
use Test::Fatal;

use MusicBrainz::Server::Test;

BEGIN { use_ok 'MusicBrainz::Server::Data::Statistics::ByDate' }

my $c = MusicBrainz::Server::Test->create_test_context;

$c->sql->begin;
$c->raw_sql->begin;
ok !exception { $c->model('Statistics::ByDate')->recalculate_all };
$c->sql->commit;
$c->raw_sql->commit;

done_testing;
