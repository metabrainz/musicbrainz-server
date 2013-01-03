package t::MusicBrainz::Server::Data::Link;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Link;

use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+relationships');

my $link_id = $test->c->model('Link')->find_or_insert({
    link_type_id => 1,
    ended => 0,
    attributes => [ 4 ],
});
is($link_id, 1);

$link_id = $test->c->model('Link')->find_or_insert({
    link_type_id => 1,
    ended => 0,
    attributes => [ 1, 3 ],
});
is($link_id, 2);

$link_id = $test->c->model('Link')->find_or_insert({
    link_type_id => 1,
    ended => 0,
    attributes => [ 3, 1 ],
});
is($link_id, 2);

$test->c->sql->begin;
$link_id = $test->c->model('Link')->find_or_insert({
    link_type_id => 1,
    begin_date => { year => 2009 },
    end_date => { year => 2010 },
    ended => 0,
    attributes => [ 1, 3 ],
});
$test->c->sql->commit;
is($link_id, 100);

my $link = $test->c->model('Link')->get_by_id(100);
is_deeply($link->begin_date, { year => 2009 });
is_deeply($link->end_date, { year => 2010 });

$test->c->sql->begin;
$link_id = $test->c->model('Link')->find_or_insert({
    link_type_id => 1,
    begin_date => { year => 2009 },
    end_date => { year => 2010 },
    ended => 0,
    attributes => [ 1, 3 ],
});
$test->c->sql->commit;
is($link_id, 100, "find_or_insert() correctly re-uses a link with end date");

};

1;
