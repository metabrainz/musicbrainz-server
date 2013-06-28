package MusicBrainz::Server::Data::Vote;
use Moose;
use namespace::autoclean;

use List::Util qw( sum );
use MusicBrainz::Server::Data::Utils qw(
    map_query
    placeholders
    query_to_list
);
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Translation qw( l ln );
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
    my ($self, $editor_id, @votes) = @_;
    return unless @votes;

    # Filter any invalid votes
    @votes = grep { VoteOption->check($_->{vote}) } @votes;

    my $query;
    Sql::run_in_transaction(sub {
        $self->sql->do('LOCK vote IN SHARE ROW EXCLUSIVE MODE');

        # Filter votes on edits that are open
        my @edit_ids = map { $_->{edit_id} } @votes;
        my $edits = $self->c->model('Edit')->get_by_ids(@edit_ids);
        @votes = grep {
            my $edit = $edits->{ $_->{edit_id} };
            defined $edit && $edit->is_open
        } @votes;

        # Filter out self-votes
        @votes = grep {
            $_->{vote} == $VOTE_APPROVE ||
            $editor_id != $edits->{ $_->{edit_id} }->editor_id
        } @votes;

        return unless @votes;

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
                 ' WHERE editor = ? AND superseded = FALSE AND edit IN (' . placeholders(@edit_ids) . ')'.
                 ' RETURNING edit, vote';
        my $superseded = $self->sql->select_list_of_hashes($query, $editor_id, @edit_ids);

        my %delta;
        # Change the vote count delta for any votes that were changed
        for my $s (@$superseded) {
            my $id = $s->{edit};
            --( $delta{ $id }->{no}  ) if $s->{vote} == $VOTE_NO;
            --( $delta{ $id }->{yes} ) if $s->{vote} == $VOTE_YES;
        }

        # Select all edits which have more than 0 'no' votes already.
        $query = 'SELECT id FROM edit WHERE id IN (' . placeholders(@edit_ids) . ') AND no_votes > 0';
        my $no_voted = $self->sql->select_single_column_array($query, @edit_ids);
        my %already_no_voted = map { $_ => 1 } @$no_voted;

        # Insert our new votes
        $query = 'INSERT INTO vote (editor, edit, vote) VALUES ';
        $query .= join ", ", (('(?, ?, ?)') x @votes);
        $query .= ' RETURNING edit, vote';
        my $voted = $self->sql->select_list_of_hashes($query, map { $editor_id, $_->{edit_id}, $_->{vote} } @votes);
        my %edit_to_vote = map { $_->{edit} => $_->{vote} } @$voted;

        # Change the vote count delta for any votes that were changed
        for my $s (@$voted) {
            my $id = $s->{edit};
            ++( $delta{ $id }->{no}  ) if $s->{vote} == $VOTE_NO;
            ++( $delta{ $id }->{yes} ) if $s->{vote} == $VOTE_YES;

            $query = 'UPDATE edit SET yes_votes = yes_votes + ?, no_votes = no_votes + ?' .
                     ' WHERE id = ?';
            $self->sql->do($query, $delta{ $id }->{yes} || 0, $delta{ $id }->{no} || 0, $id);
        }

        # Send out the emails for no votes
        my @email_extend_edit_ids = grep { $edit_to_vote{$_} == $VOTE_NO }
                             grep { !exists $already_no_voted{$_} } @edit_ids;
        my $email = MusicBrainz::Server::Email->new( c => $self->c );
        my $editors = $self->c->model('Editor')->get_by_ids((map { $edits->{$_}->editor_id } @email_extend_edit_ids),
                                                            $editor_id);
        $self->c->model('Editor')->load_preferences(values %$editors);

        for my $edit_id (@email_extend_edit_ids) {
            my $edit = $edits->{ $edit_id };
            my $voter = $editors->{ $editor_id  };
            my $editor = $editors->{ $edit->editor_id };
            $email->send_first_no_vote(edit_id => $edit_id, voter => $voter, editor => $editor )
                if $editor->preferences->email_on_no_vote;
        }

        # Extend the expiration of no-voted edits where applicable
        $self->c->model('Edit')->extend_expiration_time(@email_extend_edit_ids);

    }, $self->c->sql);
}

sub editor_statistics
{
    my ($self, $editor) = @_;

    my $base_query = "SELECT vote, count(vote) AS count " .
        "FROM vote " .
        "WHERE editor = ? ";

    my $q_all_votes    = $base_query . "GROUP BY vote";
    my $q_recent_votes = $base_query .
        " AND vote_time > NOW() - INTERVAL '28 day' " .
        " GROUP BY vote";

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
        $VOTE_ABSTAIN => l('Abstain'),
        $VOTE_NO => l('No'),
        $VOTE_YES => l('Yes'),
        $VOTE_APPROVE => l('Approve'),
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
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE edit IN (" . placeholders(@ids) . ")
                 ORDER BY vote_time";
    my @votes = query_to_list($self->c->sql, sub {
            my $vote = $self->_new_from_row(@_);
            my $edit = $id_to_edit{$vote->edit_id};
            $edit->add_vote($vote);
            $vote->edit($edit);

            return $vote
        }, $query, @ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;


=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
