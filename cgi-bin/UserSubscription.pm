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

use strict;

package UserSubscription;
use base qw( TableBase );

sub GetUser	{ $_[0]{moderator} }
sub SetUser	{ $_[0]{moderator} = $_[1] }

################################################################################
# Managing a user's subscription list
################################################################################

sub GetSubscribedArtists
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	$sql->SelectListOfHashes(
		"SELECT s.*, a.name, a.sortname
		FROM moderator_subscribe_artist s
		LEFT JOIN artist a ON a.id = s.artist
		WHERE s.moderator = ?
		ORDER BY a.sortname, s.artist",
		$uid,
	);
}

sub SubscribeArtists
{
	my ($self, @artists) = @_;
	my $uid = $self->GetUser or die;

	my @artistids;

	for my $artist (@artists)
	{
		my $artistid = $artist->GetId;
		die if $artistid == &ModDefs::VARTIST_ID;
		die if $artistid == &ModDefs::DARTIST_ID;
		push @artistids, $artistid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		my $mod = Moderation->new($self->{DBH});
		my $modid = 0;

		for my $artistid (@artistids)
		{
			$sql->SelectSingleValue(
				"SELECT 1 FROM moderator_subscribe_artist
				WHERE moderator = ? AND artist = ?",
				$uid,
				$artistid,
			) and next;

			$modid ||= $mod->GetMaxModID;

			$sql->Do(
				"INSERT INTO moderator_subscribe_artist
					(moderator, artist, lastmodsent)
				VALUES (?, ?, ?)",
				$uid,
				$artistid,
				$modid,
			);
		}
	});

	1;
}

sub UnsubscribeArtists
{
	my ($self, @artists) = @_;
	my $uid = $self->GetUser or die;

	my @artistids;

	for my $artist (@artists)
	{
		my $artistid = $artist->GetId;
		# die if $artistid == &ModDefs::VARTIST_ID;
		# die if $artistid == &ModDefs::DARTIST_ID;
		push @artistids, $artistid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		for my $artistid (@artistids)
		{
			$sql->Do(
				"DELETE FROM moderator_subscribe_artist
				WHERE moderator = ? AND artist = ?",
				$uid,
				$artistid,
			);
		}
	});

	1;
}

################################################################################
# Hooks called when artists are about to be deleted or merged away
################################################################################

sub ArtistBeingDeleted
{
	my ($self, $artist, $moderation) = @_;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE moderator_subscribe_artist
		SET deletedbymod = ? WHERE artist = ?",
		$moderation->GetId,
		$artist->GetId,
	);
}

sub ArtistBeingMerged
{
	my ($self, $artist, $moderation) = @_;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE moderator_subscribe_artist
		SET mergedbymod = ? WHERE artist = ?",
		$moderation->GetId,
		$artist->GetId,
	);
}

################################################################################
# The Subscription Bot.  This is what checks for moderations on your
# subscribed artists, then e-mails you to let you know.
################################################################################

sub ProcessAllSubscriptions
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$self->{THRESHOLD_MODID} = $sql->SelectSingleValue(
		"SELECT NEXTVAL('moderation_id_seq')"
	);
	defined($self->{THRESHOLD_MODID}) or die;

	$self->{ARTIST_MODCOUNT_CACHE} = {};

	my $users = $sql->SelectSingleColumnArray(
		"SELECT DISTINCT moderator FROM moderator_subscribe_artist",
	);
	
	printf "Processing subscriptions for %d moderators\n",
		scalar @$users
		if $self->{'verbose'};

	for my $uid (@$users)
	{
		$self->SetUser($uid);

		eval {
			$sql->Begin;
			$self->_ProcessUserSubscriptions;
			$sql->Commit;
			1;
		} and next;
		
		my $err = $@;
		eval { $sql->Rollback };

		print STDERR "Error whilst processing subscriptions for user #$uid:\n";
		print STDERR "\t$err\n";
	}
}

sub _ProcessUserSubscriptions
{
	my $self = shift;

	require UserStuff;
	my $user = UserStuff->new($self->{DBH});
	$user = $user->newFromId($self->GetUser);

	printf "Processing subscriptions for #%d '%s'\n",
		$user->GetId, $user->GetName,
		if $self->{'verbose'};

	my $subs = $self->GetSubscribedArtists;
	if (not @$subs)
	{
		print "No subscriptions (huh?)\n"
			if $self->{'verbose'};
		return;
	}

	unless ($user->GetEmail and $user->GetEmailConfirmDate)
	{
		printf "Skipping subscriptions for user #%d '%s' because they have no confirmed e-mail address\n",
			$user->GetId, $user->GetName
			if $self->{'verbose'};
		# Instead of returning here, we just empty the list of subscriptions.
		# Thus we don't go to all the trouble of looking for moderations, and
		# we don't send an e-mail, but we *do* update the "lastmodsent" values
		# for this user.
		@$subs = ();
	}

	my $text = "";
	my $root = "http://" . &DBDefs::WEB_SERVER;
	my $sql = Sql->new($self->{DBH});

	for my $sub (@$subs)
	{
		if (my $modid = $sub->{'deletedbymod'})
		{
			printf "Artist #%d was deleted by mod #%d\n",
				$sub->{'artist'}, $modid,
				if $self->{'verbose'};
			$text .= "One of your subscribed artists was deleted:\n"
				. "$root/showmod.html?modid=$modid\n\n";
			next;
		}

		if (my $modid = $sub->{'mergedbymod'})
		{
			printf "Artist #%d was merged by mod #%d\n",
				$sub->{'artist'}, $modid,
				if $self->{'verbose'};
			$text .= "One of your subscribed artists was merged:\n"
				. "$root/showmod.html?modid=$modid\n\n";
			next;
		}

		# Find mods for this artist which are
		# > lastmodsent and <= THRESHOLD_MODID

		my ($open, $applied);
		require ModDefs;
		for (
			[ &ModDefs::STATUS_OPEN, \$open ],
			[ &ModDefs::STATUS_APPLIED, \$applied ],
		) {
			my ($status, $countref) = @$_;

			my $cache = $self->{ARTIST_MODCOUNT_CACHE};
			my $cachekey = join "-",
				$sub->{'artist'},
				$sub->{'lastmodsent'},
				$status;

			if (not defined $cache->{$cachekey})
			{
				printf "Counting mods: a=%d s=%d %d < id <= %d\n",
					$sub->{'artist'},
					$status,
					$sub->{'lastmodsent'},
					$self->{THRESHOLD_MODID},
					if $self->{'verbose'};

				$cache->{$cachekey} = $sql->SelectSingleValue(
					"SELECT COUNT(*) FROM moderation
					WHERE artist = ?
					AND status = ?
					AND id > ?
					AND id <= ?",
					$sub->{'artist'},
					$status,
					$sub->{'lastmodsent'},
					$self->{THRESHOLD_MODID},
				);

				print "Answer=$cache->{$cachekey} (saved in $cachekey)\n"
					if $self->{'verbose'};
			}

			$$countref = $cache->{$cachekey};
		}

		next if $open == 0 and $applied == 0;

		printf "A=%d '%s' open=%d applied=%d\n",
			$sub->{'artist'}, $sub->{'name'},
			$open, $applied,
			if $self->{'verbose'};
		
		$text .= "$sub->{'name'} ($open open, $applied applied)\n"
			. "$root/mod/search/pre/artist.html"
			. "?artistid=$sub->{'artist'}\n\n";
	}

	unless ($self->{'dryrun'})
	{
		$sql->Do(
			"DELETE FROM moderator_subscribe_artist
			WHERE moderator = ? AND (deletedbymod <> 0 OR mergedbymod <> 0)",
			$self->GetUser,
		);
		$sql->Do(
			"UPDATE moderator_subscribe_artist
			SET lastmodsent = ? WHERE moderator = ?",
			$self->{THRESHOLD_MODID},
			$self->GetUser,
		);
	}

	if ($text eq "")
	{
		print "No moderations for subscribed artists\n"
			if $self->{'verbose'};
		return;
	}

		my $textbody = <<EOF;
This is a notification that moderations have been added for artists to
whom you subscribed on the MusicBrainz web site.  To view or edit your
subscription list, please use the following link:
$root/user/subscriptions.html

To see all open moderations for your subscribed artists, see this link:
$root/mod/search/pre/subscriptions.html

The changes to your subscribed artists are as follows:
------------------------------------------------------------------------

$text
------------------------------------------------------------------------

Please do not reply to this message.  If you need help, please see
$root/support/contact.html

EOF
		;

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		# Sender: not required
		From		=> 'MusicBrainz Subscription Robot <noreply@musicbrainz.org>',
		# To: $user (automatic)
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Moderations for your subscribed artists",
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $textbody,
	);
    $mail->attr("content-type.charset" => "utf-8");

	my $html = 0; # TODO make use of HTML email
	if ($html)
	{
		my $htmlbody = "...\n";

		my $htmlpart = $mail->new(
			Type		=> "text/html",
			Encoding	=> "quoted-printable",
			Data		=> $htmlbody,
		);
		$htmlpart->attr("content-type.charset" => "utf-8");

		$mail->attach($htmlpart);
		$mail->attr("content-type", "multipart/alternative");
	}

	if ($self->{'dryrun'})
	{
		printf "The following e-mail would be sent to #%d '%s':\n",
			$user->GetId, $user->GetName;
		$mail->print;
		return;
	}

	$user->SendFormattedEmail(entity => $mail);
}

1;
# eof UserSubscription.pm
