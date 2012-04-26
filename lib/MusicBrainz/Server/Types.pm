package MusicBrainz::Server::Types;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (
    election_status => [
        qw( $ELECTION_SECONDER_1 $ELECTION_SECONDER_2 $ELECTION_OPEN
            $ELECTION_ACCEPTED   $ELECTION_REJECTED   $ELECTION_CANCELLED )
    ],
    election_vote => [
        qw( $ELECTION_VOTE_YES $ELECTION_VOTE_NO $ELECTION_VOTE_ABSTAIN )
    ],
    vote => [
        qw( $VOTE_NO $VOTE_ABSTAIN $VOTE_YES $VOTE_APPROVE )
    ],
    edit_status => [
        qw( $STATUS_OPEN      $STATUS_APPLIED     $STATUS_FAILEDVOTE
            $STATUS_FAILEDDEP $STATUS_ERROR       $STATUS_FAILEDPREREQ
            $STATUS_NOVOTES   $STATUS_TOBEDELETED $STATUS_DELETED )
    ],
    privileges => [
        qw( $AUTO_EDITOR_FLAG         $BOT_FLAG           $UNTRUSTED_FLAG
            $RELATIONSHIP_EDITOR_FLAG $DONT_NAG_FLAG      $WIKI_TRANSCLUSION_FLAG
            $MBID_SUBMITTER_FLAG      $ACCOUNT_ADMIN_FLAG )
      ],
);
Exporter::export_ok_tags($_) for qw( election_status election_vote vote edit_status privileges );

use DateTime::Format::Pg;
use Readonly;
use Moose::Util::TypeConstraints;
use MusicBrainz::Server::Constants qw( :quality );

Readonly our $ELECTION_SECONDER_1 => 1;
Readonly our $ELECTION_SECONDER_2 => 2;
Readonly our $ELECTION_OPEN       => 3;
Readonly our $ELECTION_ACCEPTED   => 4;
Readonly our $ELECTION_REJECTED   => 5;
Readonly our $ELECTION_CANCELLED  => 6;

Readonly our $ELECTION_VOTE_NO      => -1;
Readonly our $ELECTION_VOTE_ABSTAIN => 0;
Readonly our $ELECTION_VOTE_YES     => 1;

Readonly our $VOTE_ABSTAIN => -1;
Readonly our $VOTE_NO      =>  0;
Readonly our $VOTE_YES     =>  1;
Readonly our $VOTE_APPROVE =>  2;

Readonly our $STATUS_OPEN         => 1;
Readonly our $STATUS_APPLIED      => 2;
Readonly our $STATUS_FAILEDVOTE   => 3;
Readonly our $STATUS_FAILEDDEP    => 4;
Readonly our $STATUS_ERROR        => 5;
Readonly our $STATUS_FAILEDPREREQ => 6;
Readonly our $STATUS_NOVOTES      => 7;
Readonly our $STATUS_TOBEDELETED  => 8;
Readonly our $STATUS_DELETED      => 9;

Readonly our $AUTO_EDITOR_FLAG         => 1;
Readonly our $BOT_FLAG                 => 2;
Readonly our $UNTRUSTED_FLAG           => 4;
Readonly our $RELATIONSHIP_EDITOR_FLAG => 8;
Readonly our $DONT_NAG_FLAG            => 16;
Readonly our $WIKI_TRANSCLUSION_FLAG   => 32;
Readonly our $MBID_SUBMITTER_FLAG      => 64;
Readonly our $ACCOUNT_ADMIN_FLAG       => 128;

subtype 'DateTime'
    => class_type 'DateTime';

coerce 'DateTime'
    => from 'Str'
    => via { DateTime::Format::Pg->parse_datetime($_) };

subtype 'AutoEditorElectionStatus'
    => as 'Int'
    => where { $_ >= $ELECTION_SECONDER_1 && $_ <= $ELECTION_CANCELLED };

subtype 'VoteOption'
    => as 'Int'
    => where { $_ >= $VOTE_ABSTAIN && $_ <= $VOTE_APPROVE };

subtype 'EditStatus'
    => as 'Int'
    => where { $_ >= $STATUS_OPEN && $_ <= $STATUS_DELETED };

subtype 'Quality'
    => as 'Int'
    => where { $_ >= $QUALITY_LOW && $_ <= $QUALITY_HIGH || $_ == $QUALITY_UNKNOWN };

1;

=head1 NAME

MusicBrainz::Server::Types - general Moose types and constants

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
