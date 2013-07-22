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
INSERT INTO statistics.statistic (id, date_collected, name, value) VALUES (1, '2011-03-27', 'count.artist', 300000),(2, '2011-03-28', 'count.artist', 400000),(3, '2011-03-29', 'count.artist', 500000);
INSERT INTO statistics.statistic (id, date_collected, name, value) VALUES (4, '2011-03-27', 'count.release', 50000),(5, '2011-03-28', 'count.release', 50001),(6, '2011-03-29', 'count.release', 50002);
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

test 'top_recently_active_editors' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
  SELECT x, 'Editor ' || x, '{CLEARTEXT}pass', md5('Editor ' || x || ':musicbrainz:pass'), '', now() FROM generate_series(1, 4) s(x);

INSERT INTO edit (id, data, status, type, open_time, expire_time, editor)
VALUES
-- Edits that should count
  (1, '{}', 1, 1, now(), now(), 1),
  (2, '{}', 2, 1, now(), now(), 1),
  (3, '{}', 1, 1, now(), now(), 2),

-- Failed edits dont count
  (4, '{}', 4, 1, now(), now(), 3),

-- Old edits dont count
  (5, '{}', 2, 1, '1970-01-01', now(), 4);
EOSQL

    ok !exception { $test->c->model('Statistics')->recalculate_all };
    my $stats = $test->c->model('Statistics::ByDate')->get_latest_statistics();

    ok(defined $stats);
    is($stats->statistic('editor.top_recently_active.rank.1'), 1);
    is($stats->statistic('editor.top_recently_active.rank.2'), 2);
    is($stats->statistic('editor.top_recently_active.rank.3'), undef);

    is($stats->statistic('count.edit.top_recently_active.rank.1'), 2);
    is($stats->statistic('count.edit.top_recently_active.rank.2'), 1);
};

test 'top_editors' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
  SELECT x, 'Editor ' || x, '{CLEARTEXT}pass', md5('Editor ' || x || ':musicbrainz:pass'), '', now() FROM generate_series(1, 4) s(x);

INSERT INTO edit (id, data, status, type, open_time, expire_time, editor)
VALUES
-- Edits that should count
  (1, '{}', 1, 1, now(), now(), 1),
  (2, '{}', 2, 1, now(), now(), 1),
  (3, '{}', 1, 1, now() - '5 day'::interval, now(), 2),

-- Failed edits dont count
  (4, '{}', 4, 1, now(), now(), 3),

-- Old edits do count
  (5, '{}', 2, 1, '1970-01-01', now(), 4);

UPDATE editor SET edits_accepted = 2 WHERE id = 1;
UPDATE editor SET edits_accepted = 1 WHERE id = 2;
UPDATE editor SET edits_accepted = 1 WHERE id = 4;
EOSQL

    ok !exception { $test->c->model('Statistics')->recalculate_all };
    my $stats = $test->c->model('Statistics::ByDate')->get_latest_statistics();

    ok(defined $stats);
    is($stats->statistic('editor.top_active.rank.1'), 1);
    is($stats->statistic('editor.top_active.rank.2'), 2);
    is($stats->statistic('editor.top_active.rank.3'), 4);

    is($stats->statistic('count.edit.top_active.rank.1'), 2);
    is($stats->statistic('count.edit.top_active.rank.2'), 1);
    is($stats->statistic('count.edit.top_active.rank.3'), 1);
};

test 'top_recently_active_voters' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
  SELECT x, 'Editor ' || x, '{CLEARTEXT}pass', md5('Editor ' || x || ':musicbrainz:pass'), '', now() FROM generate_series(1, 5) s(x);
INSERT INTO edit (id, data, status, type, open_time, expire_time, editor)
  SELECT x, '{}', 2, 1, now(), now(), 1 FROM generate_series(1, 4) s(x);

INSERT INTO vote (id, edit, vote, vote_time, editor, superseded)
VALUES
-- Votes that should count
  (1, 1, 0, now(), 1, FALSE),
  (2, 2, 1, now(), 1, FALSE),
  (3, 1, 2, now() - '5 day'::interval, 2, FALSE),

-- Abstains don't count
  (4, 1, -1, now(), 3, FALSE),

-- Old votes dont count
  (5, 1, 1, now() - '8 day'::interval, 4, FALSE),

-- Superseded votes don't count
  (6, 1,  1, now(), 5, TRUE),
  (7, 1, -1, now(), 5, FALSE);
EOSQL

    ok !exception { $test->c->model('Statistics')->recalculate_all };
    my $stats = $test->c->model('Statistics::ByDate')->get_latest_statistics();

    ok(defined $stats);
    is($stats->statistic('editor.top_recently_active_voters.rank.1'), 1);
    is($stats->statistic('editor.top_recently_active_voters.rank.2'), 2);
    is($stats->statistic('editor.top_recently_active_voters.rank.3'), undef);

    is($stats->statistic('count.vote.top_recently_active_voters.rank.1'), 2);
    is($stats->statistic('count.vote.top_recently_active_voters.rank.2'), 1);
};

test 'top_voters' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
  SELECT x, 'Editor ' || x, '{CLEARTEXT}pass', md5('Editor ' || x || ':musicbrainz:pass'), '', now() FROM generate_series(1, 5) s(x);
INSERT INTO edit (id, data, status, type, open_time, expire_time, editor)
  SELECT x, '{}', 2, 1, now(), now(), 1 FROM generate_series(1, 4) s(x);

INSERT INTO vote (id, edit, vote, vote_time, editor, superseded)
VALUES
-- Votes that should count
  (1, 1, 0, now(), 1, FALSE),
  (2, 2, 1, now(), 1, FALSE),
  (3, 1, 2, now() - '5 day'::interval, 2, FALSE),

-- Abstains don't count
  (4, 1, -1, now(), 3, FALSE),

-- Old votes do count
  (5, 1, 1, now() - '8 day'::interval, 4, FALSE),

-- Superseded votes don't count
  (6, 1,  1, now(), 5, TRUE),
  (7, 1, -1, now(), 5, FALSE);
EOSQL

    ok !exception { $test->c->model('Statistics')->recalculate_all };
    my $stats = $test->c->model('Statistics::ByDate')->get_latest_statistics();

    ok(defined $stats);
    is($stats->statistic('editor.top_active_voters.rank.1'), 1);
    is($stats->statistic('editor.top_active_voters.rank.2'), 2);
    is($stats->statistic('editor.top_active_voters.rank.3'), 4);

    is($stats->statistic('count.vote.top_active_voters.rank.1'), 2);
    is($stats->statistic('count.vote.top_active_voters.rank.2'), 1);
    is($stats->statistic('count.vote.top_active_voters.rank.3'), 1);
};

1;
