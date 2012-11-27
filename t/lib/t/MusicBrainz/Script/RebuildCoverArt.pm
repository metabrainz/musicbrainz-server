package t::MusicBrainz::Script::RebuildCoverArt;
use Test::Routine;
use Test::More;
use Test::Fatal;

use MusicBrainz::Script::RebuildCoverArt;

with 't::Context';

test 'all' => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+coverart');

my $script = MusicBrainz::Script::RebuildCoverArt->new( c => $c );
ok !exception { $script->run };

my $sql = $c->sql;
is($sql->select_single_value('SELECT 1 FROM release_coverart WHERE id = 1 AND cover_art_url IS NOT NULL'), 1);


SKIP: {
    skip 'Testing Amazon CoverArt requires the AWS_PUBLIC and AWS_PRIVATE configuration variables to be set', 1
        unless DBDefs->AWS_PUBLIC() && DBDefs->AWS_PRIVATE();

    is($sql->select_single_value('SELECT 1 FROM release_coverart WHERE id = 2 AND cover_art_url IS NOT NULL'), 1);
};

};

1;
