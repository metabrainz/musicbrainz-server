package t::MusicBrainz::Server::Edit::Work::Edit;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::Edit };

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

my $work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

my $edit = create_edit($c, $work);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

my ($edits) = $c->model('Edit')->find({ work => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 1);

reject_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

$work = $c->model('Work')->get_by_id(1);
$edit = create_edit($c, $work);
accept_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
is($work->name, 'Edited name');
is($work->comment, 'Edited comment');
is($work->iswc, 'T-000.000.001-0');
is($work->type_id, 1);
is($work->edits_pending, 0);

};

sub create_edit {
    my $c = shift;
    my $work = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        to_edit => $work,
        name => 'Edited name',
        comment => 'Edited comment',
        iswc => 'T-000.000.001-0',
        type_id => 1,
    );
}

sub is_unchanged {
    my $work = shift;
    is($work->name, 'Traits (remix)');
    is($work->comment, undef);
    is($work->iswc, undef);
    is($work->type_id, undef);
}

1;
