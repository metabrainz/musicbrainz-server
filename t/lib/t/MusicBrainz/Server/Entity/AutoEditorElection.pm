package t::MusicBrainz::Server::Entity::AutoEditorElection;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::AutoEditorElection;
use MusicBrainz::Server::Entity::AutoEditorElectionVote;

use MusicBrainz::Server::Constants qw( :election_status :vote );
use MusicBrainz::Server::Entity::Editor;

=head1 DESCRIPTION

This test checks autoeditor election status and permission methods.

=cut

test 'AutoEditorElection has the expected attributes' => sub {
    my $election = MusicBrainz::Server::Entity::AutoEditorElection->new();
    ok(defined $election, 'Constructor returns defined election');
    isa_ok($election, 'MusicBrainz::Server::Entity::AutoEditorElection');
    has_attribute_ok($election, $_) for qw(
        id
        candidate proposer
        seconder_1
        seconder_2
        status
        yes_votes
        no_votes
        propose_time
        close_time
        open_time
    );
};

test 'Election status methods return the expected value' => sub {
    my $election = MusicBrainz::Server::Entity::AutoEditorElection->new();

    $election->status($ELECTION_SECONDER_1);
    ok(
        !$election->is_open,
        'Election is not yet marked as open when awaiting first seconder',
    );
    ok(
        $election->is_pending,
        'Election is correctly marked as pending when awaiting first seconder',
    );

    $election->status($ELECTION_SECONDER_2);
    ok(
        !$election->is_open,
        'Election is not yet marked as open when awaiting second seconder',
    );
    ok(
        $election->is_pending,
        'Election is correctly marked as pending when awaiting second seconder',
    );

    $election->status($ELECTION_OPEN);
    ok(
        $election->is_open,
        'Election is correctly marked as open when open status is set',
    );

    $election->status($ELECTION_ACCEPTED);
    ok(
        $election->is_closed,
        'Election is correctly marked as closed once the nominee is accepted',
    );

    $election->status($ELECTION_REJECTED);
    ok(
        $election->is_closed,
        'Election is correctly marked as closed once the nominee is rejected',
    );

    $election->status($ELECTION_CANCELLED);
    ok(
        $election->is_closed,
        'Election is correctly marked as closed if it has been cancelled',
    );
    is(
        $election->status_name,
        'Cancelled at {date}',
        'status_name returns the expected string',
    );
    is(
        $election->status_name_short,
        'Cancelled',
        'status_name_short returns the expected string',
    );
};

test 'Election voting permissions work as expected' => sub {
    my $election = MusicBrainz::Server::Entity::AutoEditorElection->new();
    my $boring_editor = MusicBrainz::Server::Entity::Editor->new(id => 42);
    my $candidate = MusicBrainz::Server::Entity::Editor->new(
        id => 43,
        privileges => 1, # Marked as autoeditor for testing failsafes
    );
    $election->candidate_id($candidate->id);
    my $proposer = MusicBrainz::Server::Entity::Editor->new(
        id => 44,
        privileges => 1,
    );
    $election->proposer_id($proposer->id);
    my $seconder = MusicBrainz::Server::Entity::Editor->new(
        id => 45,
        privileges => 1,
    );
    $election->seconder_1_id($seconder->id);
    my $autoeditor = MusicBrainz::Server::Entity::Editor->new(
        id => 46,
        privileges => 1,
    );
    my $bot = MusicBrainz::Server::Entity::Editor->new(
        id => 47,
        privileges => 3,
    );

    note('Election is set as awaiting first seconder');
    $election->status($ELECTION_SECONDER_1);
    ok(
        !$election->can_second($boring_editor),
        'Non-autoeditor cannot second even in seconding phase',
    );
    ok(
        !$election->can_second($candidate),
        'Candidate cannot second even in seconding phase',
    );
    ok(
        !$election->can_second($proposer),
        'Proposer cannot second even in seconding phase',
    );
    ok(
        !$election->can_second($seconder),
        'Existing seconder cannot second again',
    );
    ok(
        $election->can_second($autoeditor),
        'Non-involved autoeditor can second in seconding phase',
    );
    ok(
        !$election->can_vote($autoeditor),
        'Non-involved autoeditor cannot vote in seconding phase',
    );
    ok(
        !$election->can_second($bot),
        'Bot account cannot second even in seconding phase',
    );
    ok(
        $election->can_cancel($proposer),
        'Proposer can cancel the election in seconding phase',
    );
    ok(
        !$election->can_cancel($seconder),
        'Seconder cannot cancel the election',
    );

    # Set a (fake) second seconder to avoid undef warning in can_vote
    $election->seconder_2_id(666);

    note('Election is set as ready for voting');
    $election->status($ELECTION_OPEN);
    ok(
        !$election->can_vote($boring_editor),
        'Non-autoeditor cannot vote even in voting phase',
    );
    ok(
        !$election->can_vote($candidate),
        'Candidate cannot vote even in voting phase',
    );
    ok(
        !$election->can_vote($proposer),
        'Proposer cannot vote even in voting phase',
    );
    ok(
        !$election->can_vote($seconder),
        'Seconder cannot  vote even in voting phase',
    );
    ok(
        $election->can_vote($autoeditor),
        'Non-involved autoeditor can vote in voting phase',
    );
    ok(
        !$election->can_second($autoeditor),
        'Non-involved autoeditor cannot second in voting phase',
    );
    ok(
        !$election->can_vote($bot),
        'Bot account cannot vote even in voting phase',
    );
    ok(
        $election->can_cancel($proposer),
        'Proposer can cancel the election in voting phase',
    );

    note('Election is set as closed and accepted');
    $election->status($ELECTION_ACCEPTED);
    ok(
        !$election->can_vote($autoeditor),
        'Non-involved autoeditor cannot vote after the election closes',
    );
    ok(
        !$election->can_second($autoeditor),
        'Non-involved autoeditor cannot second after the election closes',
    );
    ok(
        !$election->can_cancel($proposer),
        'Proposer cannot cancel the election after it closes',
    );
};
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
