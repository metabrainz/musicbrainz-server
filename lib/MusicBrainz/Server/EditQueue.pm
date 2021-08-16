package MusicBrainz::Server::EditQueue;

use Moose;
use DBDefs;
use MusicBrainz::Errors qw( capture_exceptions );
use MusicBrainz::Server::Constants qw( :expire_action :editor :edit_status :vote $REQUIRED_VOTES $MINIMUM_RESPONSE_PERIOD $MINIMUM_VOTING_PERIOD );
use DateTime::Format::Pg;

use aliased 'MusicBrainz::Server::Entity::Editor';

has 'c' => (
    is => 'ro',
    isa => 'Object',
    required => 1
);

has 'log' => (
    is => 'ro',
    isa => 'Object',
    default => sub { shift->c->log }
);

has 'dry_run' => (
    is => 'ro',
    isa => 'Bool',
    default => 0
);

has 'summary' => (
    is => 'ro',
    isa => 'Bool',
    default => 0
);

my %action_name = (
    $STATUS_OPEN => 'open',
    $STATUS_APPLIED => 'applied',
    $STATUS_FAILEDVOTE => 'failed vote',
    $STATUS_FAILEDDEP => 'failed dep',
    $STATUS_FAILEDPREREQ => 'failed prereq',
    $STATUS_NOVOTES => 'no votes',
    $STATUS_DELETED => 'deleted',
    $STATUS_ERROR => 'error'
);

sub process_edits
{
    my ($self) = @_;

    $self->log->info("Edit queue processing starting\n");

    if (DBDefs->DB_READ_ONLY) {
        $self->log->error("Can't work on a read-only database (DB_READ_ONLY is set)\n");
        return 0;
    }

    my $sql = $self->c->sql;

    $self->log->debug("Selecting eligible edit IDs\n");
    my $interval = DateTime::Format::Pg->format_interval($MINIMUM_RESPONSE_PERIOD);
    my $edit_ids = $sql->select_single_column_array('
        SELECT id
          FROM edit
               LEFT JOIN (
                 SELECT edit,
                        MIN(CASE WHEN vote = ? THEN vote_time ELSE NULL END) AS first_no_vote,
                        SUM(CASE WHEN vote = ? THEN 1 ELSE 0 END) AS yes_votes,
                        SUM(CASE WHEN vote = ? THEN 1 ELSE 0 END) AS no_votes
                   FROM vote
                  WHERE NOT superseded
                  GROUP BY edit
               ) vote_info ON edit.id = vote_info.edit
          WHERE status = ?
            AND (expire_time < now() OR
                 (vote_info.yes_votes >= ? AND vote_info.no_votes = 0) OR
                 (vote_info.no_votes >= ? AND vote_info.yes_votes = 0 AND vote_info.first_no_vote < NOW() - interval ?))
          ORDER BY id',
        $VOTE_NO, $VOTE_YES, $VOTE_NO,
        $STATUS_OPEN, $REQUIRED_VOTES, $REQUIRED_VOTES, $interval);

    my %stats;
    my $errors = 0;
    foreach my $edit_id (@$edit_ids) {
        capture_exceptions(sub {
            my $action;
            Sql::run_in_transaction(sub {
                $action = $self->_process_edit($edit_id) || 'no change'
            }, $sql);
            $stats{$action} += 1;
        }, sub {
            my $err = shift;
            $errors += 1;
            $self->log->error("Error while processing edit #$edit_id: $err\n");
            return;
        });
    }

    if ($self->summary) {
        $self->log->info("Summary:\n");
        my @actions = sort { $a cmp $b } keys %stats;
        foreach my $action (@actions) {
            $self->log->info(sprintf "  %-20.20s %d\n", $action_name{$action} // '(no action)', $stats{$action});
        }
    }

    $self->log->info("Edit queue processing completed\n");

    return 3 if $errors;
    return 0;
}

sub _process_edit
{
    my ($self, $edit_id) = @_;

    my $edit = $self->c->model('Edit')->get_by_id_and_lock($edit_id);

    if (!defined $edit) {
        $self->log->warning("Can't load data and/or get exclusive lock for edit #$edit_id\n");
        return undef;
    }

    $self->log->debug("Evaluating edit #$edit_id\n");

    $self->c->model('Vote')->load_for_edits($edit);

    if ($edit->status == $STATUS_OPEN) {
        return $self->_process_open_edit($edit);
    }

    $self->log->warning("Edit #$edit_id is no longer open\n");
    return undef;
}

sub _process_open_edit
{
    my ($self, $edit) = @_;

    my $edit_id = $edit->id;

    # Determine what to do with the edit
    my $status = $self->_determine_new_status($edit);

    # Nothing to do
    return unless defined $status;

    # Accept or reject the edit
    if ($status == $STATUS_APPLIED) {
        $self->log->debug("Applying edit #$edit_id\n");
        unless ($self->dry_run) {
            $self->c->model('Edit')->accept($edit);
        }
    }
    elsif ($status == $STATUS_FAILEDVOTE) {
        $self->log->debug("Denying edit #$edit_id\n");
        unless ($self->dry_run) {
            $self->c->model('Edit')->reject($edit, $status);
        }
    }
    elsif ($status == $STATUS_NOVOTES) {
        $self->log->debug("Denying edit #$edit_id for no votes\n");
        unless ($self->dry_run) {
            $self->c->model('EditNote')->add_note(
                $edit->id,
                {
                    editor_id => $EDITOR_MODBOT,
                    text => 'This edit failed because it affected high quality data and did not receive any votes.'
                }
            );
            $self->c->model('Edit')->reject($edit, $status);
        }
    }
    else {
        die "Unknown status returned ($status), don't know what to do.";
    }

    return $status;
}

sub _determine_new_status
{
    my ($self, $edit) = @_;

    my $yes_votes = $edit->yes_votes;
    my $no_votes = $edit->no_votes;

    my $conditions = $edit->edit_conditions;

    # Let's deal with expired edits first
    if ($edit->is_expired) {

        # Have there been any (non-abstaining) votes?
        if ($yes_votes or $no_votes) {
            # Are there more yes votes than no votes?
            if ($yes_votes > $no_votes) {
                $self->log->debug("Expired and approved\n");
                return $STATUS_APPLIED;
            }
            else {
                $self->log->debug("Expired and voted down\n");
                return $STATUS_FAILEDVOTE;
            }
        }

        # Follow edit's default expire action
        if ($conditions->{expire_action} == $EXPIRE_ACCEPT) {
            $self->log->debug("Expired and implicitly accepted\n");
            return $STATUS_APPLIED;
        }
        if ($conditions->{expire_action} == $EXPIRE_REJECT &&
                $yes_votes + $no_votes == 0) {
            $self->log->debug("Expired and rejected because of no votes\n");
            return $STATUS_NOVOTES;
        }
        if ($conditions->{expire_action} == $EXPIRE_REJECT) {
            $self->log->debug("Expired and implicitly rejected\n");
            return $STATUS_FAILEDVOTE;
        }

        # Implicitly accept the edit
        $self->log->debug("Expired and implicitly accepted (fallback)\n");
        return $STATUS_APPLIED;
    }

    # Are the number of required unanimous votes present?
    if ($yes_votes >= $conditions->{votes} && $no_votes == 0) {
        my $created = $edit->created_time;
        my $now = DateTime->now( time_zone => $created->time_zone );
        if ($created + $MINIMUM_VOTING_PERIOD < $now
                || $edit->editor_may_approve(Editor->new_privileged)) {
            $self->log->debug("Unanimous yes\n");
            return $STATUS_APPLIED;
        }
    }

    # Are the number of required unanimous votes present?
    if ($no_votes >= $conditions->{votes} && $yes_votes == 0) {
        $self->log->debug("Unanimous no\n");
        return $STATUS_FAILEDVOTE;
    }

    # No condition for this edit triggered. Leave it alone
    $self->log->debug("No change\n");
    return undef;
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
