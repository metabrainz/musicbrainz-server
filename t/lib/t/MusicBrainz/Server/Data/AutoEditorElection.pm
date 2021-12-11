package t::MusicBrainz::Server::Data::AutoEditorElection;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Constants qw( :election_status :election_vote );
use Sql;

with 't::Context';

test 'Accept' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $c->model('Editor')->get_by_name('autoeditor4');
    my $voter2 = $c->model('Editor')->get_by_name('autoeditor5');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    my $email_body = $email->object->body_str;
    like($email_body, qr{A new candidate has been put forward for autoeditor status});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    like($email_body, qr{Candidate:\s+noob1});
    like($email_body, qr{Proposer:\s+autoeditor1});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_SECONDER_1 );

    $election = $c->model('AutoEditorElection')->second($election, $seconder1);
    ok( $election );

    is($email_transport->delivery_count, 0);

    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_SECONDER_2 );

    $election = $c->model('AutoEditorElection')->second($election, $seconder2);
    ok( $election );

    is($email_transport->delivery_count, 1);
    $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    $email_body = $email->object->body_str;
    like($email_body, qr{Voting in this election is now open});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    like($email_body, qr{Candidate:\s+noob1});
    like($email_body, qr{Proposer:\s+autoeditor1});
    like($email_body, qr{Seconder:\s+autoeditor2});
    like($email_body, qr{Seconder:\s+autoeditor3});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $c->model('AutoEditorElection')->vote($election, $voter1, $ELECTION_VOTE_YES);
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $c->model('AutoEditorElection')->vote($election, $voter2, $ELECTION_VOTE_NO);
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 1 );
    is( $election->status, $ELECTION_OPEN );

    $c->model('AutoEditorElection')->vote($election, $voter2, $ELECTION_VOTE_ABSTAIN);
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_OPEN );

    $c->sql->do(q(UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'));

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_ACCEPTED );

    is($email_transport->delivery_count, 1);
    $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    $email_body = $email->object->body_str;
    like($email_body, qr{Voting in this election is now closed: noob1 has been\s+accepted as an auto-editor});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $candidate = $c->model('Editor')->get_by_id($candidate->id);
    ok( $candidate->is_auto_editor );
};

test 'Rejected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $c->model('Editor')->get_by_name('autoeditor4');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    $election = $c->model('AutoEditorElection')->second($election, $seconder1);
    $election = $c->model('AutoEditorElection')->second($election, $seconder2);
    $c->model('AutoEditorElection')->vote($election, $voter1, $ELECTION_VOTE_NO);
    $email_transport->clear_deliveries;

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_OPEN );

    $c->sql->do(q(UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'));

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_REJECTED );

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    my $email_body = $email->object->body_str;
    like($email_body, qr{Voting in this election is now closed: the proposal to make\s+noob1 an auto-editor was declined});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $candidate = $c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

test 'Cant second' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $c->model('Editor')->get_by_name('noob2');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $c->model('Editor')->get_by_name('autoeditor3');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok exception { $c->model('AutoEditorElection')->second($election, $proposer); };
    ok exception { $c->model('AutoEditorElection')->second($election, $not_autoeditor); };
    $c->model('AutoEditorElection')->second($election, $seconder1);
    ok exception { $c->model('AutoEditorElection')->second($election, $seconder1); };
    $c->model('AutoEditorElection')->cancel($election, $proposer);
    ok exception { $c->model('AutoEditorElection')->second($election, $seconder2); };
};

test 'Cant nominate' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $c->model('Editor')->get_by_name('noob2');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');

    ok exception { $c->model('AutoEditorElection')->nominate($candidate, $not_autoeditor); };
    ok exception { $c->model('AutoEditorElection')->nominate($proposer, $proposer); };
};

test 'Cant cancel' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $c->model('Editor')->get_by_name('noob2');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');
    my $autoeditor = $c->model('Editor')->get_by_name('autoeditor2');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok exception { $c->model('AutoEditorElection')->cancel($election, $not_autoeditor); };
    ok exception { $c->model('AutoEditorElection')->cancel($election, $autoeditor); };
};

test 'Cant vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $c->model('Editor')->get_by_name('noob2');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $c->model('Editor')->get_by_name('autoeditor3');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    $c->model('AutoEditorElection')->second($election, $seconder1);
    $c->model('AutoEditorElection')->second($election, $seconder2);

    ok exception { $c->model('AutoEditorElection')->vote($election, $proposer, $ELECTION_VOTE_YES); };
    ok exception { $c->model('AutoEditorElection')->vote($election, $seconder1, $ELECTION_VOTE_YES); };
    ok exception { $c->model('AutoEditorElection')->vote($election, $seconder2, $ELECTION_VOTE_YES); };
    ok exception { $c->model('AutoEditorElection')->vote($election, $not_autoeditor, $ELECTION_VOTE_YES); };
};

test 'Timeout' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    $email_transport->clear_deliveries;

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_SECONDER_1 );

    $c->sql->do(q(UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'));

    $c->model('AutoEditorElection')->try_to_close();
    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_REJECTED );

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    my $email_body = $email->object->body_str;
    like($email_body, qr{This election has been cancelled, because two seconders could not be\s+found within the allowed time \(1 week\)});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $candidate = $c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

test 'Cancel' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+autoeditor_election');

    my $candidate = $c->model('Editor')->get_by_name('noob1');
    my $proposer = $c->model('Editor')->get_by_name('autoeditor1');

    my $election = $c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );
    is( $election->status, $ELECTION_SECONDER_1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    $email_transport->clear_deliveries;

    $c->model('AutoEditorElection')->cancel($election, $proposer);

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    my $email_body = $email->object->body_str;
    like($email_body, qr{This election has been cancelled by the proposer \(autoeditor1\)});
    like($email_body, qr{https://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References header is correct');
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, 'Message-id header has correct format');
    $email_transport->clear_deliveries;

    $election = $c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_CANCELLED );

    $candidate = $c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

1;
