package t::MusicBrainz::Server::Edit::Recording::AddISRCs;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::AddISRCs };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

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

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_ADD_ISRCS,
        editor_id => 1,
        isrcs => [
            { recording => { id => 1, name => 'Recording' }, isrc => 'DEE250800232' }
        ]
    );
}

1;
