package t::MusicBrainz::Server::Edit::Recording::AddISRCs;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::AddISRCs };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS $UNTRUSTED_FLAG $STATUS_OPEN );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');

my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

my $recording = $c->model('Recording')->get_by_id(1);
is($recording->edits_pending, 0);

my @isrcs = $c->model('ISRC')->find_by_recordings(1);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800232');

isa_ok exception { create_edit($c) }, 'MusicBrainz::Server::Edit::Exceptions::NoChanges',
    'inserting the same ISRCs results in no changes';

};

test 'Applying open edits adding duplicates is a no-op (MBS-8032)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

    my $edit_1 = create_edit($c, $UNTRUSTED_FLAG);
    isa_ok($edit_1, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is($edit_1->status, $STATUS_OPEN, 'first edit is open');

    my @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 0, 'recording has no ISRCs yet');

    my $edit_2 = create_edit($c);
    isa_ok($edit_2, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    isnt($edit_2->status, $STATUS_OPEN, 'second edit is applied');

    @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 1, 'Recording has one ISRC now');
    is($isrcs[0]->isrc, 'DEE250800232', 'Recording has correct ISRC');

    ok !exception { $edit_1->accept }, 'First edit can be applied';

    @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 1, 'Recording still has one ISRC');
    is($isrcs[0]->isrc, 'DEE250800232', 'One ISRC is still correct');
};

sub create_edit {
    my ($c, $privs) = @_;
    $privs //= 0;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_ADD_ISRCS,
        editor_id => 1,
        privileges => $privs,
        isrcs => [
            { recording => { id => 1, name => 'Recording' }, isrc => 'DEE250800232' }
        ]
    );
}

1;
