package MusicBrainz::Server::EditQueue;

use Moose;
use Try::Tiny;
use DBDefs;
use MusicBrainz::Server::Constants qw( :expire_action :editor :edit_status );

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
    $STATUS_TOBEDELETED => 'to be deleted',
    $STATUS_DELETED => 'deleted',
    $STATUS_ERROR => 'error'
);

sub process_edits
{
    my ($self) = @_;

    $self->log->info("Edit queue processing starting\n");

    if (&DBDefs::DB_READ_ONLY) {
        $self->log->error("Can't work on a read-only database (DB_READ_ONLY is set)\n");
        return 0;
    }

    my $sql = $self->c->sql;

    $self->log->debug("Selecting open and to-be-deleted edit IDs\n");
    my $edit_ids = $sql->select_single_column_array("
        SELECT id FROM edit WHERE status IN (?, ?) ORDER BY id",
        $STATUS_OPEN, $STATUS_TOBEDELETED);

    my %stats;
    my $errors = 0;
    foreach my $edit_id (@$edit_ids) {
        try {
            my $action;
            Sql::run_in_transaction(sub {
                $action = $self->_process_edit($edit_id) || "no change"
            }, $sql);
            $stats{$action} += 1;
        }
        catch {
            my $err = $_;
            $errors += 1;
            $self->log->error("Error while processing edit #$edit_id: $err\n");
            return;
        };
    }

    if ($self->summary) {
        $self->log->info("Summary:\n");
        my @actions = sort { $a cmp $b } keys %stats;
        foreach my $action (@actions) {
            $self->log->info(sprintf "  %-20.20s %d\n", $action_name{$action}, $stats{$action});
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

    if ($edit->status == $STATUS_TOBEDELETED) {
        return $self->_process_tobedeleted_edit($edit);
    }

    if ($edit->status == $STATUS_OPEN) {
        return $self->_process_open_edit($edit);
    }

    $self->log->warning("Edit #$edit_id is no longer open\n");
    return undef;
}

sub _process_tobedeleted_edit
{
    my ($self, $edit) = @_;

    my $edit_id = $edit->id;
    $self->log->info("Deleting edit #$edit_id\n");

    # Delete the edit.
    unless ($self->dry_run) {
        $self->c->model('Edit')->reject($edit, $STATUS_DELETED);
    }

    return $STATUS_DELETED;
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
                    text => "This edit failed because it affected high quality data and did not receive any votes."
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

    my $quality = $edit->quality;
    my $conditions = $edit->edit_conditions->{$quality};

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
        $self->log->debug("Unanimous yes\n");
        return $STATUS_APPLIED;
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

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
