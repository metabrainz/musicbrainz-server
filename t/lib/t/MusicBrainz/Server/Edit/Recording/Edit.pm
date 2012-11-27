package t::MusicBrainz::Server::Edit::Recording::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Recording::Edit };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

my $recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 0);

my $edit = create_edit($c, $recording);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');

my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 1);

reject_edit($c, $edit);

$recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 0);

$recording = $c->model('Recording')->get_by_id(1);
$edit = create_edit($c, $recording);
accept_edit($c, $edit);

$recording = $c->model('Recording')->get_by_id(1);
$c->model('ArtistCredit')->load($recording);
is($recording->name, 'Edited name');
is($recording->comment, 'Edited comment');
is($recording->length, 12345);
is($recording->edits_pending, 0);
is($recording->artist_credit->name, 'Foo');

};

test 'Case changes to recording comments are auto-edits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');
    $c->model('Recording')->update(1, { comment => 'test comment' });
    my $recording = $c->model('Recording')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit => $recording,
        comment => 'Test CommenT'
    );

    is($edit->status, 2);
};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Recording')->get_by_id(1),
        name => 'Renamed recording',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Recording')->get_by_id(1),
        comment   => 'Comment change'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $recording = $c->model('Recording')->get_by_id(1);
    is ($recording->name, 'Renamed recording', 'recording renamed');
    is ($recording->comment, 'Comment change', 'comment changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Recording')->get_by_id(1),
        name    => 'Renamed recording',
        comment => 'comment FOO'
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Recording')->get_by_id(1),
        comment   => 'Comment BAR',
        length => 12345
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $recording = $c->model('Recording')->get_by_id(1);
    is ($recording->name, 'Renamed recording', 'recording renamed');
    is ($recording->comment, 'comment FOO', 'comment changed');
    is ($recording->length, undef);
};

sub create_edit {
    my ($c, $recording) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        to_edit => $recording,
        name => 'Edited name',
        comment => 'Edited comment',
        length => '12345',
        artist_credit => {
            names => [
                { artist => { id => 1 }, name => 'Foo' },
            ] } );
}

sub is_unchanged {
    my $recording = shift;
    subtest 'check recording hasnt changed' => sub {
        plan tests => 4;
        is($recording->name, 'Traits (remix)');
        is($recording->comment, '');
        is($recording->artist_credit_id, 1);
        is($recording->length, undef);
    }
}

1;
