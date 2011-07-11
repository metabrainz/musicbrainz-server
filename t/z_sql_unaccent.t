#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use encoding 'utf8';
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();

my $sql = Sql->new($c->dbh);

my $val = $sql->select_single_value("SELECT musicbrainz_unaccent('foo');");
is ($val, "foo");

$val = $sql->select_single_value("SELECT musicbrainz_unaccent('fôó');");
is ($val, "foo");

$val = $sql->select_single_value("SELECT musicbrainz_unaccent('Diyarbakır');");
is ($val, "Diyarbakir", "turkish dotless ı converted to i");

$val = $sql->select_single_value("SELECT musicbrainz_unaccent('Ænima');");
is ($val, "AEnima", "Æ expanded to AE");

$val = $sql->select_single_value("SELECT musicbrainz_unaccent('Пётр');");
is ($val, "Петр");

$val = $sql->select_single_value("SELECT ts_lexize('musicbrainz_unaccentdict', 'Ænima');");
is ($val->[0], "aenima");

$val = $sql->select_single_value("SELECT ts_lexize('musicbrainz_unaccentdict', 'Пётр');");
is ($val->[0], "петр");

$val = $sql->select_single_value("SELECT ts_lexize('musicbrainz_unaccentdict', 'Hey');");
is ($val->[0], "hey");

done_testing;
