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

package Discid;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Carp qw( croak );
use DBDefs;

# Accessor functions
sub GetAlbum
{
   return $_[0]->{album};
}

sub SetAlbum
{
   $_[0]->{album} = $_[1];
}

sub GetDiscid
{
   return $_[0]->{discid};
}

sub SetDiscid
{
   $_[0]->{discid} = $_[1];
}

sub GetTOC
{
   return $_[0]->{toc};
}

sub SetTOC
{
   $_[0]->{toc} = $_[1];
}

# Called by QuerySupport::GetCDInfoMM2 (i.e. the GetCDInfo RDF calls)

sub GenerateAlbumFromDiscid
{
	my ($this, $rdf, $id, $numtracks, $toc) = @_;

	return $rdf->ErrorRDF("No Discid given.") if (!defined $id);

	# Check to see if the album is in the main database
	if (my $album = $this->GetAlbumFromDiscid($id))
	{
		return $rdf->CreateAlbum(0, $album);
	}

	if (!defined $toc || !defined $numtracks)
	{
		return $rdf->CreateStatus(0);
	}

	# Ok, no freedb entries were found. Can we find a fuzzy match?
	require Discid;
	my $di = Discid->new($this->{DBH});
	my @albums = $di->_FindFuzzy($numtracks, $toc);
	if (@albums)
	{
		return $rdf->CreateAlbum(1, @albums);
	}

	# No fuzzy matches either. Let's pull the records
	# from freedb.org and insert it into the db if we find it.
	require FreeDB;
	my $fd = FreeDB->new($this->{DBH});
	my $ref = $fd->Lookup($id, $toc);
	if (defined $ref)
	{
		$fd->InsertForModeration($ref);
		return $rdf->CreateFreeDBLookup($ref);
	}

	# No Dice. This CD cannot be found!
	return $rdf->CreateStatus(0);
}

sub GetAlbumFromDiscid
{
    my ($this, $id) = @_;
    my $sql = Sql->new($this->{DBH});

	$sql->SelectSingleValue(
		"SELECT album FROM discid WHERE disc = ?",
		$id,
	);
}

sub GetDiscidFromAlbum
{
    my ($this, $album) = @_;
    my (@row, $sql, @ret);
 
    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select id, disc, toc, modpending 
                          from Discid 
                         where album = $album|))
    {
        while(@row = $sql->NextRow())
        {
            push @ret, { id=>$row[0],
                         discid=>$row[1],
                         toc=>$row[2],
                         modpending=>$row[3] };
        }
    }
	$sql->Finish();
    return @ret;
}

sub Insert
{
    my ($this, $id, $album, $toc) = @_;
    return if (!defined $id || !defined $album || !defined $toc);

	if (my $Discidalbum = $this->GetAlbumFromDiscid($id))
	{
		# Ensure TOC record present
		$this->_InsertTOC($id, $Discidalbum, $toc);
		# Nothing added, so return undef.  Mostly this seems not to matter
		# anyway, since everyone seems to call this sub in void context.
		return undef;
	}

	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"INSERT INTO discid (disc, album, toc) VALUES (?, ?, ?)",
		$id, $album, $toc,
	);
	my $rowid = $sql->GetLastInsertId("discid");

    $this->_InsertTOC($id, $album, $toc);

    return $rowid;
}
 
sub _InsertTOC
{
	my ($this, $Discid, $album, $toc) = @_;

	my $sql = Sql->new($this->{DBH});

	# Check to see if we already have this Discid
	$sql->SelectSingleValue(
		"SELECT id FROM toc WHERE discid = ?",
		$Discid,
	) and return;

	my ($firsttrack, $lasttrack, $leadoutoffset, @trackoffsets) = split / /, $toc;

	my %row = (
		discid	=> $Discid,
		album	=> $album,
		tracks	=> scalar @trackoffsets,
		leadout	=> $leadoutoffset,
		(map {( "track$_" => $trackoffsets[$_-1] )} 1..@trackoffsets),
	);

	my @keys = sort keys %row;
	my @qs = ("?") x @keys;
	my @values = @row{@keys};

	local $" = ", ";
	$sql->Do("INSERT INTO toc (@keys) VALUES (@qs)", @values);
}

sub UpdateAlbum
{
	my $self = shift;

	my $discid = $self->GetDiscid
		or croak "Missing DiscID in UpdateAlbum";
	my $album = $self->GetAlbum
		or croak "Missing album ID in UpdateAlbum";

	my $sql = Sql->new($self->{DBH});
	$sql->Do("UPDATE discid SET album = ? WHERE disc = ?", $album, $discid);
	$sql->Do("UPDATE toc SET album = ? WHERE discid = ?", $album, $discid);
}

# Remove an Discid from the database. Set the id via the accessor function.
sub Remove
{
    my ($this, $id) = @_;
    my ($sql);

    return if (!defined $id);
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("DELETE FROM toc WHERE discid = ?", $id);
    $sql->Do("DELETE FROM discid WHERE disc = ?", $id);
}

sub _FindFuzzy
{
   my ($this, $tracks, $toc) = @_;
   my ($i, $query, @list, @albums, @row, $sth, $sql);

   return @albums if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "abs(Track" . ($i - 2) . " - $list[$i]) < 1000 and ";
   }
   chop($query); chop($query); chop($query); chop($query); chop($query);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
      while(@row = $sql->NextRow())
      {
          push @albums, $row[0];
      }
   }

	$sql->Finish;
   return @albums;
}

# TODO should this ever return undef?
sub LoadFull
{
   my ($this, $album) = @_;
   my (@info, $query, $sql, @row, $disc);

   $sql = Sql->new($this->{DBH});
   $query = qq|select id, album, disc, toc 
                 from Discid
                where album = $album
             order by id|;

   $sql->Select($query);
   {
       for(;@row = $sql->NextRow();)
       {
		   require Discid;
           $disc = Discid->new($this->{DBH});
           $disc->SetId($row[0]);
           $disc->SetAlbum($row[1]);
           $disc->SetDiscid($row[2]);
           $disc->SetTOC($row[3]);
           push @info, $disc;
       }
   }
	$sql->Finish;

   return undef if not @info;
   \@info;
}

# Take in a CD TOC in string format.  Parse it, validate it.
# Returns empty list (false) on failure.  Returns the discid (true)
# on success.  In list context, returns a hash of derived information,
# including: toc tracks firsttrack lasttrack leadoutoffset tracklengths
# trackoffsets discid freedbid.

sub ParseTOC
{
	my ($class, $toc) = @_;

	defined($toc) or return;
	$toc =~ s/\A\s+//;
	$toc =~ s/\s+\z//;
	$toc =~ /\A\d+(?: \d+)*\z/ or return;

	my ($firsttrack, $lasttrack, $leadoutoffset, @trackoffsets)
		= split ' ', $toc;

	$firsttrack == 1 or return;
	$lasttrack >=1 and $lasttrack <= 99 or return;
	@trackoffsets == $lasttrack or return;

	for (($firsttrack + 1) .. $lasttrack)
	{
		$trackoffsets[$_-1] > $trackoffsets[$_-1-1]
			or return;
	}

	$leadoutoffset > $trackoffsets[-1]
		or return;

	my $message = "";
	$message .= sprintf("%02X", $firsttrack);
	$message .= sprintf("%02X", $lasttrack);
	$message .= sprintf("%08X", $leadoutoffset);
	$message .= sprintf("%08X", ($trackoffsets[$_-1] || 0))
		for 1 .. 99;

	use Digest::SHA1 qw(sha1_base64);
	my $discid = sha1_base64($message);
	$discid .= "="; # bring up to 28 characters, like the client
	$discid =~ tr[+/=][._-];

	return $discid unless wantarray;

	my @lengths = map {
		($trackoffsets[$_+1-1] || $leadoutoffset) - $trackoffsets[$_-1]
	} $firsttrack .. $lasttrack;

	require FreeDB;
	my $freedbid = FreeDB::_compute_discid(@trackoffsets, $leadoutoffset);

	return (
		toc				=> $toc,
		tracks			=> scalar @trackoffsets,
		firsttrack		=> $firsttrack,
		lasttrack		=> $lasttrack,
		leadoutoffset	=> $leadoutoffset,
		tracklengths	=> \@lengths,
		trackoffsets	=> \@trackoffsets,
		discid			=> $discid,
		freedbid		=> $freedbid,
	);
}

1;
# eof Discid.pm
