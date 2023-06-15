package t::MusicBrainz::Server::Data::Vote;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use utf8;

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
MusicBrainz::Server::EditRegistry->register_type('t::Vote::MockEdit', 1);

test 'Basic voting behaviour' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+vote');

    my $vote_data = $c->model('Vote');

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );
    my $edit_id = $edit->id;

    my $editor2 = $c->model('Editor')->get_by_id(2);

    note('editor2 enters 4 votes: No -> Yes -> Abstain -> Yes');
    $vote_data->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );
    $vote_data->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );
    $vote_data->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_ABSTAIN }],
    );
    $vote_data->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );

    $edit = $c->model('Edit')->get_by_id($edit_id);
    $vote_data->load_for_edits($edit);

    is(scalar @{ $edit->votes }, 4, 'There are 4 votes on the edit');
    is($edit->votes->[0]->vote, $VOTE_NO, 'Vote 1 is a No');
    is($edit->votes->[1]->vote, $VOTE_YES, 'Vote 2 is a Yes');
    is($edit->votes->[2]->vote, $VOTE_ABSTAIN, 'Vote 3 is an Abstain');
    is($edit->votes->[3]->vote, $VOTE_YES, 'Vote 4 is a Yes (again)');

    is(
        $edit->votes->[$_]->editor_id,
        2,
        'Vote ' . ($_ + 1) . ' is by editor2',
    ) for 0..3;

    is(
        $edit->votes->[$_]->superseded,
        1,
        'Vote ' . ($_ + 1) . ' is superseded',
    ) for 0..2;
    is(
        $edit->votes->[3]->superseded,
        0,
        'Vote 4 (most recent vote by this editor) is not superseded',
    );

    # Check the vote counts
    $edit = $c->model('Edit')->get_by_id($edit_id);
    $vote_data->load_for_edits($edit);
    is($edit->yes_votes, 1, 'There is 1 Yes vote');
    is($edit->no_votes, 0, 'There are 0 No votes');

    note('editor2 now abstains again');
    $vote_data->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_ABSTAIN }],
    );
    $edit = $c->model('Edit')->get_by_id($edit_id);
    is($edit->yes_votes, 0, 'There are now 0 Yes votes');
    is($edit->no_votes, 0, 'There are still 0 No votes');
};

test 'Email on first no vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+vote');

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );
    my $edit_id = $edit->id;

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    my $editor2 = $c->model('Editor')->get_by_id(2);
    my $editor3 = $c->model('Editor')->get_by_id(3);

    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );
    is($email_transport->delivery_count, 0, 'Yes vote sends no email');

    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );
    is($email_transport->delivery_count, 1, 'First No vote sends email');

    $c->model('Vote')->enter_votes(
        $editor3,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );
    is($email_transport->delivery_count, 1, 'Second No vote sends no email');

    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );
    is($email_transport->delivery_count, 1, 'Second Yes vote sends no email');
    $c->model('Vote')->enter_votes(
        $editor3,
        [{ edit_id => $edit_id, vote => $VOTE_YES }],
    );
    is(
        $email_transport->delivery_count,
        1,
        'Changing No vote to Yes vote sends no email',
    );

    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );
    is(
        $email_transport->delivery_count,
        2,
        'New No vote bringing count from 0 to 1 sends an email',
    );

    my $email = $email_transport->shift_deliveries->{email};
    is(
        $email->get_header('Subject'),
        "Someone has voted against your edit #$edit_id",
        'Email subject explains someone has voted against your edit',
    );
    is(
        $email->get_header('References'),
        sprintf('<edit-%d@%s>', $edit_id, DBDefs->WEB_SERVER_USED_IN_EMAIL),
        'Email’s References header contains edit id',
    );
    is(
        $email->get_header('To'),
        '"editor1" <editor1@example.com>',
        'Email’s To header contains editor email',
    );

    my $server = DBDefs->WEB_SERVER_USED_IN_EMAIL;
    my $email_body = $email->object->body_str;
    like(
        $email_body,
        qr{https://$server/edit/${\ $edit_id }},
        'Email body contains link to edit',
    );
    like($email_body, qr{'editor2'}, 'Email body mentions editor2');
};

test 'Extend expiration on first no vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+vote');

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );
    my $edit_id = $edit->id;

    $c->sql->do(<<~'SQL', $edit_id);
        UPDATE edit
           SET expire_time = NOW() + interval '20 hours'
         WHERE id = ?
        SQL

    my $expected_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value(q(SELECT NOW() + interval '72 hours';)),
    );
    my $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value(
            'SELECT expire_time FROM edit WHERE id = ?',
            $edit_id,
        ),
    );
    is(
        DateTime->compare($expire_time, $expected_expire_time),
        -1,
        'Edit’s expiration time is less than 72 hours',
    );

    my $editor2 = $c->model('Editor')->get_by_id(2);

    note('We enter a No vote');
    $c->model('Vote')->enter_votes(
        $editor2,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );

    $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value(
            'SELECT expire_time FROM edit WHERE id = ?',
            $edit_id,
        ),
    );
    is(
        $expire_time,
        $expected_expire_time,
        'Edit’s expiration was extended by the no vote',
    );
};

test 'Voting is blocked in the appropriate cases' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+vote');

    my $edit = $c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );
    my $edit_id = $edit->id;

    my $edit_creator = $c->model('Editor')->get_by_id(1);
    my $normal_voter = $c->model('Editor')->get_by_id(2);

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    note('We try to enter a No vote with the editor who entered the edit');
    $c->model('Vote')->enter_votes(
        $edit_creator,
        [{ edit_id => $edit_id, vote => $VOTE_NO }],
    );
    $edit = $c->model('Edit')->get_by_id($edit_id);
    $c->model('Vote')->load_for_edits($edit);
    is(
        $email_transport->delivery_count,
        0,
        'The forbidden No vote did not trigger an email',
    );

    is(scalar @{ $edit->votes }, 0, 'The vote count is still 0');

    is($edit->yes_votes, 0, 'There are 0 Yes votes');
    is($edit->no_votes, 0, 'There are 0 No votes');

    note('We try to enter an invalid vote with a valid voter');
    $c->model('Vote')->load_for_edits($edit);
    $c->model('Vote')->enter_votes(
        $normal_voter,
        [{ edit_id => $edit_id, vote => 123 }],
    );
    $edit = $c->model('Edit')->get_by_id($edit_id);
    is(scalar @{ $edit->votes }, 0, 'The vote count is still 0');
    is($edit->yes_votes, 0, 'There are still 0 Yes votes');
    is($edit->no_votes, 0, 'There are still 0 No votes');
};

test 'Vote statistics for editor' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+vote_stats');

    my $editor = $c->model('Editor')->get_by_id(1);
    my $stats = $c->model('Vote')->editor_statistics($editor);
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
