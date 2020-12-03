package MusicBrainz::Server::Entity::AutoEditorElectionVote;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( :election_vote );
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Types qw( VoteOption DateTime );

extends 'MusicBrainz::Server::Entity';

has 'election' => (
    isa => 'AutoEditorElection',
    is  => 'rw',
);

has 'voter' => (
    isa => 'Editor',
    is  => 'rw',
);

has [qw( election_id voter_id )] => (
    isa => 'Int',
    is  => 'rw'
);

has 'vote_time' => (
    isa => DateTime,
    is  => 'rw',
    coerce => 1,
);

has 'vote' => (
    isa => VoteOption,
    is  => 'rw'
);

our %VOTE_NAMES = (
    $ELECTION_VOTE_YES      => 'Yes',
    $ELECTION_VOTE_NO       => 'No',
    $ELECTION_VOTE_ABSTAIN  => 'Abstain',
);

sub vote_name
{
    my ($self) = @_;

    return $VOTE_NAMES{$self->vote};
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        vote_name => $self->vote_name,
        voter => (defined $self->voter ? $self->voter->TO_JSON : undef),
        vote_time => datetime_to_iso8601($self->vote_time),
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Entity::AutoEditorElectionVote - a vote on an
auto-editor election

=head1 DESCRIPTION

This represents a single editors vote cast on an auto-editor election.

=head1 ATTRIBUTES

=head2 election

The election this vote is cast on

=head2 editor

The editor who cast the vote

=head2 vote

The vote. See L<MusicBrainz::Server::Constants/VoteOption>.

=head2 vote_time

The time the vote was registered

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
