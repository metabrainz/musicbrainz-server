package MusicBrainz::Server::Data::AutoEditorElection;
use Moose;

use Readonly;
use MusicBrainz::Server::Entity::AutoEditorElection;
use MusicBrainz::Server::Entity::AutoEditorElectionVote;
use MusicBrainz::Server::Data::Utils qw( hash_to_row query_to_list );
use MusicBrainz::Server::Types qw( :election_status );

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

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {
       
        $sql->do("LOCK TABLE autoeditor_election IN EXCLUSIVE MODE");

        my $id = $sql->select_single_value("
            SELECT id FROM autoeditor_election
            WHERE candidate = ? AND status IN (?, ?, ?)",
            $candidate->id, $ELECTION_SECONDER_1, $ELECTION_SECONDER_2,
            $ELECTION_OPEN);
        return $self->_entity_class->new( id => $id )
            if defined $id;

        my $row = {
            candidate => $candidate->id,
            proposer => $proposer->id,
        };
        $id = $self->sql->insert_row($self->_table, $row, 'id');
        return $self->_entity_class->new( id => $id );

    }, $sql);
}

sub second
{
    my ($self, $election, $seconder) = @_;

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {
       
        my $query = "SELECT id, status, seconder_1, seconder_2
                     FROM autoeditor_election
                     WHERE id = ? FOR UPDATE";
        my $row = $sql->select_single_row_hash($query, $election->id);

        my %update;
        if ($row->{status} == $ELECTION_SECONDER_1 && !$row->{seconder_1}) {
            $update{status} = $ELECTION_SECONDER_2;
            $update{seconder_1} = $seconder->id;
        }
        elsif ($row->{status} == $ELECTION_SECONDER_2 && !$row->{seconder_2}) {
            $update{status} = $ELECTION_OPEN;
            $update{seconder_2} = $seconder->id;
            $update{open_time} = DateTime->now();
        }
        else {
            die 'Already seconded';
        }

        $self->sql->update_row($self->_table, \%update, { id => $election->id });

    }, $sql);
}

sub cancel
{
    my ($self, $election) = @_;

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {
       
        my $query = "SELECT id, status
                     FROM autoeditor_election
                     WHERE id = ? FOR UPDATE";
        my $row = $sql->select_single_row_hash($query, $election->id);

        if ($row->{status} != $ELECTION_SECONDER_1 &&
            $row->{status} != $ELECTION_SECONDER_2 &&
            $row->{status} != $ELECTION_OPEN) {
            die 'Not open';
        }

        my %update = (
            status      => $ELECTION_CANCELLED,
            close_time  => DateTime->now(),
        );
        $self->sql->update_row($self->_table, \%update, { id => $election->id });

    }, $sql);
}

sub vote
{
    my ($self, $election, $voter, $vote) = @_;

    $vote += 0;
    die 'Invalid vote' if ($vote < -1 || $vote > 1);

    my $sql = $self->c->sql;
    return Sql::run_in_transaction(sub {
       
        my $query = "SELECT id, status, seconder_1, seconder_2, yes_votes, no_votes
                     FROM autoeditor_election
                     WHERE id = ? FOR UPDATE";
        my $row = $sql->select_single_row_hash($query, $election->id);

        if ($row->{status} != $ELECTION_OPEN) {
            die 'Not open';
        }

        $self->sql->insert_row("autoeditor_election_vote", {
            autoeditor_election => $election->id,
            voter               => $voter->id,
            vote                => $vote,
        });

        my %update;
        if ($vote == -1) {
            $update{no_votes} = $row->{no_votes} + 1;
        }
        elsif ($vote == 1) {
            $update{yes_votes} = $row->{yes_votes} + 1;
        }
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
       
        $sql->do("LOCK TABLE autoeditor_election IN EXCLUSIVE MODE");

        $self->_try_to_close_timeout();
        $self->_try_to_close_voting();

    }, $sql);
}

sub _try_to_close_timeout
{
    my ($self) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE now() - propose_time > INTERVAL ? AND
                       status IN (?, ?)";
    my @elections = query_to_list($self->sql,
        sub { $self->_new_from_row(@_) }, $query,
        $PROPOSAL_TIMEOUT, $ELECTION_SECONDER_1,
        $ELECTION_SECONDER_2);

    for my $election (@elections) {
        my %update = ( status => $ELECTION_REJECTED );
        $self->sql->update_row($self->_table, \%update, { id => $election->id });
    }
}

sub _try_to_close_voting
{
    my ($self) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE now() - propose_time > INTERVAL ? AND
                       status = ?";
    my @elections = query_to_list($self->sql,
        sub { $self->_new_from_row(@_) }, $query,
        $VOTING_TIMEOUT, $ELECTION_OPEN);

    for my $election (@elections) {
        my %update = (
            status      => $election->yes_votes > $election->no_votes
                                ? $ELECTION_ACCEPTED
                                : $ELECTION_REJECTED,
            close_time  => DateTime->now(),
        );
        if ($update{status} == $ELECTION_ACCEPTED) {
            $self->c->model('Editor')->make_autoeditor($election->candidate_id);
        }
        $self->sql->update_row($self->_table, \%update, { id => $election->id });
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
    my $query = "SELECT * FROM autoeditor_election_vote
                 WHERE autoeditor_election = ? ORDER BY vote_time";
    $sql->select($query, $election->id);
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $vote = MusicBrainz::Server::Entity::AutoEditorElectionVote->new({
            election_id => $election->id,
            election    => $election,
            voter_id    => $row->{voter},
            vote_time   => $row->{vote_time},
            vote        => $row->{vote},
        });
        $election->add_vote($vote);
    }
    $sql->finish;
}

sub get_all
{
    my ($self) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 ORDER BY propose_time DESC";
    return query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                         $query);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
