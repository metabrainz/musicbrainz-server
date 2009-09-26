#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::Delete'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');

is($edit->label_id, 1);

my ($edits, $hits) = $c->model('Edit')->find({ label => $edit->label_id }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);
is($edit->label->id, $edit->label_id);
is($edit->label->edits_pending, 1);

reject_edit($c, $edit);
$c->model('Edit')->load_all($edit);
is($edit->label->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);
$c->model('Edit')->load_all($edit);
is($edit->label, undef);

done_testing;

sub create_edit {
    return  $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_DELETE,
        label_id => 1,
        editor_id => 1
    );
}
