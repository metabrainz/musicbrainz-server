package MusicBrainz::Server::Entity::AutoEditorElection;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( :election_status );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Types qw( DateTime AutoEditorElectionStatus );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Entity';

has [qw( candidate proposer seconder_1 seconder_2 )] => (
    isa => 'Editor',
    is  => 'rw',
);

has [qw( candidate_id proposer_id seconder_1_id seconder_2_id)] => (
    isa => 'Int',
    is  => 'rw',
);

has 'status' => (
    isa => AutoEditorElectionStatus,
    is  => 'rw'
);

has 'yes_votes' => (
    traits    => [ 'Counter' ],
    isa       => 'Int',
    is        => 'rw',
    handles   => {
        _inc_yes => 'inc'
    },
    default   => 0,
);

has 'no_votes' => (
    traits    => [ 'Counter' ],
    isa       => 'Int',
    is        => 'rw',
    handles   => {
        _inc_no => 'inc'
    },
    default   => 0,
);

has [qw( propose_time open_time close_time )] => (
    isa => DateTime,
    is  => 'rw',
    coerce => 1
);

has 'votes' => (
    isa  => 'ArrayRef[AutoEditorElectionVote]',
    is   => 'rw',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_votes => 'elements',
        add_vote => 'push',
        clear_votes => 'clear'
    }
);

sub is_open
{
    my $self = shift;
    return $self->status == $ELECTION_OPEN;
}

sub is_pending
{
    my $self = shift;
    return $self->status == $ELECTION_SECONDER_1 ||
           $self->status == $ELECTION_SECONDER_2;
}

sub is_closed
{
    my $self = shift;
    return $self->status == $ELECTION_ACCEPTED ||
           $self->status == $ELECTION_REJECTED ||
           $self->status == $ELECTION_CANCELLED;
}

# XXX not translatable
our %STATUS_NAMES = (
    $ELECTION_SECONDER_1  => N_lp('Awaiting 1st seconder', 'autoeditor election status'),
    $ELECTION_SECONDER_2  => N_lp('Awaiting 2nd seconder', 'autoeditor election status'),
    $ELECTION_OPEN        => N_lp('Voting open since {date}', 'autoeditor election status'),
    $ELECTION_ACCEPTED    => N_lp('Accepted at {date}', 'autoeditor election status'),
    $ELECTION_REJECTED    => N_lp('Declined at {date}', 'autoeditor election status'),
    $ELECTION_CANCELLED   => N_lp('Cancelled at {date}', 'autoeditor election status'),
);

our %SHORT_STATUS_NAMES = (
    $ELECTION_SECONDER_1  => N_lp('Awaiting 1st seconder', 'autoeditor election status (short)'),
    $ELECTION_SECONDER_2  => N_lp('Awaiting 2nd seconder', 'autoeditor election status (short)'),
    $ELECTION_OPEN        => N_lp('Voting open', 'autoeditor election status (short)'),
    $ELECTION_ACCEPTED    => N_lp('Accepted', 'autoeditor election status (short)'),
    $ELECTION_REJECTED    => N_lp('Declined', 'autoeditor election status (short)'),
    $ELECTION_CANCELLED   => N_lp('Cancelled', 'autoeditor election status (short)'),
);

sub status_name
{
    my ($self) = @_;

    return $STATUS_NAMES{$self->status};
}

sub status_name_short
{
    my ($self) = @_;

    return $SHORT_STATUS_NAMES{$self->status};
}

sub can_vote
{
    my ($self, $editor) = @_;

    return 0 unless $self->is_open;
    return 0 unless $editor->is_auto_editor;

    return 0 if $editor->is_bot;
    return 0 if $self->candidate_id == $editor->id;
    return 0 if $self->proposer_id == $editor->id;
    return 0 if $self->seconder_1_id == $editor->id;
    return 0 if $self->seconder_2_id == $editor->id;

    return 1;
}

sub can_second
{
    my ($self, $editor) = @_;

    return 0 unless $self->is_pending;
    return 0 unless $editor->is_auto_editor;

    return 0 if $editor->is_bot;
    return 0 if $self->candidate_id == $editor->id;
    return 0 if $self->proposer_id == $editor->id;
    return 0 if defined $self->seconder_1_id &&
                $self->seconder_1_id == $editor->id;
    return 0 if defined $self->seconder_2_id &&
                $self->seconder_2_id == $editor->id;

    return 1;
}

sub can_cancel
{
    my ($self, $editor) = @_;

    return !$self->is_closed && $self->proposer_id == $editor->id;
}

sub current_expiration_time
{
    my ($self) = @_;
    return $self->open_time ?
           $self->open_time->clone->add( weeks => 1 ) :
           $self->propose_time->clone->add( weeks => 1 );
}

sub editor_to_json {
    my $editor = shift;
    return defined $editor ? $editor->TO_JSON : undef;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        candidate => editor_to_json($self->candidate),
        close_time => datetime_to_iso8601($self->close_time),
        current_expiration_time => datetime_to_iso8601($self->current_expiration_time),
        is_closed => boolean_to_json($self->is_closed),
        is_open => boolean_to_json($self->is_open),
        is_pending => boolean_to_json($self->is_pending),
        no_votes => $self->no_votes,
        proposer => editor_to_json($self->proposer),
        propose_time => datetime_to_iso8601($self->propose_time),
        open_time => datetime_to_iso8601($self->open_time),
        seconder_1 => editor_to_json($self->seconder_1),
        seconder_2 => editor_to_json($self->seconder_2),
        status_name => $self->status_name,
        status_name_short => $self->status_name_short,
        votes => to_json_array($self->votes),
        yes_votes => $self->yes_votes,
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Entity::AutoEditorElection - an auto-editor
election

=head1 DESCRIPTION

MusicBrainz allows certain editors to become auto-editors via an
elective process, from other members of the community. This entity
represents one of these elections

=head1 ATTRIBUTES

=head2 candidate

The editor proposed to become an auto-editor

=head2 proposer, seconder_1, seconder_2

The editor's who proposed and seconded this election, respectively.
The latter 2 may be undef.

=head2 status

The current status of this election, see L<MusicBrainz::Server::Constants>
for possible values.

=head2 yes_votes, no_votes

The amount of yes and no votes this election has received, respectively.

=head2 propose_time, open_time, close_time

The time this election was proposed, opened for voting and closed.
open_time and close_time my be undef, depending on the status of the
election.

=head2 votes

A list of all votes cast in this election.

=head1 METHODS

=head2 Status helpers

=head3 is_open

Check if this election is open for voting

=head3 is_closed

Check if this election has been closed

=head3 is_pending

Check if this election is waiting for other editors to second it.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
