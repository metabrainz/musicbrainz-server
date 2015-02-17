package MusicBrainz::Server::Types;

use strict;
use warnings;

use DateTime ();
use DateTime::Format::Pg;

use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( :quality :election_status :vote :edit_status );

use namespace::clean;

use MooseX::Types -declare => [
    qw( DateTime Time AutoEditorElectionStatus VoteOption EditStatus Quality )
];

class_type 'DateTime';

subtype DateTime, as 'DateTime';

coerce DateTime,
    from Str,
    via { DateTime::Format::Pg->parse_datetime($_) };

subtype Time, as 'DateTime';

coerce Time,
    from Str,
    via { DateTime::Format::Pg->parse_time($_) };

subtype AutoEditorElectionStatus,
    as Int,
    where { $_ >= $ELECTION_SECONDER_1 && $_ <= $ELECTION_CANCELLED };

subtype VoteOption,
    as Int,
    where { $_ >= $VOTE_ABSTAIN && $_ <= $VOTE_APPROVE };

subtype EditStatus,
    as Int,
    where { $_ >= $STATUS_OPEN && $_ <= $STATUS_DELETED };

subtype Quality,
    as Int,
    where { $_ >= $QUALITY_LOW && $_ <= $QUALITY_HIGH || $_ == $QUALITY_UNKNOWN };

1;

=head1 NAME

MusicBrainz::Server::Constants - general Moose types and constants

=head1 TYPES

=head2 DateTime

Type for DateTime classes

=head2 AutoEditorElectionStatus

Type for representing one of the ELECTION_ constants

=head2 Vote

Type for representing the type of vote (one of the VOTE_
constants)

=head1 STATUS ENUMERATIONS

=head2 Auto-editor Elections

These status types are available for import either by name,
or by using the C<:election_status> import tag.

=over 4

=item ELECTION_SECONDER_1, ELECTION_SECONDER_2

The election is awaiting a first or second editor to second the
proposal

=item ELECTION_OPEN

The election is open for editors to vote

=item ELECTION_ACCEPTED

The election has closed and the candidate was accepted

=item ELECTION_REJECTED

The election has closed and the candidate was rejected

=item ELECTION_CANCELLED

The original proposer has cancelled the election

=head2 Votes

Types of votes editor's are able to cast

=over 4

=item VOTE_YES

A yes vote

=item VOTE_NO

A no vote

=item VOTE_ABSTAIN

An abstain vote - the user has specified they plan to vote on this
election at a later time

=item VOTE_NO_VOTE

The user has explicitly casted no vote

=cut

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
