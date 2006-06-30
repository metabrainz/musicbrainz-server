#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

package MusicBrainz::Server::Moderation::MOD_EDIT_RELEASES;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Release Events" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'album'} or die;
	my $adds = $opts{'adds'} || [];
	my $edits = $opts{'edits'} || [];
	my $removes = $opts{'removes'} || [];

	my %new = (
		albumid => $al->GetId,
		albumname => $al->GetName,
	);
	my $i;

	$i=0;
	for my $row (@$adds)
	{
		die unless $row->GetAlbum == $al->GetId;
		$row->InsertSelf;
		$new{"add".$i++} = sprintf "d=%s c=%d id=%d",
			$row->GetSortDate,
			$row->GetCountry,
			$row->GetId;
	}

	$i=0;
	for my $row (@$edits)
	{
		my $obj = $row->{'object'};
		die unless $obj->GetAlbum == $al->GetId;

		my $old = sprintf "d=%s c=%d id=%d",
			$obj->GetSortDate,
			$obj->GetCountry,
			$obj->GetId;

		$obj->SetCountry($row->{'country'});
		$obj->SetYMD(@$row{qw( year month day )});

		my $new = sprintf "nd=%s nc=%d",
			$obj->GetSortDate,
			$obj->GetCountry;

		$new{"edit".$i++} = "$old $new";
	}

	$i=0;
	for my $row (@$removes)
	{
		die unless $row->GetAlbum == $al->GetId;
		$new{"remove".$i++} = sprintf "d=%s c=%d id=%d",
			$row->GetSortDate,
			$row->GetCountry,
			$row->GetId;
	}

	return $self->SuppressInsert
		unless @$adds or @$edits or @$removes;

	$self->SetArtist($al->GetArtist);
	$self->SetPrev($al->GetName);
	$self->SetTable("album");
	$self->SetColumn("releases");
	$self->SetRowId($al->GetId);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	my (@adds, @edits, @removes);
	
	$self->{"new_unpacked"} = $self->ConvertNewToHash($self->GetNew)
		or die;

	# extract albumid and changed release events from new_unpacked hash
	my $new = $self->{'new_unpacked'};	

	for (my $i=0; ; ++$i)
	{
		my $v = $new->{"add$i"} or last;
		push @adds, +{ split /[ =]/, $v };
	}
	
	for (my $i=0; ; ++$i)
	{
		my $v = $new->{"edit$i"} or last;
		push @edits, +{ split /[ =]/, $v };
	}
	
	for (my $i=0; ; ++$i)
	{
		my $v = $new->{"remove$i"} or last;
		push @removes, +{ split /[ =]/, $v };
	}
	
	$self->{"adds"} = \@adds;
	$self->{"edits"} = \@edits;
	$self->{"removes"} = \@removes;
	
	# check if release still exists.
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{"albumid"}, 1);

	# fallback to stored name if release cannot be loaded	
	$self->{"albumname"} = $new->{"albumname"}; 
}

sub IsAutoMod
{
	my ($self, $user_is_automod) = @_;
	my $edits = 0;
	
	# we do not auto-approve adding new release events.
	# my $adds = @{ $self->{"adds"} }; 
	
	# TODO: fix code, since it has ill effects for autoeditors
	# -- see #1623
	
	# for my $t (@{ $self->{"edits"} })
	# {
	# 	my @d = map { 0+$_ } split "-", $t->{"d"};
	#     my @nd = map { 0+$_ } split "-", $t->{"nd"};
	#     $edits++
	# 	if $d[0] != $nd[0] or (($d[1] or !$nd[1]) and ($d[1] != $nd[1] or $d[2] or !$nd[2]));
	# }
	
	my $removes = @{ $self->{"removes"} };
	
	(not $removes and (not $edits or $user_is_automod));
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require MusicBrainz::Server::Release;
	my $rel = MusicBrainz::Server::Release->new($self->{DBH});

	for my $list (qw( adds edits removes ))
	{
		for my $t (@{ $self->{$list} })
		{
			$rel->SetId($t->{"id"});
			$rel->UpdateModPending($adjust);
		}
	}
}

sub ApprovedAction
{
	my $self = shift;
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->{DBH});

	my @notes;
	my $ok = @{ $self->{"adds"} };

	require MusicBrainz::Server::Country;
	my $country = MusicBrainz::Server::Country->new($self->{DBH});

	# Update the "edits" list
	for my $t (@{ $self->{"edits"} })
	{
		my $r = $release->newFromId($t->{"id"});
		my $c = $country->newFromId($t->{"c"});
		my $name = ($c ? $c->GetName : "?");
		my $display = "'$t->{d} - $name'";

		unless ($r)
		{
			push @notes, "$display has already been deleted";
			next;
		}

		if ($r->GetCountry != $t->{'c'}
			or $r->GetSortDate ne $t->{'d'})
		{
			push @notes, "$display has already been changed";
			next;
		}

		unless ($r->Update(date => $t->{"nd"}, country => $t->{"nc"}))
		{
			push @notes, "Failed to update $display";
			next;
		}

		++$ok;
	}

	# Remove the "removes" list
	for my $t (@{ $self->{"removes"} })
	{
		$release->RemoveById($t->{"id"})
			and ++$ok, next;
		my $c = $country->newFromId($t->{"c"});
		my $name = ($c ? $c->GetName : "?");
		my $display = "'$t->{d} - $name'";
		push @notes, "$display has already been deleted";
	}

	$self->InsertNote(MODBOT_MODERATOR, (join "\n", @notes))
		if @notes;

	($ok ? STATUS_APPLIED : STATUS_FAILEDPREREQ);
}

sub DeniedAction
{
	my $self = shift;
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->{DBH});

	# Remove the "adds" list
	for my $t (@{ $self->{"adds"} })
	{
		$release->RemoveById($t->{"id"});
		# If the RemoveById failed, it's probably because that row has already
		# been deleted.  Fine - we wanted to delete it anyway.
	}
}

1;
# eof MOD_EDIT_RELEASES.pm
