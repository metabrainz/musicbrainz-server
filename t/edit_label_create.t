#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::Create'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+labeltype');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE label CASCADE;
SQL
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');

ok(defined $edit->label_id);

my ($edits, $hits) = $c->model('Edit')->find({ label => $edit->label_id }, 0, 10);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);
ok(defined $edit->label);
is($edit->label->name, '!K7');
is($edit->label->sort_name, '!K7 Recordings');
is($edit->label->type_id, 1);
is($edit->label->comment, "Funky record label");
is($edit->label->label_code, 7306);
is($edit->label->edits_pending, 1);
is($edit->label->begin_date->year, 1995);
is($edit->label->begin_date->month, 1);
is($edit->label->begin_date->day, 12);
is($edit->label->end_date->year, 2005);
is($edit->label->end_date->month, 5);
is($edit->label->end_date->day, 30);

$c->model('Edit')->accept($edit);
my $label = $c->model('Label')->get_by_id($edit->label_id);
is($label->edits_pending, 0);

# Test rejecting the edit
$edit = create_edit();
$c->model('Edit')->reject($edit);

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);
ok(!defined $edit->label);

done_testing;

sub create_edit
{
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,

        name => '!K7',
        sort_name => '!K7 Recordings',
        type_id => 1,
        comment => 'Funky record label',
        label_code => 7306,
        begin_date => { year => 1995, month => 1, day => 12 },
        end_date => { year => 2005, month => 5, day => 30 }
    );
}
