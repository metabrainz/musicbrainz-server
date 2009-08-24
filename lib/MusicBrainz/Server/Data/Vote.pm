package MusicBrainz::Server::Data::Vote;
use Moose;

use Moose::Util::TypeConstraints qw( find_type_constraint );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use MusicBrainz::Server::Types qw( $VOTE_YES $VOTE_NO );

extends 'MusicBrainz::Server::Data::Entity';

sub _columns
{
    return 'id, editor, edit, votetime, vote, superseded';
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
        vote_time => 'votetime',
        superseded => 'superseded',
    };
}

sub enter_votes
{
    my ($self, $editor_id, @votes) = @_;
    return unless @votes;

    # Filter any invalid votes
    my $vote_tc = find_type_constraint('VoteOption');
    @votes = grep { $vote_tc->check($_->{vote}) } @votes;

    my $sql = Sql->new($self->c->raw_dbh);
    my $query;
    Sql::RunInTransaction(sub {
        $sql->Do('LOCK vote IN SHARE ROW EXCLUSIVE MODE');

        # Filter votes on edits that are open and were not created by the voter
        my $edits = $self->c->model('Edit')->get_by_ids(map { $_->{edit_id} } @votes);
        @votes = grep {
            my $edit = $edits->{ $_->{edit_id} };
            defined $edit && $edit->is_open && $edit->editor_id != $editor_id
        } @votes;

        return unless @votes;

        # Supersede any existing votes
        $query = 'UPDATE vote SET superseded = TRUE' .
                 ' WHERE editor = ? AND superseded = FALSE AND edit IN (' . placeholders(@votes) . ')'.
                 ' RETURNING edit, vote';
        my $superseded = $sql->SelectListOfHashes($query, $editor_id, map { $_->{edit_id} } @votes);

        my %delta;
        # Change the vote count delta for any votes that were changed
        for my $s (@$superseded) {
            my $id = $s->{edit};
            --( $delta{ $id }->{no}  ) if $s->{vote} == $VOTE_NO;
            --( $delta{ $id }->{yes} ) if $s->{vote} == $VOTE_YES;
        }

        $query = 'INSERT INTO vote (editor, edit, vote) VALUES ';
        $query .= join ", ", (('(?, ?, ?)') x @votes);
        $query .= ' RETURNING edit, vote';
        my $voted = $sql->SelectListOfHashes($query, map { $editor_id, $_->{edit_id}, $_->{vote} } @votes);

        # Change the vote count delta for any votes that were changed
        for my $s (@$voted) {
            my $id = $s->{edit};
            ++( $delta{ $id }->{no}  ) if $s->{vote} == $VOTE_NO;
            ++( $delta{ $id }->{yes} ) if $s->{vote} == $VOTE_YES;

            $query = 'UPDATE edit SET yesvotes = yesvotes + ?, novotes = novotes + ?' .
                     ' WHERE id = ?';
            $sql->Do($query, $delta{ $id }->{yes} || 0, $delta{ $id }->{no} || 0, $id);
        }
    }, $sql);
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
                 ORDER BY votetime";
    my @votes = query_to_list($self->c->raw_dbh, sub {
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
