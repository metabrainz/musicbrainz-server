package t::MusicBrainz::Server::Edit::Work::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::Delete }

use MusicBrainz::Server::Constants qw(
    :edit_status
    $EDIT_WORK_DELETE
    $EDITOR_MODBOT
);
use MusicBrainz::Server::Test qw( accept_edit );

test 'Can delete works' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+work');

    my $work = $c->model('Work')->get_by_id(1);

    my $edit = create_edit($c, $work);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ work => $work->id }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $work = $c->model('Work')->get_by_id($work->id);
    is($work->edits_pending, 1);

    # Test accepting the edit
    accept_edit($c, $edit);
    $work = $c->model('Work')->get_by_id($work->id);
    is($edit->status, $STATUS_APPLIED);
    ok(!defined $work);
};

test 'Can be entered as an auto-edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+work');

    my $work = $c->model('Work')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_WORK_DELETE,
        to_delete => $work,
        editor_id => $EDITOR_MODBOT,
        privileges => 1
    );
    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Delete');

    $work = $c->model('Work')->get_by_id($work->id);
    ok(!defined $work);
};

test 'Edit is failed if work no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+work');

    my $work = $c->model('Work')->get_by_id(1);
    my $edit1 = create_edit($c, $work);
    my $edit2 = create_edit($c, $work);

    $edit1->accept;
    isa_ok exception { $edit2->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub create_edit {
    my ($c, $work) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_DELETE,
        to_delete => $work,
        editor_id => 1
    );
}

1;
