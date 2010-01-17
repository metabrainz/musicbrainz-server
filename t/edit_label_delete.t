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

my $label = $c->model('Label')->get_by_id(1);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');

my ($edits, $hits) = $c->model('Edit')->find({ label => $label->id }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);
$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 1);

reject_edit($c, $edit);
$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);
$label = $c->model('Label')->get_by_id(1);
ok(!defined $label);

done_testing;

sub create_edit {
    return  $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_DELETE,
        to_delete => $label,
        editor_id => 1
    );
}
