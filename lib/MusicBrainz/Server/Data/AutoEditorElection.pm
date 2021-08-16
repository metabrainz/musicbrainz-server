package MusicBrainz::Server::Data::AutoEditorElection;
use Moose;
use namespace::autoclean;

use Readonly;
use MusicBrainz::Server::Entity::AutoEditorElection;
use MusicBrainz::Server::Entity::AutoEditorElectionVote;
use MusicBrainz::Server::Data::Utils qw( hash_to_row );
use MusicBrainz::Server::Constants qw( :election_status :election_vote );

extends 'MusicBrainz::Server::Data::Entity';

Readonly our $PROPOSAL_TIMEOUT => '1 week';
Readonly our $VOTING_TIMEOUT   => '1 week';

sub _table
{
    return 'autoeditor_election';
}

sub _columns
{
    return 'id, candidate, proposer, seconder_1, seconder_2, status,
        yes_votes, no_votes, propose_time, open_time, close_time';
}

sub _column_mapping
{
    return {
        id => 'id',
        candidate_id  => 'candidate',
        proposer_id => 'proposer',
        seconder_1_id => 'seconder_1',
        seconder_2_id => 'seconder_2',
        status => 'status',
        yes_votes => 'yes_votes',
        no_votes => 'no_votes',
        propose_time => 'propose_time',
        open_time => 'open_time',
        close_time => 'close_time',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::AutoEditorElection';
}

sub nominate
{
    my ($self, $candidate, $proposer) = @_;

    die 'Forbidden' unless $proposer->can_nominate($candidate);

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {

        $sql->do('LOCK TABLE autoeditor_election IN EXCLUSIVE MODE');

        my $id = $sql->select_single_value('
            SELECT id FROM ' . $self->_table . '
            WHERE candidate = ? AND status IN (?, ?, ?)',
            $candidate->id, $ELECTION_SECONDER_1, $ELECTION_SECONDER_2,
            $ELECTION_OPEN);
        return $self->_entity_class->new( id => $id )
            if defined $id;

        my $row = {
            candidate => $candidate->id,
            proposer => $proposer->id,
        };
        $id = $self->sql->insert_row($self->_table, $row, 'id');

        my $election = $self->get_by_id($id);
        $election->candidate($candidate);
        $election->proposer($proposer);

        $self->c->model('Email')->send_election_nomination($election);

        return $election;

    }, $sql);
}

sub second
{
    my ($self, $election, $seconder) = @_;

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {

        $election = $self->get_by_id_locked($election->id);

        die 'Forbidden' unless $election->can_second($seconder);

        my %update;
        if ($election->status == $ELECTION_SECONDER_1) {
            $update{status} = $ELECTION_SECONDER_2;
            $update{seconder_1} = $seconder->id;
        }
        elsif ($election->status == $ELECTION_SECONDER_2) {
            $update{status} = $ELECTION_OPEN;
            $update{seconder_2} = $seconder->id;
            $update{open_time} = DateTime->now();
        }

        $self->sql->update_row($self->_table, \%update, { id => $election->id });

        if ($update{status} == $ELECTION_OPEN) {
            $election = $self->get_by_id($election->id);
            $self->load_editors($election);
            $self->c->model('Email')->send_election_voting_open($election);
        }

        return $election;

    }, $sql);
}

sub cancel
{
    my ($self, $election, $proposer) = @_;

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {

        $election = $self->get_by_id_locked($election->id);

        die 'Forbidden' unless $election->can_cancel($proposer);

        my %update = (
            status      => $ELECTION_CANCELLED,
            close_time  => DateTime->now(),
        );
        $self->sql->update_row($self->_table, \%update, { id => $election->id });

        $self->load_editors($election);
        $self->c->model('Email')->send_election_canceled($election);

    }, $sql);
}

sub vote
{
    my ($self, $election, $voter, $vote) = @_;

    $vote += 0;
    die 'Invalid vote' if ($vote < -1 || $vote > 1);

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {

        $election = $self->get_by_id_locked($election->id);

        die 'Forbidden' unless $election->can_vote($voter);

        my $old_vote = $sql->select_single_row_hash('
            SELECT id, vote FROM autoeditor_election_vote
            WHERE autoeditor_election = ? AND voter = ?',
            $election->id, $voter->id);

        if (defined $old_vote && $old_vote->{vote} == $vote) {
            return; # no change
        }

        if (defined $old_vote) {
            $self->sql->update_row('autoeditor_election_vote', {
                vote                => $vote,
                vote_time           => DateTime->now(),
            }, { id => $old_vote->{id} });
        }
        else {
            $self->sql->insert_row('autoeditor_election_vote', {
                autoeditor_election => $election->id,
                voter               => $voter->id,
                vote                => $vote,
                vote_time           => DateTime->now(),
            });
        }

        my %update = (
            yes_votes   => $election->yes_votes,
            no_votes    => $election->no_votes,
        );

        if (defined $old_vote) {
            $update{yes_votes}-- if $old_vote->{vote} == $ELECTION_VOTE_YES;
            $update{no_votes}-- if $old_vote->{vote} == $ELECTION_VOTE_NO;
        }
        $update{yes_votes}++ if $vote == $ELECTION_VOTE_YES;
        $update{no_votes}++ if $vote == $ELECTION_VOTE_NO;

        if (%update) {
            $self->sql->update_row($self->_table, \%update, { id => $election->id });
        }

    }, $sql);
}

sub try_to_close
{
    my ($self) = @_;

    my $sql = $self->sql;
    return Sql::run_in_transaction(sub {

        $sql->do('LOCK TABLE autoeditor_election IN EXCLUSIVE MODE');

        $self->_try_to_close_timeout();
        $self->_try_to_close_voting();

    }, $sql);
}

sub _try_to_close_timeout
{
    my ($self) = @_;

    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 WHERE now() - propose_time > INTERVAL ? AND
                       status IN (?, ?)';
    my @elections = $self->query_to_list(
        $query,
        [$PROPOSAL_TIMEOUT, $ELECTION_SECONDER_1, $ELECTION_SECONDER_2],
    );

    for my $election (@elections) {
        my %update = ( status => $ELECTION_REJECTED );
        $self->sql->update_row($self->_table, \%update, { id => $election->id });
        $self->load_editors($election);
        $self->c->model('Email')->send_election_timeout($election);
    }
}

sub _try_to_close_voting
{
    my ($self) = @_;

    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 WHERE now() - propose_time > INTERVAL ? AND
                       status = ?';
    my @elections = $self->query_to_list(
        $query,
        [$VOTING_TIMEOUT, $ELECTION_OPEN],
    );

    for my $election (@elections) {
        my %update = (
            status      => $election->yes_votes > $election->no_votes
                                ? $ELECTION_ACCEPTED
                                : $ELECTION_REJECTED,
            close_time  => DateTime->now(),
        );
        $self->sql->update_row($self->_table, \%update, { id => $election->id });
        if ($update{status} == $ELECTION_ACCEPTED) {
            $self->c->model('Editor')->make_autoeditor($election->candidate_id);
            $self->load_editors($election);
            $self->c->model('Email')->send_election_accepted($election);
        }
        else {
            $self->load_editors($election);
            $self->c->model('Email')->send_election_rejected($election);
        }
    }
}

sub load_editors
{
    my ($self, @elections) = @_;

    my @ids = grep { defined } map {
            $_->candidate_id,
            $_->proposer_id,
            $_->seconder_1_id,
            $_->seconder_2_id,
            map { $_->voter_id } $_->all_votes
        } @elections;

    my $editors = $self->c->model('Editor')->get_by_ids(@ids);

    for my $election (@elections) {
        $election->candidate($editors->{$election->candidate_id});
        $election->proposer($editors->{$election->proposer_id});
        $election->seconder_1($editors->{$election->seconder_1_id})
            if defined $election->seconder_1_id;
        $election->seconder_2($editors->{$election->seconder_2_id})
            if defined $election->seconder_2_id;
        for my $vote ($election->all_votes) {
            $vote->voter($editors->{$vote->voter_id});
        }
    }
}

sub load_votes
{
    my ($self, $election) = @_;

    my $sql = $self->c->sql;
    my $query = 'SELECT * FROM autoeditor_election_vote
                 WHERE autoeditor_election = ? ORDER BY vote_time';
    for my $row (@{ $self->sql->select_list_of_hashes($query, $election->id) }) {
        my $vote = MusicBrainz::Server::Entity::AutoEditorElectionVote->new({
            election_id => $election->id,
            election    => $election,
            voter_id    => $row->{voter},
            vote_time   => $row->{vote_time},
            vote        => $row->{vote},
        });
        $election->add_vote($vote);
    }
}

sub get_all {
    my ($self) = @_;

    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 ORDER BY propose_time DESC';
    $self->query_to_list($query);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
