package t::MusicBrainz::Server::Edit::Recording::RemoveISRC;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::RemoveISRC };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_REMOVE_ISRC );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+isrc');

my $isrc = $c->model('ISRC')->get_by_id(1);

{
    my $edit = create_edit($c, $isrc);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::RemoveISRC');

    my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
    is($edits->[0]->id, $edit->id);

    my $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 1);

    my @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 1);

    reject_edit($c, $edit);

    @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 1);

    $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 0);
}

{
    my $edit = create_edit($c, $isrc);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::RemoveISRC');

    my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
    is($edits->[0]->id, $edit->id);

    my $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 1);

    my @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 1);

    accept_edit($c, $edit);

    @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 0);

    $recording = $c->model('Recording')->get_by_id(1);
    is($recording->edits_pending, 0);
}

};

sub create_edit {
    my ($c, $isrc) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_REMOVE_ISRC,
        editor_id => 1,
        isrc      => $isrc
    );
}

1;
