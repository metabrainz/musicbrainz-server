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

package MusicBrainz::Server::Moderation::MOD_EDIT_RELEASES;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Release Events (old version)" }
(__PACKAGE__)->RegisterHandler;

sub _EncodeText
{
	my $t = $_[0];
	$t =~ s/\$/\$26/g;
	$t =~ s/ /\$20/g;
	$t =~ s/=/\$3D/g;
	return $t;
}

sub _DecodeText
{
	my $t = $_[0];
    return undef if (!defined $t);
	$t =~ s/\$20/ /g;
	$t =~ s/\$3D/=/g;
	$t =~ s/\$26/\$/g;
	return $t;
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{"album"} or die;
	my @adds = @{ $opts{"adds"} || [] };
	my @edits = @{ $opts{"edits"} || [] };
	my @removes = @{ $opts{"removes"} || [] };

	use Album;
	my %new = (
		albumid => $al->GetId,
		albumname => $al->GetName,
	);	

	my $i;
	$i = 0;
	for my $row (@adds)
	{
		die unless $row->GetAlbum == $al->GetId;
		$row->InsertSelf;
		$new{"add".$i++} = sprintf "d=%s c=%d id=%d l=%d n=%s b=%s f=%d",
			$row->GetSortDate,
			$row->GetCountry,
			$row->GetId,
			$row->GetLabel,
			_EncodeText($row->GetCatNo),
			_EncodeText($row->GetBarcode),
			$row->GetFormat;
	}
	
	$i = 0;
	for my $row (@edits)
	{	
		my $obj = $row->{"object"};
		die unless $obj->GetAlbum == $al->GetId;

		my $old = sprintf "d=%s c=%d id=%d l=%d n=%s b=%s f=%d",
			$obj->GetSortDate,
			$obj->GetCountry,
			$obj->GetId,
			$obj->GetLabel,
			_EncodeText($obj->GetCatNo),
			_EncodeText($obj->GetBarcode),
			$obj->GetFormat;

		$obj->SetCountry($row->{"country"});
		$obj->SetYMD(@$row{qw( year month day )});
		$obj->SetLabel($row->{label});
		$obj->SetCatNo($row->{catno});
		$obj->SetBarcode($row->{barcode});
		$obj->SetFormat($row->{format});

		my $new = sprintf "nd=%s nc=%d nl=%d nn=%s nb=%s nf=%d",
			$obj->GetSortDate,
			$obj->GetCountry,
			$obj->GetLabel,
			_EncodeText($obj->GetCatNo),
			_EncodeText($obj->GetBarcode),
			$obj->GetFormat;

		$new{"edit".$i++} = "$old $new";
	}
	
	$i = 0;	
	for my $row (@removes)
	{
		die unless $row->GetAlbum == $al->GetId;
		$new{"remove".$i++} = sprintf "d=%s c=%d id=%d l=%d n=%s b=%s f=%d",
			$row->GetSortDate,
			$row->GetCountry,
			$row->GetId,
			$row->GetLabel,
			_EncodeText($row->GetCatNo),
			_EncodeText($row->GetBarcode),
			$row->GetFormat;
	}

	return $self->SuppressInsert
		unless @adds or @edits or @removes;

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
		my $r = +{ split /[ =]/, $v };
		$r->{"n"} = _DecodeText($r->{"n"});
		$r->{"b"} = _DecodeText($r->{"b"});
		push @adds, $r;
	}
	
	for (my $i=0; ; ++$i)
	{
		my $v = $new->{"edit$i"} or last;
		my $r = +{ split /[ =]/, $v };
		$r->{"n"} = _DecodeText($r->{"n"});
		$r->{"b"} = _DecodeText($r->{"b"});
		$r->{"nn"} = _DecodeText($r->{"nn"});
		$r->{"nb"} = _DecodeText($r->{"nb"});
		push @edits, $r;
	}
	
	for (my $i=0; ; ++$i)
	{
		my $v = $new->{"remove$i"} or last;
		my $r = +{ split /[ =]/, $v };
		$r->{"n"} = _DecodeText($r->{"n"});
		$r->{"b"} = _DecodeText($r->{"b"});
		push @removes, $r;
	}
	
	$self->{"adds"} = \@adds;
	$self->{"edits"} = \@edits;
	$self->{"removes"} = \@removes;
	
	# check if release still exists.
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{"albumid"}, 1);

	# fallback to stored name if release cannot be loaded	
	$self->{"albumname"} = $new->{"albumname"}; 
}

sub DetermineQuality
{
	my $self = shift;

	my $rel = Album->new($self->{DBH});
	$rel->SetId($self->{rowid});
	if ($rel->LoadFromId())
	{
        return $rel->GetQuality();        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub IsAutoEdit
{
	my ($self) = @_;

	# Adding of a completely new release events is auto-approved only for autoeditors
	my $adds = @{ $self->{"adds"} };
	return 0 if ($adds);

	# If data is being removed, never autoedit
	my $removes = @{ $self->{"removes"} };
	return 0 if ($removes);

	# see ticket #1623, entering more complete release events is
	# an autoedit.
	my $edits = 0;
	for my $t (@{ $self->{"edits"} })
	{
		my ($origyear, $origmonth, $origday) = map { 0+$_ } split "-", $t->{"d"};
		my ($newyear, $newmonth, $newday) = map { 0+$_ } split "-", $t->{"nd"};
		my ($origcountry, $newcountry) = ($t->{"c"}, $t->{"nc"});
		my ($origlabel, $newlabel) = ($t->{"l"}, $t->{"nl"});
		my ($origcatno, $newcatno) = ($t->{"n"}, $t->{"nn"});
		my ($origbarcode, $newbarcode) = ($t->{"b"}, $t->{"nb"});
		my ($origformat, $newformat) = ($t->{"f"}, $t->{"nf"});


		# If is the user changing the existing data, the edit
		# shouldn't be auto-approved.
		return 0 if (
			($origday && ($newday != $origday)) ||
			($origmonth && ($newmonth != $origmonth)) ||
			($origyear && ($newyear != $origyear)) ||
			($origcountry && ($newcountry != $origcountry)) ||
			($origlabel && ($newlabel != $origlabel)) ||
			($origcatno && ($newcatno ne $origcatno)) ||
			($origbarcode && ($newbarcode ne $origbarcode)) ||
			($origformat && ($newformat != $origformat))
			);
	}

	# Adding more complete data is auto approved for all
	return 1;
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

	require MusicBrainz::Server::Country;
	my $country = MusicBrainz::Server::Country->new($self->{DBH});

	require Label;
	my $label = Label->new($self->{DBH});

	my @notes;
	my $ok = 0;
	
	$ok = @{ $self->{"adds"} };
	
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

		my $nl = $t->{"n1"};
		if ($nl)
		{
			my $l = $label->newFromId($nl);
			unless ($l)
			{
				push @notes, "Label $nl has already been deleted";
				next;
			}
		}

		if ($r->GetCountry != $t->{'c'}
			or $r->GetSortDate ne $t->{'d'}
			or $r->GetLabel != $t->{'l'}
			or $r->GetCatNo ne $t->{'n'}
			or $r->GetBarcode ne $t->{'b'}
			or $r->GetFormat != $t->{'f'})
		{
			push @notes, "$display has already been changed";
			next;
		}

		unless ($r->Update(date => $t->{"nd"}, country => $t->{"nc"}, label => $t->{"nl"}, catno => $t->{"nn"}, barcode => $t->{"nb"}, format => $t->{"nf"}))
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
