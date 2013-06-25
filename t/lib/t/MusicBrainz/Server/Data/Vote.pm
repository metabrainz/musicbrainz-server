package t::MusicBrainz::Server::Data::Vote;
use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN { use MusicBrainz::Server::Data::Vote }

use MusicBrainz::Server::Email;
use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Test;
use DateTime;

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
    is($email_transport->delivery_count, 0, 'yes vote sends no email');

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
    is($email_transport->delivery_count, 1, 'first no vote sends email');

    $c->model('Vote')->enter_votes(3, { edit_id => $edit->id, vote => $VOTE_NO });
    is($email_transport->delivery_count, 1, 'second no vote sends no email');

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_YES });
    is($email_transport->delivery_count, 1, 'yes vote sends no email');
    $c->model('Vote')->enter_votes(3, { edit_id => $edit->id, vote => $VOTE_YES });
    is($email_transport->delivery_count, 1, 'yes vote sends no email');

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
    is($email_transport->delivery_count, 2, 'new no vote bringing count from 0 to 1 sends an email');
};

test 'Extend expiration on first no vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );

    $c->sql->do("UPDATE edit SET expire_time = NOW() + interval '20 hours'
        WHERE id = ?", $edit->id);

    my $expected_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value("SELECT NOW() + interval '72 hours';"));
    my $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value("SELECT expire_time FROM edit WHERE id = ?", $edit->id));
    is(DateTime->compare($expire_time, $expected_expire_time), -1,
                         'edit\'s expiration time is less than 72 hours');

    $c->model('Vote')->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });

    $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value("SELECT expire_time FROM edit WHERE id = ?", $edit->id));
    is($expire_time, $expected_expire_time, 'edit\'s expiration was extended by the no vote');
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
is($email_transport->delivery_count, 1);

my $email = $email_transport->shift_deliveries->{email};
is($email->get_header('Subject'), 'Someone has voted against your edit #2', 'Subject explains someone has voted against your edit');
is($email->get_header('References'), sprintf '<edit-%d@%s>', $edit->id, DBDefs->WEB_SERVER_USED_IN_EMAIL, 'References header contains edit id');
is($email->get_header('To'), '"editor1" <editor1@example.com>', 'To header contains editor email');

my $server = DBDefs->WEB_SERVER_USED_IN_EMAIL;
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
is($email_transport->delivery_count, 0);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Check the vote counts
$edit = $test->c->model('Edit')->get_by_id($edit->id);
$vote_data->load_for_edits($edit);
is($edit->yes_votes, 1);
is($edit->no_votes, 0);

$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
$edit = $test->c->model('Edit')->get_by_id($edit->id);
is($edit->yes_votes, 0);
is($edit->no_votes, 0);

# Make sure *new* no-votes against result in an email being sent
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => $VOTE_NO });
is($email_transport->delivery_count, 1, 'no-vote count 0-1 results in email');

# but that ones that just add extra no-votes don't send any
$vote_data->enter_votes(3, { edit_id => $edit->id, vote => $VOTE_NO });
is($email_transport->delivery_count, 1, 'no-vote count 1-2 does not result in additional email');

# Entering invalid votes doesn't do anything
$vote_data->load_for_edits($edit);
my $old_count = @{ $edit->votes };
$vote_data->enter_votes(2, { edit_id => $edit->id, vote => 123 });
is(@{ $edit->votes }, $old_count, 'vote count should not have changed');

# Check the voting statistics
my $stats = $vote_data->editor_statistics($test->c->model('Editor')->get_by_id(1));
is_deeply($stats, [
    {
        name   => 'Yes',
        recent => {
            count      => 2,
            percentage => 50,
        },
        all    => {
            count      => 3,
            percentage => 60
        }
    },
    {
        name   => 'No',
        recent => {
            count      => 1,
            percentage => 25,
        },
        all    => {
            count      => 1,
            percentage => 20
        }
    },
    {
        name   => 'Abstain',
        recent => {
            count      => 1,
            percentage => 25,
        },
        all    => {
            count      => 1,
            percentage => 20
        }
    },
    {
        name   => 'Total',
        recent => {
            count      => 4,
        },
        all    => {
            count      => 5,
        }
    }
]);

};

1;
