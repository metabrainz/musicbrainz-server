package t::MusicBrainz::Server::Edit::Recording::AddPUIDs;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::AddPUIDs };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_PUIDS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');

my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

($edits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is(scalar @$edits, 0);

my $recording = $c->model('Recording')->get_by_id(1);
is($recording->edits_pending, 0);

my @puids = $c->model('RecordingPUID')->find_by_recording(1);
is(scalar @puids, 1);
is($puids[0]->puid->puid, '1f93eae7-f210-455d-8b7a-8df4d88d16bb');

};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_ADD_PUIDS,
        editor_id => 1,
        client_version => 'App-1.0',
        puids => [
            { recording => { id => 1, name => 'Recording' },
              puid => '1f93eae7-f210-455d-8b7a-8df4d88d16bb' }
        ]
    );
}

1;
