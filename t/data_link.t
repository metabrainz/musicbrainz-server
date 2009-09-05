#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::Link';

use Sql;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');

my $sql = Sql->new($c->dbh);

my $link_id = $c->model('Link')->find_or_insert({
    link_type_id => 1,
    attributes => [ 4 ],
});
is($link_id, 1);

$link_id = $c->model('Link')->find_or_insert({
    link_type_id => 1,
    attributes => [ 1, 3 ],
});
is($link_id, 2);

$link_id = $c->model('Link')->find_or_insert({
    link_type_id => 1,
    attributes => [ 3, 1 ],
});
is($link_id, 2);

$sql->Begin;
$link_id = $c->model('Link')->find_or_insert({
    link_type_id => 1,
    begin_date => { year => 2009 },
    end_date => { year => 2010 },
    attributes => [ 1, 3 ],
});
$sql->Commit;
is($link_id, 100);

my $link = $c->model('Link')->get_by_id(100);
is_deeply($link->begin_date, { year => 2009 });
is_deeply($link->end_date, { year => 2010 });
