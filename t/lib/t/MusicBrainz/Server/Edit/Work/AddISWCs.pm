package t::MusicBrainz::Server::Edit::Work::AddISWCs;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $UNTRUSTED_FLAG );
use Test::Routine;
use Test::More;
use Test::Fatal;

around run_test => sub {
    my ($orig, $test) = splice(@_, 0, 2);
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');
    $test->$orig(@_);
};

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ISWCS $STATUS_APPLIED );

my $valid_addition = { work => { id => 10, name => 'Foo' }, iswc => 'T-111.222.002-0' };
my $already_exists = { work => { id => 1, name => 'Foo' }, iswc => 'T-000.000.001-0' };

test 'Enters an autoedit' => sub {
    my $test = shift;
    my $edit = _create_edit($test, [
        $valid_addition
    ]);

    ok(!$edit->is_open, 'The edit is not open');
    is($edit->status, $STATUS_APPLIED, 'The edit is applied');

    my @iswcs = $test->c->model('ISWC')->find_by_iswc('T-111.222.002-0');
    is(@iswcs, 1, 'Found 1 ISWC objects with ISWC=T-111.222.002-0');

    iswc_ok($iswcs[0], 'T-111.222.002-0', 10);
};

test 'Enters set of ISWCs (no duplicates)' => sub {
    my $test = shift;
    my $edit = _create_edit($test, [
        $valid_addition, $valid_addition
    ]);

    ok(!$edit->is_open, 'The edit is not open');
    is($edit->status, $STATUS_APPLIED, 'The edit is applied');

    my @iswcs = $test->c->model('ISWC')->find_by_iswc('T-111.222.002-0');
    is(@iswcs, 1, 'Found 1 ISWC object with ISWC=T-111.222.002-0');

    iswc_ok($iswcs[0], 'T-111.222.002-0', 10);
};

test 'Notices no changes' => sub {
    my $test = shift;
    isa_ok exception {
        _create_edit($test, [
            $already_exists
        ]);
    }, 'MusicBrainz::Server::Edit::Exceptions::NoChanges';
};

test 'Fails if all the works have been deleted' => sub {
    my $test = shift;

    my $edit = _create_edit($test, [$valid_addition], privileges => $UNTRUSTED_FLAG);
    $test->c->model('Work')->delete(10);
    isa_ok exception { $edit->accept }, 'MusicBrainz::Server::Edit::Exceptions::NoLongerApplicable';
};

test 'Adds ISWCs to works that exist, even if some works were deleted' => sub {
    my $test = shift;

    my $edit = _create_edit(
        $test,
        [
            $valid_addition,
            { work => { id => 1, name => 'Foo' }, iswc => 'T-222.333.001-0' },
        ],
        privileges => $UNTRUSTED_FLAG,
    );

    $test->c->model('Work')->delete(10);
    $edit->accept;

    my @iswcs = $test->c->model('ISWC')->find_by_iswc('T-222.333.001-0');
    is(@iswcs, 1, 'Found 1 ISWC object with ISWC=T-222.333.001-0');
    iswc_ok($iswcs[0], 'T-222.333.001-0', 1);
};

sub iswc_ok {
    my ($iswc_object, $iswc, $work_id) = @_;
    is($iswc_object->iswc, $iswc, 'Has correct ISWC');
    is($iswc_object->work_id, $work_id, "Is linked to work=$work_id");
}

sub _create_edit {
    my ($test, $iswcs, %args) = @_;
    return $test->c->model('Edit')->create(
        edit_type => $EDIT_WORK_ADD_ISWCS,
        editor_id => 1,
        iswcs => $iswcs,
        %args,
    );
}

1;
