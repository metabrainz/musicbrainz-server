package t::MusicBrainz::Server::Edit::PUID::Delete;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::PUID::Delete; }

use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+puid');

my $delete_puid = $c->model('RecordingPUID')->get_by_recording_puid(3, '134478d1-306e-41a1-8b37-ff525e53c8be')
    or die "Could not get recording puid";
my $edit = _create_edit($c, $delete_puid);
isa_ok($edit, 'MusicBrainz::Server::Edit::PUID::Delete');

my ($edits, $hits) = $c->model('Edit')->find({ recording => 3 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my @puids = $c->model('RecordingPUID')->find_by_recording(3);
is(scalar @puids, 1);

my $puid = $c->model('RecordingPUID')->get_by_id(6);
ok(!defined $puid);

reject_edit($c, $edit);

@puids = $c->model('RecordingPUID')->find_by_recording(3);
is(scalar @puids, 2);

$edit = _create_edit($c, $delete_puid);
accept_edit($c, $edit);

};

sub _create_edit {
    my ($c, $delete_puid) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_PUID_DELETE,
        editor_id => 1,
        puid => $delete_puid,
    );
}

1;
