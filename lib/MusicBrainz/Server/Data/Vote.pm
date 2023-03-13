package MusicBrainz::Server::Data::Vote;
use Moose;
use namespace::autoclean;

use List::AllUtils qw( any sum );
use Carp qw( confess );
use MusicBrainz::Server::Data::Utils qw( map_query placeholders );
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Translation qw( l lp );
use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Types qw( VoteOption );

extends 'MusicBrainz::Server::Data::Entity';

sub _columns
{
    return 'id, editor, edit, vote_time, vote, superseded';
}

sub _table
{
    return 'vote';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Vote';
}

sub _column_mapping
{
    return {
        editor_id => 'editor',
        edit_id => 'edit',
        vote => 'vote',
        vote_time => 'vote_time',
        superseded => 'superseded',
    };
}

sub enter_votes
{
    my ($self, $editor, @votes) = @_;

    # Filter any invalid votes
    @votes = grep { VoteOption->check($_->{vote}) } @votes;

    return unless @votes;

    my $query;
    Sql::run_in_transaction(sub {
        $self->sql->do('LOCK vote IN SHARE ROW EXCLUSIVE MODE');

        # Deal with votes on closed or own edits, by blocked users, etc.
        my @edit_ids = map { $_->{edit_id} } @votes;
        my $edits = $self->c->model('Edit')->get_by_ids(@edit_ids);
        @votes = grep { defined $edits->{ $_->{edit_id} } } @votes;
        if (any { $_->{vote} == $VOTE_APPROVE && !$edits->{ $_->{edit_id} }->editor_may_approve($editor) } @votes) {
            # not sufficient to filter the vote because the actual approval is happening elsewhere
            confess 'Unauthorized editor ' . $editor->id . ' tried to approve edit #' . $_->{edit_id};
        }
        @votes = grep {
            $_->{vote} == $VOTE_APPROVE || $edits->{ $_->{edit_id} }->editor_may_vote_on_edit($editor)
        } @votes;

        return unless @votes;

        my $editor_id = $editor->id;

        # Also filter duplicate votes
        my $current_votes = $self->sql->select_list_of_hashes(
            'SELECT vote, edit FROM vote ' .
            'WHERE superseded = FALSE AND editor = ? AND edit IN (' .
              placeholders(@edit_ids) . ')',
            $editor_id, @edit_ids);
        my %current_votes = map { $_->{edit} => $_->{vote} } @$current_votes;

        # Filter votes where the user has either not voted before, or previously casted a different vote
        @votes = grep {
            !exists $current_votes{$_->{edit_id}} || $current_votes{$_->{edit_id}} != $_->{vote}
        } @votes;
        @edit_ids = map { $_->{edit_id} } @votes;

        return unless @votes;

        # Supersede any existing votes
        $query = 'UPDATE vote SET superseded = TRUE' .
                 ' WHERE editor = ? AND superseded = FALSE AND edit IN (' . placeholders(@edit_ids) . ')';
        $self->sql->do($query, $editor_id, @edit_ids);

        # Select all edits which have more than 0 'no' votes already.
        $query = 'SELECT id FROM edit WHERE id IN (' . placeholders(@edit_ids) . ') ' .
                 'AND EXISTS (SELECT 1 FROM vote WHERE vote.edit = edit.id AND NOT vote.superseded AND vote.vote = ?)';
        my $no_voted = $self->sql->select_single_column_array($query, @edit_ids, $VOTE_NO);
        my %already_no_voted = map { $_ => 1 } @$no_voted;

        # Insert our new votes
        $query = 'INSERT INTO vote (editor, edit, vote) VALUES ';
        $query .= join q(, ), (('(?, ?, ?)') x @votes);
        $query .= ' RETURNING edit, vote';
        my $voted = $self->sql->select_list_of_hashes($query, map { $editor_id, $_->{edit_id}, $_->{vote} } @votes);
        my %edit_to_vote = map { $_->{edit} => $_->{vote} } @$voted;

        # Send out the emails for no votes
        my @email_extend_edit_ids = grep { $edit_to_vote{$_} == $VOTE_NO }
                             grep { !exists $already_no_voted{$_} } @edit_ids;

        if (@email_extend_edit_ids) {
            my $email = MusicBrainz::Server::Email->new( c => $self->c );
            my $editors = $self->c->model('Editor')->get_by_ids((map { $edits->{$_}->editor_id } @email_extend_edit_ids),
                                                                $editor_id);
            $self->c->model('Editor')->load_preferences(values %$editors);

            for my $edit_id (@email_extend_edit_ids) {
                my $edit = $edits->{ $edit_id };
                my $voter = $editors->{ $editor_id };
                my $editor = $editors->{ $edit->editor_id };
                $email->send_first_no_vote(edit_id => $edit_id, voter => $voter, editor => $editor )
                    if $editor->preferences->email_on_no_vote;
            }

            # Extend the expiration of no-voted edits where applicable
            $self->c->model('Edit')->extend_expiration_time(@email_extend_edit_ids);
        }

    }, $self->c->sql);
}

sub editor_statistics
{
    my ($self, $editor) = @_;

    my $base_query = 'SELECT vote, count(vote) AS count ' .
        'FROM vote ' .
        'WHERE NOT superseded AND editor = ? ';

    my $q_all_votes    = $base_query . 'GROUP BY vote';
    my $q_recent_votes = $base_query .
        q{ AND vote_time > NOW() - INTERVAL '28 day' } .
        ' GROUP BY vote';

    my $all_votes = map_query($self->c->sql, 'vote' => 'count', $q_all_votes, $editor->id);
    my $recent_votes = map_query($self->c->sql, 'vote' => 'count', $q_recent_votes, $editor->id);

    return [
        # Summarise for each vote type
        $self->summarize_votes($VOTE_YES, $all_votes, $recent_votes),
        $self->summarize_votes($VOTE_NO, $all_votes, $recent_votes),
        $self->summarize_votes($VOTE_ABSTAIN, $all_votes, $recent_votes),

        # Show Approve only if there are approves to be shown or if editor is an autoeditor
        $all_votes->{$VOTE_APPROVE} || $editor->is_auto_editor
            ? $self->summarize_votes($VOTE_APPROVE, $all_votes, $recent_votes)
            : (),

        # Add totals
        {
            name => l('Total'),
            recent => {
                count      => sum(values %$recent_votes) || 0,
            },
            all => {
                count      => sum(values %$all_votes) || 0,
            }
        }
    ]
}

sub summarize_votes
{
    my ($self, $vote_kind, $all_votes, $recent_votes) = @_;
    my %names = (
        $VOTE_ABSTAIN => lp('Abstain', 'vote'),
        $VOTE_NO => lp('No', 'vote'),
        $VOTE_YES => lp('Yes', 'vote'),
        $VOTE_APPROVE => lp('Approve', 'vote'),
    );

    return (
        {
            name    => $names{$vote_kind},
            recent  => {
                count      => $recent_votes->{$vote_kind} || 0,
                percentage => int(($recent_votes->{$vote_kind} || 0) / (sum(values %$recent_votes) || 1) * 100 + 0.5)
            },
            all     => {
                count      => ($all_votes->{$vote_kind} || 0),
                percentage => int(($all_votes->{$vote_kind} || 0) / (sum(values %$all_votes) || 1) * 100 + 0.5)
            }
        }
    )
}

sub load_for_edits
{
    my ($self, @edits) = @_;
    my %id_to_edit = map { $_->id => $_ } @edits;
    my @ids = keys %id_to_edit;
    return unless @ids; # nothing to do
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 WHERE edit IN (' . placeholders(@ids) . ')
                 ORDER BY vote_time';
    my @votes = $self->query_to_list($query, \@ids, sub {
        my ($model, $row) = @_;

        my $vote = $model->_new_from_row($row);
        my $edit = $id_to_edit{$vote->edit_id};
        $edit->add_vote($vote);
        $vote->edit($edit);
        $vote;
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
