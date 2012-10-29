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

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $test->c->model('Editor')->get_by_name('autoeditor4');
    my $voter2 = $test->c->model('Editor')->get_by_name('autoeditor5');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{A new candidate has been put forward for autoeditor status});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    like($email->get_body, qr{Candidate:\s+noob1});
    like($email->get_body, qr{Proposer:\s+autoeditor1});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_SECONDER_1 );

    $election = $test->c->model('AutoEditorElection')->second($election, $seconder1);
    ok( $election );

    is($email_transport->delivery_count, 0);

    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_SECONDER_2 );

    $election = $test->c->model('AutoEditorElection')->second($election, $seconder2);
    ok( $election );

    is($email_transport->delivery_count, 1);
    $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{Voting in this election is now open});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    like($email->get_body, qr{Candidate:\s+noob1});
    like($email->get_body, qr{Proposer:\s+autoeditor1});
    like($email->get_body, qr{Seconder:\s+autoeditor2});
    like($email->get_body, qr{Seconder:\s+autoeditor3});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $test->c->model('AutoEditorElection')->vote($election, $voter1, $ELECTION_VOTE_YES);
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $test->c->model('AutoEditorElection')->vote($election, $voter2, $ELECTION_VOTE_NO);
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 1 );
    is( $election->status, $ELECTION_OPEN );

    $test->c->model('AutoEditorElection')->vote($election, $voter2, $ELECTION_VOTE_ABSTAIN);
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->seconder_1_id, $seconder1->id );
    is( $election->seconder_2_id, $seconder2->id );
    is( $election->yes_votes, 1 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_OPEN );

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_OPEN );

    $test->c->sql->do("UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'");

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_ACCEPTED );

    is($email_transport->delivery_count, 1);
    $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{Voting in this election is now closed: noob1 has been\s+accepted as an auto-editor});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $candidate = $test->c->model('Editor')->get_by_id($candidate->id);
    ok( $candidate->is_auto_editor );
};

test 'Rejected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $test->c->model('Editor')->get_by_name('autoeditor4');
    my $voter2 = $test->c->model('Editor')->get_by_name('autoeditor5');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;

    $election = $test->c->model('AutoEditorElection')->second($election, $seconder1);
    $election = $test->c->model('AutoEditorElection')->second($election, $seconder2);
    $test->c->model('AutoEditorElection')->vote($election, $voter1, $ELECTION_VOTE_NO);
    $email_transport->clear_deliveries;

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_OPEN );

    $test->c->sql->do("UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'");

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_REJECTED );

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{Voting in this election is now closed: the proposal to make\s+noob1 an auto-editor was declined});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $candidate = $test->c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

test 'Cant second' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $test->c->model('Editor')->get_by_name('noob2');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok exception { $test->c->model('AutoEditorElection')->second($election, $proposer); };
    ok exception { $test->c->model('AutoEditorElection')->second($election, $not_autoeditor); };
    $test->c->model('AutoEditorElection')->second($election, $seconder1);
    ok exception { $test->c->model('AutoEditorElection')->second($election, $seconder1); };
    $test->c->model('AutoEditorElection')->cancel($election, $proposer);
    ok exception { $test->c->model('AutoEditorElection')->second($election, $seconder2); };
};

test 'Cant nominate' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $test->c->model('Editor')->get_by_name('noob2');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');

    ok exception { $test->c->model('AutoEditorElection')->nominate($candidate, $not_autoeditor); };
    ok exception { $test->c->model('AutoEditorElection')->nominate($proposer, $proposer); };
};

test 'Cant cancel' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $test->c->model('Editor')->get_by_name('noob2');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $autoeditor = $test->c->model('Editor')->get_by_name('autoeditor2');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok exception { $test->c->model('AutoEditorElection')->cancel($election, $not_autoeditor); };
    ok exception { $test->c->model('AutoEditorElection')->cancel($election, $autoeditor); };
};

test 'Cant vote' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $not_autoeditor = $test->c->model('Editor')->get_by_name('noob2');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    $test->c->model('AutoEditorElection')->second($election, $seconder1);
    $test->c->model('AutoEditorElection')->second($election, $seconder2);

    ok exception { $test->c->model('AutoEditorElection')->vote($election, $proposer, $ELECTION_VOTE_YES); }; 
    ok exception { $test->c->model('AutoEditorElection')->vote($election, $seconder1, $ELECTION_VOTE_YES); }; 
    ok exception { $test->c->model('AutoEditorElection')->vote($election, $seconder2, $ELECTION_VOTE_YES); }; 
    ok exception { $test->c->model('AutoEditorElection')->vote($election, $not_autoeditor, $ELECTION_VOTE_YES); }; 
};

test 'Timeout' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $test->c->model('Editor')->get_by_name('autoeditor4');
    my $voter2 = $test->c->model('Editor')->get_by_name('autoeditor5');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    $email_transport->clear_deliveries;

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_SECONDER_1 );

    $test->c->sql->do("UPDATE autoeditor_election SET propose_time = propose_time - INTERVAL '2 week'");

    $test->c->model('AutoEditorElection')->try_to_close();
    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->status, $ELECTION_REJECTED );

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{This election has been cancelled, because two seconders could not be\s+found within the allowed time \(1 week\)});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $candidate = $test->c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

test 'Cancel' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+autoeditor_election');

    my $candidate = $test->c->model('Editor')->get_by_name('noob1');
    my $proposer = $test->c->model('Editor')->get_by_name('autoeditor1');
    my $seconder1 = $test->c->model('Editor')->get_by_name('autoeditor2');
    my $seconder2 = $test->c->model('Editor')->get_by_name('autoeditor3');
    my $voter1 = $test->c->model('Editor')->get_by_name('autoeditor4');
    my $voter2 = $test->c->model('Editor')->get_by_name('autoeditor5');

    my $election = $test->c->model('AutoEditorElection')->nominate($candidate, $proposer);
    ok( $election );
    is( $election->id, 1 );
    is( $election->status, $ELECTION_SECONDER_1 );

    my $email_transport = MusicBrainz::Server::Email->get_test_transport;
    $email_transport->clear_deliveries;

    $test->c->model('AutoEditorElection')->cancel($election, $proposer);

    is($email_transport->delivery_count, 1);
    my $email = $email_transport->shift_deliveries->{email};
    is($email->get_header('Subject'), 'Autoeditor Election: noob1');
    like($email->get_body, qr{This election has been cancelled by the proposer \(autoeditor1\)});
    like($email->get_body, qr{http://[^/]+/election/${\ $election->id }});
    is($email->get_header('References'), sprintf('<autoeditor-election-%s@%s>', $election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL), "References header is correct");
    like($email->get_header('Message-Id'), qr{<autoeditor-election-1-\d+@.*>}, "Message-id header has correct format");
    $email_transport->clear_deliveries;

    $election = $test->c->model('AutoEditorElection')->get_by_id($election->id);
    ok( $election );
    is( $election->candidate_id, $candidate->id );
    is( $election->proposer_id, $proposer->id );
    is( $election->yes_votes, 0 );
    is( $election->no_votes, 0 );
    is( $election->status, $ELECTION_CANCELLED );

    $candidate = $test->c->model('Editor')->get_by_id($candidate->id);
    ok( !$candidate->is_auto_editor );
};

1;
