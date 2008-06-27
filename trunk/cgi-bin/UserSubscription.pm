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

use TableBase;
{ our @ISA = qw( TableBase ) }

sub GetUser	{ $_[0]{moderator} }
sub SetUser	{ $_[0]{moderator} = $_[1] }

################################################################################
# Users subscribed to an artist
################################################################################

# Returns a list or count of users subscribed to a particular artist
sub GetSubscribersForArtist
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $artist = shift;

	return if not defined wantarray;
    my $sql = Sql->new($self->{DBH});

    return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderator_subscribe_artist WHERE artist = ?",
		$artist,
    ) if not wantarray;

    my $user_ids = $sql->SelectSingleColumnArray(
		"SELECT moderator FROM moderator_subscribe_artist WHERE artist = ?",
		$artist,
    );
	return @$user_ids;
}

################################################################################
# Users subscribed to a label
################################################################################

# Returns a list or count of users subscribed to a particular label
sub GetSubscribersForLabel
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $label = shift;

	return if not defined wantarray;
    my $sql = Sql->new($self->{DBH});

    return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderator_subscribe_label WHERE label = ?",
		$label,
    ) if not wantarray;

    my $user_ids = $sql->SelectSingleColumnArray(
		"SELECT moderator FROM moderator_subscribe_label WHERE label = ?",
		$label,
    );
	return @$user_ids;
}

################################################################################
# Users subscribed to an editor
################################################################################

# Returns a list or count of users subscribed to a particular editor
sub GetSubscribersForEditor
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $editor = shift;

	return if not defined wantarray;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM editor_subscribe_editor WHERE subscribededitor = ?",
		$editor,
	) if not wantarray;

	my $user_ids = $sql->SelectSingleColumnArray(
		"SELECT editor FROM editor_subscribe_editor WHERE subscribededitor = ?",
		$editor,
	);
	return @$user_ids;
}

################################################################################
# Managing a user's subscription list
################################################################################

sub GetSubscribedArtists
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfHashes(
		"SELECT s.*, a.name, a.sortname, a.resolution
		FROM moderator_subscribe_artist s
		LEFT JOIN artist a ON a.id = s.artist
		WHERE s.moderator = ?
		ORDER BY a.sortname, s.artist",
		$uid,
	);

	@$rows = map { $_->[0] }
		sort { $a->[1] cmp $b->[1] }
		map {
			my $row = $_;
			my $name = MusicBrainz::Server::Validation::NormaliseSortText($row->{'sortname'});
			[ $row, $name ];
		} @$rows;

	return $rows;
}

sub GetNumSubscribedArtists
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderator_subscribe_artist WHERE moderator = ?",
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
		require Moderation;
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

sub GetSubscribedLabels
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfHashes(
		"SELECT s.*, a.name, a.sortname, a.resolution
		FROM moderator_subscribe_label s
		LEFT JOIN label a ON a.id = s.label
		WHERE s.moderator = ?
		ORDER BY a.sortname, s.label",
		$uid,
	);

	@$rows = map { $_->[0] }
		sort { $a->[1] cmp $b->[1] }
		map {
			my $row = $_;
			my $name = MusicBrainz::Server::Validation::NormaliseSortText($row->{'sortname'});
			[ $row, $name ];
		} @$rows;

	return $rows;
}

sub GetNumSubscribedLabels
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderator_subscribe_label WHERE moderator = ?",
		$uid,
	);
}

sub SubscribeLabels
{
	my ($self, @labels) = @_;
	my $uid = $self->GetUser or die;

	my @labelids;

	for my $label (@labels)
	{
		my $labelid = $label->GetId;
		die if $labelid == &ModDefs::DLABEL_ID;
		push @labelids, $labelid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		require Moderation;
		my $mod = Moderation->new($self->{DBH});
		my $modid = 0;

		for my $labelid (@labelids)
		{
			$sql->SelectSingleValue(
				"SELECT 1 FROM moderator_subscribe_label
				WHERE moderator = ? AND label = ?",
				$uid,
				$labelid,
			) and next;

			$modid ||= $mod->GetMaxModID;

			$sql->Do(
				"INSERT INTO moderator_subscribe_label
					(moderator, label, lastmodsent)
				VALUES (?, ?, ?)",
				$uid,
				$labelid,
				$modid,
			);
		}
	});

	1;
}

sub UnsubscribeLabels
{
	my ($self, @labels) = @_;
	my $uid = $self->GetUser or die;

	my @labelids;

	for my $label (@labels)
	{
		my $labelid = $label->GetId;
		# die if $labelid == &ModDefs::DARTIST_ID;
		push @labelids, $labelid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		for my $labelid (@labelids)
		{
			$sql->Do(
				"DELETE FROM moderator_subscribe_label
				WHERE moderator = ? AND label = ?",
				$uid,
				$labelid,
			);
		}
	});

	1;
}

sub GetSubscribedEditors
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfHashes(
		"SELECT s.*, m.name
		FROM editor_subscribe_editor s
		LEFT JOIN moderator m ON m.id = s.subscribededitor
		WHERE s.editor = ?
		ORDER BY m.name",
		$uid,
	);

	@$rows = map { $_->[0] }
		sort { $a->[1] cmp $b->[1] }
		map {
			my $row = $_;
			my $name = MusicBrainz::Server::Validation::NormaliseSortText($row->{'name'});
			[ $row, $name ];
		} @$rows;

	return $rows;
}

sub GetNumSubscribedEditors
{
	my ($self) = @_;
	my $uid = $self->GetUser or die;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM editor_subscribe_editor WHERE editor = ?",
		$uid,
	);
}

sub SubscribeEditors
{
	my ($self, @editors) = @_;
	my $uid = $self->GetUser or die;

	my @editorids;

	for my $editor (@editors)
	{
		my $editorid = $editor->GetId;
		push @editorids, $editorid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		require Moderation;
		my $mod = Moderation->new($self->{DBH});
		my $modid = 0;

		for my $editorid (@editorids)
		{
			$sql->SelectSingleValue(
				"SELECT 1 FROM editor_subscribe_editor
				WHERE editor = ? AND subscribededitor = ?",
				$uid,
				$editorid,
			) and next;

			$modid ||= $mod->GetMaxModID;

			$sql->Do(
				"INSERT INTO editor_subscribe_editor
					(editor, subscribededitor, lasteditsent)
				VALUES (?, ?, ?)",
				$uid,
				$editorid,
				$modid,
			);
		}
	});

	1;
}

sub UnsubscribeEditors
{
	my ($self, @editors) = @_;
	my $uid = $self->GetUser or die;

	my @editorids;

	for my $editor (@editors)
	{
		my $editorid = $editor->GetId;
		push @editorids, $editorid;
	}

	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		for my $editorid (@editorids)
		{
			$sql->Do(
				"DELETE FROM editor_subscribe_editor
				WHERE editor = ? AND subscribededitor = ?",
				$uid,
				$editorid,
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
# Hooks called when labels are about to be deleted or merged away
################################################################################

sub LabelBeingDeleted
{
	my ($self, $label, $moderation) = @_;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE moderator_subscribe_label
		SET deletedbymod = ? WHERE label = ?",
		$moderation->GetId,
		$label->GetId,
	);
}

sub LabelBeingMerged
{
	my ($self, $label, $moderation) = @_;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE moderator_subscribe_label
		SET mergedbymod = ? WHERE label = ?",
		$moderation->GetId,
		$label->GetId,
	);
}

################################################################################
# The Subscription Bot.  This is what checks for edits on your
# subscribed artists, then e-mails you to let you know.
################################################################################

sub ProcessAllSubscriptions
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$self->{THRESHOLD_MODID} = do {
		require Moderation;
		my $mod = Moderation->new($self->{DBH});
		$mod->GetMaxModID;
	};
	defined($self->{THRESHOLD_MODID}) or die;

	$self->{ARTIST_MODCOUNT_CACHE} = {};

	my $users_artist = $sql->SelectSingleColumnArray(
		"SELECT DISTINCT moderator FROM moderator_subscribe_artist",
	);
	my $users_label = $sql->SelectSingleColumnArray(
		"SELECT DISTINCT moderator FROM moderator_subscribe_label",
	);
	my $users_editor = $sql->SelectSingleColumnArray(
		"SELECT DISTINCT editor FROM editor_subscribe_editor",
	);
	
	my %users = map { $_ => 1 } (@$users_artist, @$users_label, @$users_editor);
	my @users = keys %users;

	printf "Processing subscriptions for %d editors\n",
		scalar @users
		if $self->{'verbose'};

	for my $uid (@users)
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
	my $labelsubs = $self->GetSubscribedLabels;
	my $editorsubs = $self->GetSubscribedEditors;
	
	if (not @$subs and not @$labelsubs and not @$editorsubs)
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
		# Thus we don't go to all the trouble of looking for edits, and
		# we don't send an e-mail, but we *do* update the "lastmodsent" values
		# for this user.
		@$subs = ();
		@$editorsubs = ();
	}

	my $text = "";
	my $editorstext = "";
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

		require ModDefs;
		my $open = $self->CountArtistEdits(
			$sql,
			artist => $sub->{'artist'},
			status => &ModDefs::STATUS_OPEN,
			minid => $sub->{'lastmodsent'}+1,
			maxid => $self->{THRESHOLD_MODID},
		);
		my $applied = $self->CountArtistEdits(
			$sql,
			artist => $sub->{'artist'},
			status => &ModDefs::STATUS_APPLIED,
			minid => $sub->{'lastmodsent'}+1,
			maxid => $self->{THRESHOLD_MODID},
		);

		next if $open == 0 and $applied == 0;

		printf "A=%d '%s' open=%d applied=%d\n",
			$sub->{'artist'}, $sub->{'name'},
			$open, $applied,
			if $self->{'verbose'};
		
		my $res = $sub->{'resolution'} ? " ($sub->{'resolution'})" : "";
		$text .= "$sub->{'name'}$res ($open open, $applied applied)\n"
			. "$root/mod/search/pre/artist.html"
			. "?artistid=$sub->{'artist'}\n\n";
	}

	for my $sub (@$editorsubs)
	{
		# Find edits for this editor which are
		# > lasteditsent and <= THRESHOLD_MODID
		
		require ModDefs;
		my $open = $self->CountEditorEdits(
			$sql,
			editor => $sub->{'subscribededitor'},
			status => &ModDefs::STATUS_OPEN,
			minid => $sub->{'lasteditsent'}+1,
			maxid => $self->{THRESHOLD_MODID},
			);
		
		my $applied = $self->CountEditorEdits(
			$sql,
			editor => $sub->{'subscribededitor'},
			status => &ModDefs::STATUS_APPLIED,
			minid => $sub->{'lasteditsent'}+1,
			maxid => $self->{THRESHOLD_MODID},
		);
		
		next if $open == 0 and $applied == 0;
		
		printf "A=%d '%s' open=%d applied=%d\n",
			$sub->{'subscribededitor'}, $sub->{'name'},
			$open, $applied,
			if $self->{'verbose'};
		
		$editorstext .= "$sub->{'name'} ($open open, $applied applied)\n"
					 . "All Edits: $root/mod/search/pre/editor.html"
					 . "?userid=$sub->{'subscribededitor'}\n"
					 . "Open Edits: $root/mod/search/pre/editor-open.html"
					 . "?userid=$sub->{'subscribededitor'}\n\n";
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
		$sql->Do(
			"DELETE FROM moderator_subscribe_label
			WHERE moderator = ? AND (deletedbymod <> 0 OR mergedbymod <> 0)",
			$self->GetUser,
		);
		$sql->Do(
			"UPDATE moderator_subscribe_label
			SET lastmodsent = ? WHERE moderator = ?",
			$self->{THRESHOLD_MODID},
			$self->GetUser,
		);
		$sql->Do(
			"UPDATE editor_subscribe_editor
			SET lasteditsent = ? WHERE editor = ?",
			$self->{THRESHOLD_MODID},
			$self->GetUser,
		);
	}

	if ($text eq "" and $editorstext eq "")
	{
		print "No edits for subscribed artists, labels and editors\n"
			if $self->{'verbose'};
		return;
	}

	my $textbody = <<EOF;
This is a notification that edits have been added for artists, labels and
editors to whom you subscribed on the MusicBrainz web site.
To view or edit your subscription list, please use the following link:
$root/user/subscriptions.html

To see all open edits for your subscribed artists, see this link:
$root/mod/search/pre/subscriptions.html
EOF
	;

	if ($text =~ /\S/) 
	{
		$textbody .= <<EOF

The changes to your subscribed artists are as follows:
------------------------------------------------------------------------

$text
EOF
		;
	}

	if ($editorstext =~ /\S/)
	{
		$textbody .= <<EOF

The changes to your subscribed editors are as follows:
------------------------------------------------------------------------

$editorstext
EOF
		;
	}

	$textbody .= <<EOF
------------------------------------------------------------------------
Please do not reply to this message.  If you need help, please see
$root/doc/ContactUs

EOF
	;

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		# Sender: not required
		From		=> 'MusicBrainz Subscription Robot <noreply@musicbrainz.org>',
		# To: $user (automatic)
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Edits for your subscriptions",
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

sub CountArtistEdits
{
	my ($self, $sql, %opts) = @_;

	my $key = "CountArtistEdits s=$opts{status} id=$opts{minid}-$opts{maxid}";
	if (my $t = $self->{_cache_}{$key})
	{
		return $t->{ $opts{artist} } || 0;
	}

	printf "Counting edits by artist: s=%d %d <= id <= %d\n",
		$opts{status},
		$opts{minid},
		$opts{maxid},
		if $self->{'verbose'};

	my %counts;
	{
		my $rows = $sql->SelectListOfLists(
			"SELECT artist, COUNT(*) FROM moderation_all
			WHERE status = ?
			AND id BETWEEN ? AND ?
			GROUP BY artist",
			$opts{status},
			$opts{minid},
			$opts{maxid},
		);
		%counts = map { $_->[0] => $_->[1] } @$rows;
	}

	printf "Got counts of edits by artist (%d artists)\n",
		scalar(keys %counts),
		if $self->{'verbose'};

	$self->{_cache_}{$key} = \%counts;
	return $counts{ $opts{artist} } || 0;
}

sub CountEditorEdits
{
	my ($self, $sql, %opts) = @_;
	
	my $key = "CountEditorEdits s=$opts{status} id=$opts{minid}-$opts{maxid}";
	if (my $t = $self->{_cache_}{$key})
	{
		return $t->{ $opts{editor} } || 0;
	}
	
	printf "Counting edits by editor: s=%d %d <= id <= %d\n",
		$opts{status},
		$opts{minid},
		$opts{maxid},
		if $self->{'verbose'};
	
	my %counts;
	{
		my $rows = $sql->SelectListOfLists(
			"SELECT moderator, COUNT(*) FROM moderation_all
			WHERE status = ?
			AND id BETWEEN ? AND ?
			GROUP BY moderator",
			$opts{status},
			$opts{minid},
			$opts{maxid},
		);
		%counts = map { $_->[0] => $_->[1] } @$rows;
	}
	
	printf "Got counts of edits by editor (%d editors)\n",
		scalar(keys %counts),
		if $self->{'verbose'};
		
	$self->{_cache_}{$key} = \%counts;
	return $counts{ $opts{editor} } || 0;
}

1;
# eof UserSubscription.pm
