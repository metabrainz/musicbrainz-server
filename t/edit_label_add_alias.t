use strict;
use Test::More;
BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::AddAlias' }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ALIAS );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');
ok(defined $edit->alias_id);
ok($edit->alias_id > 0);

my ($edits) = $c->model('Edit')->find({ label => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->label_id, 1);
is($edit->label->id, 1);
ok($edit->alias_id > 3);
is($edit->alias->id, $edit->alias_id);
is($edit->label->edits_pending, 1);
is($edit->alias->name, 'Another alias');

$c->model('Edit')->reject($edit);

my $alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

my $label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

my $edit = _create_edit();
$c->model('Edit')->accept($edit);
$c->model('Edit')->load_all($edit);
is($edit->label->edits_pending, 0);
is($edit->alias->edits_pending, 0);
is($edit->alias->name, 'Another alias');

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_ADD_ALIAS,
        editor_id => 1,
        label_id => 1,
        alias => 'Another alias',
    );
}
