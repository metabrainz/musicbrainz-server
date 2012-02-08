package t::MusicBrainz::Server::Data::Statistics;
use Test::Fatal;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Statistics::ByName;

use MusicBrainz::Server::Test;

with 't::Context';

test 'get_statistic works as expected' => sub {
    my $test = shift;

    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<'EOSQL');
INSERT INTO statistic (id, date_collected, name, value) VALUES (1, '2011-03-27', 'count.artist', 300000),(2, '2011-03-28', 'count.artist', 400000),(3, '2011-03-29', 'count.artist', 500000);
INSERT INTO statistic (id, date_collected, name, value) VALUES (4, '2011-03-27', 'count.release', 50000),(5, '2011-03-28', 'count.release', 50001),(6, '2011-03-29', 'count.release', 50002);
EOSQL

    my $tc1 = $c->model('Statistics::ByName')->get_statistic('count.artist');
    is($tc1->statistic_for('2011-03-27') => 300000);
    is($tc1->statistic_for('2011-03-28') => 400000);
    is($tc1->statistic_for('2011-03-29') => 500000);
    is($tc1->name => 'count.artist');

    my $tc2 = $c->model('Statistics::ByName')->get_statistic('count.release');
    is($tc2->statistic_for('2011-03-27') => 50000);
    is($tc2->statistic_for('2011-03-28') => 50001);
    is($tc2->statistic_for('2011-03-29') => 50002);
    is($tc2->name => 'count.release');
};

test 'test recalculate_all' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->begin;
    ok !exception { $c->model('Statistics')->recalculate_all };
    $c->sql->commit;
};

1;
