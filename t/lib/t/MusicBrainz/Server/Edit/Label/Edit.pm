package t::MusicBrainz::Server::Edit::Label::Edit;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

my $label = $c->model('Label')->get_by_id(2);
my $edit = create_full_edit($c, $label);

isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');

$edit = $c->model('Edit')->get_by_id($edit->id);
$label = $c->model('Label')->get_by_id(2);
is_unchanged($label);
is($label->edits_pending, 1);

my ($edits, $hits) = $c->model('Edit')->find({ label => $edit->label_id }, 10, 0);
is($edits->[0]->id, $edit->id);

reject_edit($c, $edit);
$label = $c->model('Label')->get_by_id($edit->label_id);
is_unchanged($label);
is($label->edits_pending, 0);

$edit = create_full_edit($c, $label);
accept_edit($c, $edit);

$label = $c->model('Label')->get_by_id($edit->label_id);
is($label->name, 'Edit Name');
is($label->sort_name, 'Edit Sort');
is($label->type_id, 1);
is($label->comment, "Edit comment");
is($label->label_code, 12345);
is($label->begin_date->year, 1995);
is($label->begin_date->month, 1);
is($label->begin_date->day, 12);
is($label->end_date->year, 2005);
is($label->end_date->month, 5);
is($label->end_date->day, 30);
is($label->edits_pending, 0);

};

sub create_full_edit {
    my ($c, $label) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 2,

        to_edit => $label,
        name => 'Edit Name',
        sort_name => 'Edit Sort',
        comment => 'Edit comment',
        country_id => 1,
        type_id => 1,
        label_code => 12345,
        begin_date => { year => 1995, month => 1, day => 12 },
        end_date => { year => 2005, month => 5, day => 30 }
    );
}

sub is_unchanged {
    my $label = shift;
    is($label->name, 'Label Name');
    is($label->sort_name, 'Label Name');
    is($label->$_, undef) for qw( comment country_id label_code );
    ok($label->begin_date->is_empty);
    ok($label->end_date->is_empty);
}

1;
