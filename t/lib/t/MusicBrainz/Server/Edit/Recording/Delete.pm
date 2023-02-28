package t::MusicBrainz::Server::Edit::Recording::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::Delete; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');

    my $recording = $c->model('Recording')->get_by_id(1);

    my $edit = create_edit($c, $recording);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ recording => $recording->id }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $edit = $c->model('Edit')->get_by_id($edit->id);
    $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 1);

    reject_edit($c, $edit);
    $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 0);

    $edit = create_edit($c, $recording);
    accept_edit($c, $edit);
    $recording = $c->model('Recording')->get_by_id(1);
    ok(!defined $recording);
};

test 'Edit is failed if recording no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');

    my $recording = $c->model('Recording')->get_by_id(1);
    my $edit1 = create_edit($c, $recording);
    my $edit2 = create_edit($c, $recording);

    $edit1->accept;
    isa_ok exception { $edit2->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub create_edit {
    my ($c, $recording) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_DELETE,
        to_delete => $recording,
        editor_id => 1
    );
}

1;
