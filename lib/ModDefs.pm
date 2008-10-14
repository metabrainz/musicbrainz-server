#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package ModDefs;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (
        artistid  => [qw( VARTIST_ID VARTIST_MBID DARTIST_ID )],
        labelid   => [qw( DLABEL_ID )],
        userid    => [qw( ANON_MODERATOR FREEDB_MODERATOR MODBOT_MODERATOR )],
        modstatus => [qw( STATUS_OPEN STATUS_DELETED STATUS_TOBEDELETED STATUS_NOVOTES
                          STATUS_FAILEDPREREQ STATUS_ERROR STATUS_FAILEDDEP STATUS_FAILEDVOTE
                          STATUS_APPLIED
                        )],
        vote      => [qw( VOTE_NO VOTE_YES VOTE_ABS VOTE_NOTVOTED VOTE_UNKNOWN )],
);

Exporter::export_ok_tags(qw(artistid labelid userid modstatus vote));

# Use the following id for the multiple/various artist albums
use constant VARTIST_ID					=> 1;
use constant VARTIST_MBID				=> "89ad4ac3-39f7-470e-963a-56509c546377";

# Use the following id to reference artist that have been deleted.
# This will be used only by the moderation system
use constant DARTIST_ID					=> 2;
use constant DLABEL_ID					=> 1;

# Special TRMs
use constant TRM_ID_SILENCE				=> "7d154f52-b536-4fae-b58b-0666826c2bac";
use constant TRM_TOO_SHORT				=> "f9809ab1-2b0f-4d78-8862-fb425ade8ab9";
use constant TRM_SIGSERVER_BUSY			=> "c457a4a8-b342-4ec9-8f13-b6bd26c0e400";

use constant ANON_MODERATOR				=> 1;
use constant FREEDB_MODERATOR			=> 2;
use constant MODBOT_MODERATOR			=> 4;

# Values used for edit levels (quality)
use constant QUALITY_UNKNOWN         => -1;
use constant QUALITY_UNKNOWN_MAPPED  => 1;
use constant QUALITY_LOW             => 0;
use constant QUALITY_NORMAL          => 1;
use constant QUALITY_HIGH            => 2;

my %QualityNames = (
   QUALITY_LOW     . "" => 'low',
   QUALITY_NORMAL  . "" => 'default',
   QUALITY_HIGH    . "" => 'high'
);

sub GetQualityText
{
   my ($level) = @_;

   # The level unknown is an internal state that will never be shown to the
   # the users. Users cannot set data quality back to unknown and yet
   # unknown behaves like a known level (determined by QUALITY_UNKNOWN_MAPPED)
   $level = QUALITY_UNKNOWN_MAPPED if $level == QUALITY_UNKNOWN;

   return $QualityNames{$level};
}

# Expire actions -- what to do when an edit expires without having a definitive outcome

# Reject expired edits
use constant EXPIRE_REJECT           => 0;
# Accept expired edits
use constant EXPIRE_ACCEPT           => 1;
# Keep expired edits open for a grace period if the artist has enough subscribers. 
# If there are not enough subscribers, accept the edit. If there are and the
# grace period passes, accept the edit
use constant EXPIRE_KEEP_OPEN_IF_SUB => 2;

my %ExpireActionNames = (
   EXPIRE_REJECT            . "" => 'reject',
   EXPIRE_ACCEPT            . "" => 'accept',
   EXPIRE_KEEP_OPEN_IF_SUB  . "" => 'keep open if artist has subscribers' 
);

sub GetExpireActionText
{
    return $ExpireActionNames{$_[0]};
} 

# The constants below define the state a moderation can have:

# Open for people to vote on
use constant STATUS_OPEN				=> 1;

# The vote was successful and the moderation applied
use constant STATUS_APPLIED				=> 2;

# The vote was unsuccessful and the moderation undone
use constant STATUS_FAILEDVOTE			=> 3;

# A dependent moderation failed, therefore this moderation will fail
use constant STATUS_FAILEDDEP			=> 4;

# There was an internal error. :-(
use constant STATUS_ERROR				=> 5;

# The Moderation system fails a moderation if the previous_data value field
# does not match up with the data currently in the rol/col.
use constant STATUS_FAILEDPREREQ		=> 6;

# The edit received no votes during the voting period and the
# edit rules determined that the edit should be rejected.
use constant STATUS_NOVOTES             => 7;

# When a moderator wants to delete their own mod, the web interface Moderation 
# its status to 'to be deleted' so that the ModerationBot can clean it and
# its possible depedents up. Once the ModBot spots this record it cleans up
# any dependants and then marks the record as 'deleted'.
use constant STATUS_TOBEDELETED			=> 8;
use constant STATUS_DELETED				=> 9;

# These are the various vote states
# The moderation voted NO
use constant VOTE_NO					=> 0;
# The moderation voted YES
use constant VOTE_YES					=> 1;
# The moderation voted ABSTAIN
use constant VOTE_ABS					=> -1;

# The moderator didn't vote.
use constant VOTE_NOTVOTED				=> -2;

# The database did not retrieve this information. You need to fetch the
# vote outcome from the moderation specifically.
use constant VOTE_UNKNOWN				=> -3;

{ my $c; sub type_as_hashref   { $c ||= _hash(qr/^MOD_/   ) } }
{ my $c; sub status_as_hashref { $c ||= _hash(qr/^STATUS_/) } }
{ my $c; sub vote_as_hashref   { $c ||= _hash(qr/^VOTE_/  ) } }

sub _hash
{
	my $re = shift;

	my $stash = \%ModDefs::;
	my %h;

	for my $name (grep /$re/, keys %$stash)
	{
		my $glob = $stash->{$name};
		$h{$name} = &$glob if defined &$glob;
	}

	\%h;
}

1;
