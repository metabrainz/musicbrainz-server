package t::MusicBrainz::Server::Data::Vote;
use strict;
use warnings;

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
MusicBrainz::Server::EditRegistry->register_type('t::Vote::MockEdit', 1);

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

    $c->model('Vote')->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_YES }]);
    is($email_transport->delivery_count, 0, 'yes vote sends no email');

    $c->model('Vote')->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
    is($email_transport->delivery_count, 1, 'first no vote sends email');

    $c->model('Vote')->enter_votes($editor3, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
    is($email_transport->delivery_count, 1, 'second no vote sends no email');

    $c->model('Vote')->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_YES }]);
    is($email_transport->delivery_count, 1, 'yes vote sends no email');
    $c->model('Vote')->enter_votes($editor3, [{ edit_id => $edit_id, vote => $VOTE_YES }]);
    is($email_transport->delivery_count, 1, 'yes vote sends no email');

    $c->model('Vote')->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
    is($email_transport->delivery_count, 2, 'new no vote bringing count from 0 to 1 sends an email');
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

    $c->sql->do(
        q(UPDATE edit SET expire_time = NOW() + interval '20 hours' WHERE id = ?),
        $edit_id
    );

    my $expected_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value(q(SELECT NOW() + interval '72 hours';)));
    my $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit_id));
    is(DateTime->compare($expire_time, $expected_expire_time), -1,
                         q(edit's expiration time is less than 72 hours));

    my $editor2 = $c->model('Editor')->get_by_id(2);

    $c->model('Vote')->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_NO }]);

    $expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit_id));
    is($expire_time, $expected_expire_time, q(edit's expiration was extended by the no vote));
};

test all => sub {

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

my $editor1 = $c->model('Editor')->get_by_id(1);
my $editor2 = $c->model('Editor')->get_by_id(2);
my $editor3 = $c->model('Editor')->get_by_id(3);

# Test voting on an edit
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_YES }]);
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_ABSTAIN }]);
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_YES }]);

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
is($email_transport->delivery_count, 1);

my $email = $email_transport->shift_deliveries->{email};
is($email->get_header('Subject'), "Someone has voted against your edit #$edit_id", 'Subject explains someone has voted against your edit');
is($email->get_header('References'), sprintf('<edit-%d@%s>', $edit_id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header contains edit id');
is($email->get_header('To'), '"editor1" <editor1@example.com>', 'To header contains editor email');

my $server = DBDefs->WEB_SERVER_USED_IN_EMAIL;
my $email_body = $email->object->body_str;
like($email_body, qr{https://$server/edit/$edit_id}, 'body contains link to edit');
like($email_body, qr{'editor2'}, 'body mentions editor2');

$edit = $c->model('Edit')->get_by_id($edit_id);
$vote_data->load_for_edits($edit);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[0]->vote, $VOTE_NO, 'no vote saved correctly');
is($edit->votes->[1]->vote, $VOTE_YES, 'yes vote saved correctly');
is($edit->votes->[2]->vote, $VOTE_ABSTAIN, 'abstain vote saved correctly');
is($edit->votes->[3]->vote, $VOTE_YES, 'yes vote saved correctly');

is($edit->votes->[$_]->superseded, 1) for 0..2;
is($edit->votes->[3]->superseded, 0);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Make sure the person who created an edit cannot vote
$vote_data->enter_votes($editor1, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
$edit = $c->model('Edit')->get_by_id($edit_id);
$vote_data->load_for_edits($edit);
is($email_transport->delivery_count, 0);

is(scalar @{ $edit->votes }, 4);
is($edit->votes->[$_]->editor_id, 2) for 0..3;

# Check the vote counts
$edit = $c->model('Edit')->get_by_id($edit_id);
$vote_data->load_for_edits($edit);
is($edit->yes_votes, 1);
is($edit->no_votes, 0);

$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_ABSTAIN }]);
$edit = $c->model('Edit')->get_by_id($edit_id);
is($edit->yes_votes, 0);
is($edit->no_votes, 0);

# Make sure *new* no-votes against result in an email being sent
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
is($email_transport->delivery_count, 1, 'no-vote count 0-1 results in email');

# but that ones that just add extra no-votes don't send any
$vote_data->enter_votes($editor3, [{ edit_id => $edit_id, vote => $VOTE_NO }]);
is($email_transport->delivery_count, 1, 'no-vote count 1-2 does not result in additional email');

# Entering invalid votes doesn't do anything
$vote_data->load_for_edits($edit);
my $old_count = @{ $edit->votes };
$vote_data->enter_votes($editor2, [{ edit_id => $edit_id, vote => 123 }]);
is(@{ $edit->votes }, $old_count, 'vote count should not have changed');
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
