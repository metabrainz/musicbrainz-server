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

=head1 DESCRIPTION

This test checks whether votes are counted correctly, and whether No votes
notify the edit editor and extend the edit expiration date when needed.

=cut

test 'Email is sent on first No vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    my $editor2 = $c->model('Editor')->get_by_id(2);
    my $editor3 = $c->model('Editor')->get_by_id(3);

    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });
    is(
        $email_transport->delivery_count,
        0,
        'A Yes vote sends no email',
    );

    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });
    is(
        $email_transport->delivery_count,
        1,
        'The first No vote sends email',
    );

    my $email = $email_transport->shift_deliveries->{email};
    is(
        $email->get_header('Subject'),
        'Someone has voted against your edit #21',
        'Subject explains someone has voted against your edit',
    );
    is(
        $email->get_header('References'),
        sprintf('<edit-%d@%s>', $edit->id, DBDefs->WEB_SERVER_USED_IN_EMAIL),
        'References header contains edit id',
    );
    is(
        $email->get_header('To'),
        '"editor1" <editor1@example.com>',
        'To header contains editor email',
    );

    my $server = DBDefs->WEB_SERVER_USED_IN_EMAIL;
    my $email_body = $email->object->body_str;
    like(
        $email_body,
        qr{https://$server/edit/${\ $edit->id }},
        'Email body contains link to edit',
    );
    like($email_body, qr{'editor2'}, 'Email body mentions voter name');

    $c->model('Vote')->enter_votes($editor3, { edit_id => $edit->id, vote => $VOTE_NO });
    is(
        $email_transport->delivery_count,
        0,
        'A second No vote sends no email',
    );

    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });
    is(
        $email_transport->delivery_count,
        0,
        'Changing the first No vote to Yes sends no email',
    );
    $c->model('Vote')->enter_votes($editor3, { edit_id => $edit->id, vote => $VOTE_YES });
    is(
        $email_transport->delivery_count,
        0,
        'Changing the second No vote to Yes sends no email',
    );

    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });
    is(
        $email_transport->delivery_count,
        1,
        'Changing a Yes vote to No and bringing No count from 0 to 1 again sends an email',
    );
};

test 'Extend expiration of soon-to-expire edits on first No vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );

    my $editor2 = $c->model('Editor')->get_by_id(2);

    my $minimum_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value(q(SELECT NOW() + interval '72 hours';)));
    my $current_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit->id));
    is(
        DateTime->compare($current_expire_time, $minimum_expire_time),
        1,
        q(The edit's current expiration time is more than 72 hours),
    );

    my $previous_expire_time = $current_expire_time;
    note('We enter a No vote');
    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });

    $current_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit->id));
    is(
        DateTime->compare($current_expire_time, $previous_expire_time),
        0,
        q(The edit's current expiration time is not changed since it was more than 72 hours),
    );

    note('We change the No vote to Yes to go back to 0 No votes');
    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });

    note('We set the edit expiration time to only 20 hours from now');
    $c->sql->do(
        q(UPDATE edit SET expire_time = NOW() + interval '20 hours' WHERE id = ?),
        $edit->id
    );

    $current_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit->id));
    is(
        DateTime->compare($current_expire_time, $minimum_expire_time),
        -1,
        q(The edit's current expiration time is less than 72 hours),
    );

    note('We enter a No vote again');
    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });

    $current_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit->id));
    is(
        $current_expire_time,
        $minimum_expire_time,
        q(The edit's expiration was extended to the 72 h minimum by the No vote),
    );

    $previous_expire_time = $current_expire_time;

    note('We change the No vote to Yes again');
    $c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });

    $current_expire_time = DateTime::Format::Pg->parse_datetime(
        $c->sql->select_single_value('SELECT expire_time FROM edit WHERE id = ?', $edit->id));
    is(
        DateTime->compare($current_expire_time, $previous_expire_time),
        0,
        q(The edit's current expiration time is not changed back even if the No vote is gone),
    );
};

test 'Vote entering and counting' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $vote_data = $test->c->model('Vote');

    my $edit = $test->c->model('Edit')->create(
        editor_id => 1,
        edit_type => 4242,
        foo => 'bar',
    );

    my $editor1 = $test->c->model('Editor')->get_by_id(1);
    my $editor2 = $test->c->model('Editor')->get_by_id(2);
    my $editor3 = $test->c->model('Editor')->get_by_id(3);

    note('editor2 enters 4 votes in the order: No->Yes->Abstain->Yes');
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_YES });

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $vote_data->load_for_edits($edit);

    is(scalar @{ $edit->votes }, 4, '4 votes were saved for the edit');
    is($edit->votes->[0]->vote, $VOTE_NO, 'No vote saved correctly');
    is($edit->votes->[1]->vote, $VOTE_YES, 'First Yes vote saved correctly');
    is(
        $edit->votes->[2]->vote,
        $VOTE_ABSTAIN,
        'Abstain vote saved correctly',
    );
    is($edit->votes->[3]->vote, $VOTE_YES, 'Second Yes vote saved correctly');

    ok(
        $edit->votes->[$_]->superseded,
        "Vote $_ is marked as superseded",
    ) for 0..2;
    ok(!$edit->votes->[3]->superseded, 'The latest vote is not superseded');
    is(
        $edit->votes->[$_]->editor_id,
        2,
        "The right editor is stored for vote $_",
    ) for 0..3;

    note('The edit editor tries to enter a vote');
    $vote_data->enter_votes($editor1, { edit_id => $edit->id, vote => $VOTE_NO });
    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $vote_data->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 4, 'We still have only 4 votes for the edit');

    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $vote_data->load_for_edits($edit);
    is($edit->yes_votes, 1, 'There is 1 Yes vote at the moment');
    is($edit->no_votes, 0, 'There are 0 No votes at the moment');

    note('editor2 changes their Yes vote to Abstain');
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_ABSTAIN });
    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $vote_data->load_for_edits($edit);
    is($edit->yes_votes, 0, 'There are 0 Yes votes at the moment');
    is($edit->no_votes, 0, 'There are 0 No votes at the moment');

    note('editor2 changes their Abstain vote to No');
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => $VOTE_NO });
    note('editor3 also votes No');
    $vote_data->enter_votes($editor3, { edit_id => $edit->id, vote => $VOTE_NO });
    $edit = $test->c->model('Edit')->get_by_id($edit->id);
    $vote_data->load_for_edits($edit);
    is($edit->yes_votes, 0, 'There are 0 Yes votes at the moment');
    is($edit->no_votes, 2, 'There are 2 No votes at the moment');

    $vote_data->load_for_edits($edit);
    my $old_count = @{ $edit->votes };
    note('We try to enter an invalid vote value for editor2');
    $vote_data->enter_votes($editor2, { edit_id => $edit->id, vote => 123 });
    is(@{ $edit->votes }, $old_count, 'The vote count remains unchanged');
};

test 'Vote stats' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+vote_stats');

    my $vote_data = $test->c->model('Vote');

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
    ], 'The vote stats for editor 1 match our expectation');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
