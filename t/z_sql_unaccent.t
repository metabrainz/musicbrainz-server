#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use encoding 'utf8';
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();

my $sql = Sql->new($c->dbh);

my $val = $sql->select_single_value("SELECT unaccent('foo');");
is ($val, "foo");

$val = $sql->select_single_value("SELECT unaccent('fôó');");
is ($val, "foo");

$val = $sql->select_single_value("SELECT unaccent('Diyarbakır');");
is ($val, "Diyarbakir", "turkish dotless ı converted to i");

$val = $sql->select_single_value("SELECT unaccent('Ænima');");
is ($val, "AEnima", "Æ expanded to AE");

$val = $sql->select_single_value("SELECT unaccent('Пётр');");
is ($val, "Петр");

$val = $sql->select_single_value("SELECT ts_lexize('unaccentdict', 'Ænima');");
is ($val->[0], "aenima");

$val = $sql->select_single_value("SELECT ts_lexize('unaccentdict', 'Пётр');");
is ($val->[0], "петр");

$val = $sql->select_single_value("SELECT ts_lexize('unaccentdict', 'Hey');");
is ($val->[0], "hey");

done_testing;
