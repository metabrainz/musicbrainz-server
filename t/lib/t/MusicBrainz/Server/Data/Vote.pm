package t::MusicBrainz::Server::Data::Vote;
use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN { use MusicBrainz::Server::Data::Vote }

use MusicBrainz::Server::Email;
use MusicBrainz::Server::Types qw( :vote );
use MusicBrainz::Server::Test;

with 't::Context';

{
    package t::Vote::MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 4242 }
    sub edit_name { 'mock edit' }
}

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type("t::Vote::MockEdit", 1);

test 'Email on first no vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });
    is(scalar @{ $email_transport->deliveries }, 0);

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
    is(scalar @{ $email_transport->deliveries }, 1);
};

test all => sub {

{
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::_RUNNING_TESTS = sub { 1 };
}

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');
MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+vote_stats');

my $vote_data = $test->c->model('Vote');

my $edit = $test->c->model('Edit')->create(
    editor_id => 1,
    edit_type => 4242,
    foo => 'bar',
);

# Test voting on an edit
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
is(scalar @{ $email_transport->deliveries }, 1);

my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Someone has voted against your edit #2', 'Subject explains someone has voted against your edit');
is($email->get_header('References'), sprintf '<edit-%d@musicbrainz.org>', $edit->id, 'References header contains edit id');
is($email->get_header('To'), '"editor1" <editor1@example.com>', 'To header contains editor email');

my $server = DBDefs::WEB_SERVER_USED_IN_EMAIL;
like($email->get_body, qr{http://$server/edit/${\ $edit->id }}, 'body contains link to edit');
like($email->get_body, qr{'editor2'}, 'body mentions editor2');

$edit = $test->c->model('Edit')->get_by_id($edit->id);
$vote_data->load_for_edits($edit);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[0]->vote, $VOTE_NO, 'no vote saved correctly');
is($edit->votes->[1]->vote, $VOTE_YES, 'yes vote saved correctly');
is($edit->votes->[2]->vote, $VOTE_ABSTAIN, 'abstain vote saved correctly');
is($edit->votes->[3]->vote, $VOTE_YES, 'yes vote saved correctly');

is($edit->votes->[$_]->superseded, 1) for 0..2;
is($edit->votes->[3]->superseded, 0);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Make sure the person who created a vote cannot vote
$vote_data->enter_votes(1, { edit_id => $edit->id, vote => $VOTE_NO });
$edit = $test->c->model('Edit')->get_by_id($edit->id);
$vote_data->load_for_edits($edit);
is(scalar @{ $email_transport->deliveries }, 1);
is($email_transport->deliveries->[-1]->{email}, $email);

is(scalar @{ $edit->votes }, 5);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Check the vote counts
$edit = $test->c->model('Edit')->get_by_id($edit->id);
$vote_data->load_for_edits($edit);
is($edit->yes_votes, 1);
is($edit->no_votes, 1);

$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
$edit = $test->c->model('Edit')->get_by_id($edit->id);
is($edit->yes_votes, 0);
is($edit->no_votes, 1);

# Make sure future no votes do not cause another email to be sent out
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
is(scalar @{ $email_transport->deliveries }, 1);
is($email_transport->deliveries->[-1]->{email}, $email);

# Entering invalid votes doesn't do anything
$vote_data->load_for_edits($edit);
my $old_count = @{ $edit->votes };
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => 123 });
is(@{ $edit->votes }, $old_count, 'vote count should not have changed');

# Check the voting statistics
my $stats = $vote_data->editor_statistics(1);
is_deeply($stats, [
    {
        name   => 'Yes',
        recent => {
            count      => 2,
            percentage => 40,
        },
        all    => {
            count      => 3,
            percentage => 50
        }
    },
    {
        name   => 'No',
        recent => {
            count      => 2,
            percentage => 40,
        },
        all    => {
            count      => 2,
            percentage => 33
        }
    },
    {
        name   => 'Abstain',
        recent => {
            count      => 1,
            percentage => 20,
        },
        all    => {
            count      => 1,
            percentage => 17
        }
    },
    {
        name   => 'Total',
        recent => {
            count      => 5,
        },
        all    => {
            count      => 6,
        }
    }
]);

};

1;
