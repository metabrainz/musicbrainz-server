package MusicBrainz::Server::Entity::AutoEditorElection;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( :election_status );

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
    isa => 'AutoEditorElectionStatus',
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
    isa => 'DateTime',
    is  => 'rw',
    coerce => 1
);

has 'votes' => (
    isa  => 'ArrayRef[AutoEditorElectionVote]',
    is   => 'rw',
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
our @STATUS_MAP = (
    [ $ELECTION_SECONDER_1  => 'Awaiting 1st seconder' ],
    [ $ELECTION_SECONDER_2  => 'Awaiting 2nd seconder' ],
    [ $ELECTION_OPEN        => 'Voting open since {date}' ],
    [ $ELECTION_ACCEPTED    => 'Accepted at {date}' ],
    [ $ELECTION_REJECTED    => 'Declined at {date}' ],
    [ $ELECTION_CANCELLED   => 'Cancelled at {date}' ],
);
our %STATUS_NAMES = map { @$_ } @STATUS_MAP;

sub status_name
{
    my ($self) = @_;

    return $STATUS_NAMES{$self->status};
}

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

The current status of this election, see L<MusicBrainz::Server::Types>
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
