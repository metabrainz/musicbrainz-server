#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=8 sw=8 :
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

my $stash = \%ModDefs::;
my @subs = grep {
    my $glob = $stash->{$_};
    defined *{$glob}{CODE};
} sort keys %$stash;

my $get = sub {
    my $re = shift;
    [ grep { $_ =~ $re } @subs ];
};

use Exporter;
@ISA = qw( Exporter );

%EXPORT_TAGS = (
	artistid	=> &$get(qr/^[VD]ARTIST_(MB)?ID$/),
	userid		=> &$get(qr/^(?!TYPE)\w+_MODERATOR$/),
	modtype		=> &$get(qr/^MOD_/),
	modstatus	=> &$get(qr/^STATUS_/),
	vote		=> &$get(qr/^VOTE_/),
	all		=> \@subs,
);

@EXPORT_OK = @subs;

use strict;

# Use the following id for the multiple/various artist albums
use constant VARTIST_ID                  => 1;
use constant VARTIST_MBID                => "89ad4ac3-39f7-470e-963a-56509c546377";

# Use the following id to reference artist that have been deleted.
# This will be used only by the moderation system
use constant DARTIST_ID                  => 2;

# Special TRMs
use constant TRM_ID_SILENCE              => "7d154f52-b536-4fae-b58b-0666826c2bac";
use constant TRM_TOO_SHORT               => "f9809ab1-2b0f-4d78-8862-fb425ade8ab9";
use constant TRM_SIGSERVER_BUSY          => "c457a4a8-b342-4ec9-8f13-b6bd26c0e400";

use constant ANON_MODERATOR              => 1;
use constant FREEDB_MODERATOR            => 2;
use constant MODBOT_MODERATOR            => 4;

# The various moderations, enumerated
use constant MOD_EDIT_ARTISTNAME         => 1;
use constant MOD_EDIT_ARTISTSORTNAME     => 2;
use constant MOD_EDIT_ALBUMNAME          => 3;
use constant MOD_EDIT_TRACKNAME          => 4;
use constant MOD_EDIT_TRACKNUM           => 5;
use constant MOD_MERGE_ARTIST            => 6;
use constant MOD_ADD_TRACK               => 7;
use constant MOD_MOVE_ALBUM              => 8;
use constant MOD_SAC_TO_MAC              => 9;
use constant MOD_CHANGE_TRACK_ARTIST     => 10;
use constant MOD_REMOVE_TRACK            => 11;
use constant MOD_REMOVE_ALBUM            => 12;
use constant MOD_MAC_TO_SAC              => 13;
use constant MOD_REMOVE_ARTISTALIAS      => 14;
use constant MOD_ADD_ARTISTALIAS         => 15;
use constant MOD_ADD_ALBUM               => 16;
use constant MOD_ADD_ARTIST              => 17;
use constant MOD_ADD_TRACK_KV            => 18;
use constant MOD_REMOVE_ARTIST           => 19;
use constant MOD_REMOVE_DISCID           => 20;
use constant MOD_MOVE_DISCID             => 21;
use constant MOD_REMOVE_TRMID            => 22;
use constant MOD_MERGE_ALBUM             => 23;
use constant MOD_REMOVE_ALBUMS           => 24;
use constant MOD_MERGE_ALBUM_MAC         => 25;
use constant MOD_EDIT_ALBUMATTRS         => 26;
use constant MOD_ADD_TRMS                => 27;
use constant MOD_EDIT_ARTISTALIAS        => 28;
use constant MOD_EDIT_RELEASES           => 29;
use constant MOD_LAST                    => 29;


# The constants below define the state a moderation can have:

# Open for people to vote on
use constant STATUS_OPEN                 => 1;

# The vote was successful and the moderation applied
use constant STATUS_APPLIED              => 2;

# The vote was unsuccessful and the moderation undone
use constant STATUS_FAILEDVOTE           => 3;

# A dependent moderation failed, therefore this moderation will fail
use constant STATUS_FAILEDDEP            => 4;

# There was an internal error. :-(
use constant STATUS_ERROR                => 5;

# The Moderation system fails a moderation if the previous value field
# does not match up with the data currently in the rol/col.
use constant STATUS_FAILEDPREREQ         => 6;

# When a moderator wants to delete their own mod, the web interface Moderation 
# its status to 'to be deleted' so that the ModerationBot can clean it and
# its possible depedents up. Once the ModBot spots this record it cleans up
# any dependants and then marks the record as 'deleted'.
use constant STATUS_TOBEDELETED          => 8;
use constant STATUS_DELETED              => 9;

# These are the various vote states
# The moderation voted NO
use constant VOTE_NO       => 0;
# The moderation voted YES
use constant VOTE_YES      => 1;
# The moderation voted ABSTAIN
use constant VOTE_ABS      => -1;

# The moderator didn't vote.
use constant VOTE_NOTVOTED => -2;

# The database did not retrieve this information. You need to fetch the
# vote outcome from the moderation specifically.
use constant VOTE_UNKNOWN  => -3;

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
# eof ModDefs.pm
