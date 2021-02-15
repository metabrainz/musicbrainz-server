package MusicBrainz::Server::Types;

use strict;
use warnings;

use DateTime ();
use DateTime::Format::Pg;

use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( :quality :election_status :vote :edit_status );

use namespace::clean;

use MooseX::Types -declare => [qw(
    DateTime
    PgDateStr
    Time
    AutoEditorElectionStatus
    VoteOption
    EditStatus
    Quality
)];

class_type 'DateTime';

subtype DateTime, as 'DateTime';

coerce DateTime,
    from Str,
    via { DateTime::Format::Pg->parse_datetime($_) };

subtype PgDateStr,
    as Str;

coerce PgDateStr,
    from DateTime,
    via { DateTime::Format::Pg->format_datetime($_) };

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
