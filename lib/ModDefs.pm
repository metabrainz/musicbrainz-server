#!/usr/bin/env perl

use warnings;
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

my $stash = \%ModDefs::;
my @subs = grep {
    my $glob = $stash->{$_};
    ref $glob eq 'GLOB' && defined *{$glob}{CODE};
} sort keys %$stash;

@subs = grep !/^BEGIN$/, keys %ModDefs::;

sub _get {
    my $re = shift;
    [ grep { $_ =~ $re } @subs ];
};

use Exporter;
@ISA = qw( Exporter );

%EXPORT_TAGS = (
    artistid    => _get(qr/^[VD]ARTIST_(MB)?ID$/),
    labelid             => _get(qr/^[D]LABEL_(MB)?ID$/),
    userid              => _get(qr/^\w+_MODERATOR$/),
    modtype             => _get(qr/^MOD_/),
    modstatus   => _get(qr/^STATUS_/),
    vote                => _get(qr/^VOTE_/),
    all             => [ @subs ],
);

@EXPORT = @subs;
@EXPORT_OK = @subs;

use strict;

# Use the following id for the multiple/various artist albums
use constant VARTIST_ID                                 => 1;
use constant VARTIST_MBID                       => "89ad4ac3-39f7-470e-963a-56509c546377";

# Use the following id to reference artist that have been deleted.
# This will be used only by the moderation system
use constant DARTIST_ID                                 => 2;

use constant DLABEL_ID                                  => 1;

# Special TRMs
use constant TRM_ID_SILENCE                     => "7d154f52-b536-4fae-b58b-0666826c2bac";

use constant ANON_MODERATOR                     => 1;
use constant FREEDB_MODERATOR                   => 2;
use constant MODBOT_MODERATOR                   => 4;

# The various moderations, enumerated
use constant MOD_EDIT_ARTISTNAME         => 1;
use constant MOD_EDIT_ARTISTSORTNAME     => 2;
use constant MOD_EDIT_RELEASE_NAME               => 3;
use constant MOD_EDIT_TRACKNAME                  => 4;
use constant MOD_EDIT_TRACKNUM                   => 5;
use constant MOD_MERGE_ARTIST                    => 6;
use constant MOD_ADD_TRACK                       => 7;
use constant MOD_MOVE_RELEASE                            => 8;
use constant MOD_SAC_TO_MAC                      => 9;
use constant MOD_CHANGE_TRACK_ARTIST     => 10;
use constant MOD_REMOVE_TRACK                    => 11;
use constant MOD_REMOVE_RELEASE                  => 12;
use constant MOD_MAC_TO_SAC                      => 13;
use constant MOD_REMOVE_ARTISTALIAS      => 14;
use constant MOD_ADD_ARTISTALIAS         => 15;
use constant MOD_ADD_RELEASE                             => 16;
use constant MOD_ADD_ARTIST                      => 17;
use constant MOD_ADD_TRACK_KV                    => 18;
use constant MOD_REMOVE_ARTIST                   => 19;
use constant MOD_REMOVE_DISCID                   => 20;
use constant MOD_MOVE_DISCID                     => 21;
use constant MOD_MERGE_RELEASE                   => 23;
use constant MOD_REMOVE_RELEASES                 => 24;
use constant MOD_MERGE_RELEASE_MAC       => 25;
use constant MOD_EDIT_RELEASE_ATTRS      => 26;
use constant MOD_EDIT_ARTISTALIAS        => 28;
use constant MOD_EDIT_RELEASE_EVENTS_OLD                 => 29;
use constant MOD_ADD_ARTIST_ANNOTATION     => 30;
use constant MOD_ADD_RELEASE_ANNOTATION     => 31;
use constant MOD_ADD_DISCID                      => 32;
use constant MOD_ADD_LINK                        => 33;
use constant MOD_EDIT_LINK                       => 34;
use constant MOD_REMOVE_LINK                     => 35;
use constant MOD_ADD_LINK_TYPE                   => 36;
use constant MOD_EDIT_LINK_TYPE                  => 37;
use constant MOD_REMOVE_LINK_TYPE        => 38;
# use constant MOD_MERGE_LINK_TYPE       => 39; -- not implemented
use constant MOD_EDIT_ARTIST                     => 40;
use constant MOD_ADD_LINK_ATTR                   => 41;
use constant MOD_EDIT_LINK_ATTR                  => 42;
use constant MOD_REMOVE_LINK_ATTR        => 43;
use constant MOD_EDIT_RELEASE_LANGUAGE     => 44;
use constant MOD_EDIT_TRACKTIME                  => 45;
use constant MOD_REMOVE_PUID                     => 46;
use constant MOD_ADD_PUIDS                       => 47;
use constant MOD_CHANGE_WIKIDOC                  => 48;
use constant MOD_ADD_RELEASE_EVENTS      => 49;
use constant MOD_EDIT_RELEASE_EVENTS             => 50;
use constant MOD_REMOVE_RELEASE_EVENTS     => 51;
use constant MOD_CHANGE_ARTIST_QUALITY   => 52;
use constant MOD_SET_RELEASE_DURATIONS     => 53;
use constant MOD_ADD_LABEL                       => 54;
use constant MOD_EDIT_LABEL                      => 55;
use constant MOD_REMOVE_LABEL                    => 56;
use constant MOD_ADD_LABEL_ANNOTATION     => 57;
use constant MOD_MERGE_LABEL                     => 58;
use constant MOD_EDIT_URL                        => 59;
use constant MOD_ADD_LABELALIAS                  => 60;
use constant MOD_EDIT_LABELALIAS         => 61;
use constant MOD_REMOVE_LABELALIAS       => 62;
use constant MOD_CHANGE_RELEASE_QUALITY  => 63;
use constant MOD_ADD_TRACK_ANNOTATION     => 64;
use constant MOD_LAST                                    => 64;

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
use constant STATUS_OPEN                        => 1;

# The vote was successful and the moderation applied
use constant STATUS_APPLIED                     => 2;

# The vote was unsuccessful and the moderation undone
use constant STATUS_FAILEDVOTE                  => 3;

# A dependent moderation failed, therefore this moderation will fail
use constant STATUS_FAILEDDEP                   => 4;

# There was an internal error. :-(
use constant STATUS_ERROR                       => 5;

# The Moderation system fails a moderation if the previous value field
# does not match up with the data currently in the rol/col.
use constant STATUS_FAILEDPREREQ        => 6;

# The edit received no votes during the voting period and the
# edit rules determined that the edit should be rejected.
use constant STATUS_NOVOTES             => 7;

# When a moderator wants to delete their own mod, the web interface Moderation
# its status to 'to be deleted' so that the ModerationBot can clean it and
# its possible depedents up. Once the ModBot spots this record it cleans up
# any dependants and then marks the record as 'deleted'.
use constant STATUS_TOBEDELETED                 => 8;
use constant STATUS_DELETED                     => 9;

# These are the various vote states
# The moderation voted NO
use constant VOTE_NO                                    => 0;
# The moderation voted YES
use constant VOTE_YES                                   => 1;
# The moderation voted ABSTAIN
use constant VOTE_ABS                                   => -1;
# An auto-editor approved the edit
use constant VOTE_APPROVE                               => 2;

# The moderator didn't vote.
use constant VOTE_NOTVOTED                      => -2;

# The database did not retrieve this information. You need to fetch the
# vote outcome from the moderation specifically.
use constant VOTE_UNKNOWN                       => -3;

my %VoteNames = (
    VOTE_NO  . ""      => "no",
    VOTE_YES . ""      => "yes",
    VOTE_ABS . ""      => "abstain",
    VOTE_APPROVE . ""  => "approve",
    VOTE_NOTVOTED . "" => "not voted",
    VOTE_UNKNOWN  . "" => "unknown",
);

sub vote_name
{
    my $vote = shift;
    return $VoteNames{$vote} || $VoteNames{VOTE_UNKNOWN};
}

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


# Moderation DataQuality level categories
use constant CAT_NONE           => 0;
use constant CAT_ARTIST    => 1;
use constant CAT_RELEASE    => 2;
use constant CAT_DEPENDS    => 3;

# Moderation DataQuality level category header titles
my %ModCategoryTitles = (
    CAT_ARTIST  . "" => "Artist Level Dependent Edits",
    CAT_RELEASE . "" => "Release Level Dependent Edits",
    CAT_DEPENDS . "" => "Circumstantial Level Dependent Edits",
    CAT_NONE    . "" => "Level Independent Edits"
);

# DataQuality level moderations catogorization
my %ModCategories = (
    MOD_ADD_RELEASE                             . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_ADD_RELEASE_ANNOTATION  . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_ARTIST                              . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_ARTISTALIAS                 . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_ADD_ARTIST_ANNOTATION   . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_DISCID                              . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_LABEL                               . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_LABELALIAS                  . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_LABEL_ANNOTATION            . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_LINK                                        . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_ADD_LINK_ATTR                   . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_ADD_LINK_TYPE                   . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_ADD_PUIDS                               . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_RELEASE_EVENTS              . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_ADD_TRACK                               . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_ADD_TRACK_ANNOTATION            . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_ADD_TRACK_KV                            . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_CHANGE_ARTIST_QUALITY   . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_CHANGE_RELEASE_QUALITY  . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_CHANGE_TRACK_ARTIST             . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release, current artist or new artist"},
    MOD_CHANGE_WIKIDOC                  . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_EDIT_RELEASE_LANGUAGE           . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit if no language was set"},
    MOD_EDIT_RELEASE_ATTRS                      . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit if no attributes where set"},
    MOD_EDIT_RELEASE_NAME                       . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit when changing capitalisation or accents"},
    MOD_EDIT_ARTIST                             . "" => {'category' => CAT_ARTIST, 'criteria' => "Auto-edit when providing new properties (Begin Date, End Date or Type) or changing capitalisation or accents"},
    MOD_EDIT_ARTISTALIAS                        . "" => {'category' => CAT_ARTIST, 'criteria' => "Auto-edit when changing capitalisation or accents"},
    MOD_EDIT_ARTISTNAME                 . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_EDIT_ARTISTSORTNAME             . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_EDIT_LABEL                              . "" => {'category' => CAT_NONE, 'criteria' => "Auto-edit when providing new properties (Begin Date, End Date or Type) or changing capitalisation or accents"},
    MOD_EDIT_LABELALIAS                         . "" => {'category' => CAT_NONE, 'criteria' => "Auto-edit when changing capitalisation or accents"},
    MOD_EDIT_LINK                                       . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_EDIT_LINK_ATTR                  . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_EDIT_LINK_TYPE                  . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_EDIT_RELEASE_EVENTS_OLD                 . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_EDIT_RELEASE_EVENTS             . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit when providing supplemental information"},
    MOD_EDIT_TRACKNAME                  . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit when changing capitalisation or accents"},
    MOD_EDIT_TRACKNUM                   . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_EDIT_TRACKTIME                  . "" => {'category' => CAT_RELEASE, 'criteria' => "Auto-edit if no times where set"},
    MOD_EDIT_URL                                . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_MAC_TO_SAC                              . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release or new artist"},
    MOD_MERGE_RELEASE                   . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release or new artist"},
    MOD_MERGE_RELEASE_MAC               . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release or new artist"},
    MOD_MERGE_ARTIST                    . "" => {'category' => CAT_ARTIST, 'criteria' => "Level of artist with highest level"},
    MOD_MERGE_LABEL                             . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_MOVE_RELEASE                            . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release, current artist or new artist"},
    MOD_MOVE_DISCID                             . "" => {'category' => CAT_RELEASE, 'criteria' => "Level of release with highest level"},
    MOD_REMOVE_RELEASE                  . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_REMOVE_RELEASES                 . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_REMOVE_ARTIST                   . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_REMOVE_ARTISTALIAS              . "" => {'category' => CAT_ARTIST, 'criteria' => ""},
    MOD_REMOVE_DISCID                   . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_REMOVE_LABEL                    . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_REMOVE_LABELALIAS               . "" => {'category' => CAT_NONE, 'criteria' => ""},
    MOD_REMOVE_LINK                             . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_REMOVE_LINK_ATTR                        . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_REMOVE_LINK_TYPE                        . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_REMOVE_PUID                             . "" => {'category' => CAT_DEPENDS, 'criteria' => ""},
    MOD_REMOVE_RELEASE_EVENTS   . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_REMOVE_TRACK                    . "" => {'category' => CAT_RELEASE, 'criteria' => ""},
    MOD_SAC_TO_MAC                              . "" => {'category' => CAT_DEPENDS, 'criteria' => "Highest level of release or current artist"},
    MOD_SET_RELEASE_DURATIONS   . "" => {'category' => CAT_RELEASE, 'criteria' => ""}
);

sub GetModCategories
{
    return %ModCategories;
}

sub GetModCategoryTitle
{
    return $ModCategoryTitles{$_[0]};
}

1;
# eof ModDefs.pm
