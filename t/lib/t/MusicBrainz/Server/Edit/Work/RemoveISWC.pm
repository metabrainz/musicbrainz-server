package t::MusicBrainz::Server::Edit::Work::RemoveISWC;
use Test::Routine;
use Test::More;

around run_test => sub {
    my ($orig, $test) = splice(@_, 0, 2);
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');
    $test->_clear_edit;
    $test->edit;
    $test->$orig(@_);
};

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_REMOVE_ISWC $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

has edit => (
    is => 'ro',
    lazy => 1,
    clearer => '_clear_edit',
    builder => '_build_edit'
);

test 'Entering makes no changes' => sub {
    my $test = shift;
    my $iswc = $test->c->model('ISWC')->get_by_id(1);
    ok(defined $iswc, 'The ISWC object still exists');
    is($iswc->edits_pending, 1, 'The ISWC has 1 edit pending');
};

test 'Can accept' => sub {
    my $test = shift;
    accept_edit($test->c, $test->edit);
    is($test->edit->status, $STATUS_APPLIED);

    my $iswc = $test->c->model('ISWC')->get_by_id(1);
    ok(!defined $iswc, 'The ISWC object no longer exists');
};

test 'Can reject' => sub {
    my $test = shift;
    reject_edit($test->c, $test->edit);

    my $iswc = $test->c->model('ISWC')->get_by_id(1);
    ok(defined $iswc, 'The ISWC object still exists');
    is($iswc->edits_pending, 0, 'The ISWC has no edits pending');
};

test 'Can build_display_data for accepted edits' => sub {
    my $test = shift;
    accept_edit($test->c, $test->edit);

    $test->c->model('Edit')->load_all($test->edit);
    is($test->edit->display_data->{iswc}{iswc}, 'T-000.000.001-0');
};

sub _build_edit {
    my ($test, $url, $url_to_edit) = @_;
    $test->c->model('Edit')->create(
        edit_type => $EDIT_WORK_REMOVE_ISWC,
        editor_id => 1,
        iswc => $test->c->model('ISWC')->get_by_id(1)
    );
}

1;
