package t::MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Delete; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

    my $rg = $c->model('ReleaseGroup')->get_by_id(1);
    my $edit = create_edit($c, $rg);
    isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Delete');

    my ($edits) = $c->model('Edit')->find({ release_group => 1 }, 10, 0);
    is($edits->[0]->id, $edit->id);

    $edit = $c->model('Edit')->get_by_id($edit->id);

    $rg = $c->model('ReleaseGroup')->get_by_id(1);
    is($rg->edits_pending, 1);

    reject_edit($c, $edit);
    $rg = $c->model('ReleaseGroup')->get_by_id(1);
    ok(defined $rg);
    is($rg->edits_pending, 0);

    $edit = create_edit($c, $rg);
    accept_edit($c, $edit);
    $rg = $c->model('ReleaseGroup')->get_by_id(1);
    ok(!defined $rg);
};

test 'Edit is failed if release group no longer exists' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

    my $release_group = $c->model('ReleaseGroup')->get_by_id(1);
    my $edit1 = create_edit($c, $release_group);
    my $edit2 = create_edit($c, $release_group);

    $edit1->accept;
    isa_ok exception { $edit2->accept }, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

sub create_edit {
    my ($c, $rg) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_DELETE,
        editor_id => 1,
        to_delete => $rg,
    );
}

1;
