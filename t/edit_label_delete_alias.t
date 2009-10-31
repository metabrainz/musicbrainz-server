use strict;
use Test::More;
use Test::Moose;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::DeleteAlias' }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE_ALIAS );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::DeleteAlias');

my ($edits) = $c->model('Edit')->find({ label => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->label_id, 1);
is($edit->label->id, 1);
is($edit->label->edits_pending, 1);
is($edit->alias_id, 1);
is($edit->alias->id, 1);
is($edit->alias->edits_pending, 1);

my $alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

MusicBrainz::Server::Test::reject_edit($c, $edit);

my $alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

my $label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

my $alias = $c->model('Label')->alias->get_by_id(1);
ok(defined $alias);
is($alias->edits_pending, 0);

my $edit = _create_edit();
MusicBrainz::Server::Test::accept_edit($c, $edit);
$c->model('Edit')->load_all($edit);
is($edit->label->edits_pending, 0);
ok(!defined $edit->alias);

$alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 1);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_DELETE_ALIAS,
        editor_id => 1,
        entity_id => 1,
        alias_id => 1,
    );
}
