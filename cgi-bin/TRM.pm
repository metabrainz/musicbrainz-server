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

package TRM;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = (TableBase);
@EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

# Accessor functions to set/get the artist id of this album
sub GetTRM
{
   return $_[0]->{trm};
}

sub SetTRM
{
   $_[0]->{trm} = $_[1];
}

sub GetTrackIdsFromTRM
{
   my ($this, $TRM) = @_;
   my ($sql);

   $TRM =~ tr/A-Z/a-z/;
   $sql = Sql->new($this->{DBH});
   return $sql->GetSingleColumn("TRMJoin, TRM", "track",
                                ["TRM.TRM", $sql->Quote($TRM), 
                                 "TRM.id", "TRMJoin.TRM"]);
}

sub GetIdFromTRM
{
   my ($this, $TRM) = @_;
   my ($sql, $id);

   $TRM =~ tr/A-Z/a-z/;
   $sql = Sql->new($this->{DBH});
   ($id) = $sql->GetSingleRow("TRM", ["id"], ["TRM", $sql->Quote($TRM)]);

   return $id;
}

sub GetTRMFromTrackId
{
    my ($this, $id) = @_;
    my (@row, $sql, @ret);

    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select TRM.TRM, TRMJoin.id, TRM.lookupcount 
                          from TRMJoin, TRM
                         where TRMJoin.track = $id and
                               TRMJoin.TRM = TRM.id
                      order by TRM.lookupcount desc|))
    {
        while(@row = $sql->NextRow())
        {
            push @ret, { TRMjoinid=>$row[1],
                         TRM=>$row[0],
                         lookupcount=>$row[2]
                       };
        }
        $sql->Finish();
    }
    return @ret;
}

sub Insert
{
    my ($this, $TRM, $trackid, $clientver) = @_;
    my ($id, $sql);

    $this->{new_insert} = 0;
    $sql = Sql->new($this->{DBH});

    $id = $this->GetIdFromTRM($TRM);
    $TRM = $sql->Quote($TRM);
    $clientver = $sql->Quote($clientver);

    if (!defined $id)
    {
        my $verid;
        
        ($verid) = $sql->GetSingleRow("ClientVersion", ["id"], ["version", $clientver]);
        if (not defined $verid)
        {
            if ($sql->Do(qq/insert into ClientVersion (version) values ($clientver)/))
            {
                $verid = $sql->GetLastInsertId("ClientVersion");
            }
        }

        if ($sql->Do(qq/insert into TRM (TRM, version) values ($TRM, $verid)/))
        {
            $id = $sql->GetLastInsertId("TRM");
            $this->{new_insert} = 1;
        }
    }

    if (defined $id && defined $trackid)
    {
        my ($temp) = $sql->GetSingleRow("TRMJoin, TRM", 
                                         ["TRMJoin.id"], 
                                         ["TRMJoin.track", $trackid,
                                          "TRMJoin.TRM", "TRM.id",
                                          "TRM.TRM", $TRM]);
        if (!defined $temp)
        {
            $sql->Do(qq/insert into TRMJoin (TRM, track) values 
                       ($id, $trackid)/);
        }
    }
    return $id;
}

# Remove a TRM from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql);

    return undef if (!defined $this->GetId());
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("delete from TRMJoin where TRM = " . $this->GetId());
    $sql->Do("delete from TRM where id = " . $this->GetId());

    return 1;
}

# Remove all the TRM/TRMJoins from the database for a given track id. 
sub RemoveByTrackId
{
    my ($this, $trackid) = @_;
    my ($sql, $sql2, $refcount, @row);

    return undef if (!defined $trackid);
 
    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select TRMJoin.id, TRMJoin.TRM from TRMJoin
                         where TRMJoin.track = $trackid|))
    {
         $sql2 = Sql->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             $sql->Do("delete from TRMJoin where id = $row[0]");
             ($refcount) = $sql2->GetSingleRow("TRMJoin", ["count(*)"],
                                              [ "TRMJoin.TRM", $row[1]]);
             if ($refcount == 0)
             {
                $sql->Do("delete from TRM where id=$row[1]");
             }
         }
         $sql->Finish;
    }

    return 1;
}

# Remove a specific single TRM from a given track
sub RemoveTRMByTRMJoin
{
    my ($this, $joinid) = @_;
    my ($sql, $sql2, $refcount, @row);

    return undef if (!defined $joinid);
 
    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select TRMJoin.id, TRMJoin.TRM from TRMJoin
                         where TRMJoin.id = $joinid|))
    {
         $sql2 = Sql->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             $sql->Do("delete from TRMJoin where id = $row[0]");
             ($refcount) = $sql2->GetSingleRow("TRMJoin", ["count(*)"],
                                              [ "TRMJoin.TRM", $row[1]]);
             if ($refcount == 0)
             {
                $sql->Do("delete from TRM where id=$row[1]");
             }
         }
         $sql->Finish;
    }

    return 1;
}
sub AssociateTRM
{
    my ($this, $TRM, $name, $artist, $album) = @_;
    my ($id, $sql, @row);

    $sql = Sql->new($this->{DBH});
    $artist = $sql->Quote($artist);
    $album = $sql->Quote($album);
    $name = $sql->Quote($name);
    if ($sql->Select(qq\select Track.id 
                          from Artist, Album, Track, AlbumJoin
                         where Artist.name ilike $artist and 
                               Album.name ilike $album and
                               Track.name ilike $name and 
                               Track.artist = Artist.id and
                               Track.id = AlbumJoin.track and 
                               AlbumJoin.album = Album.id\))
    {
       while(@row = $sql->NextRow())
       {
           $this->Insert($TRM, $row[0]);
       }
       $sql->Finish();
       
       return 1;
    }
    return 0;
}

# Load all the trms for a given track and return an array of references to trms
# objects. Returns undef if error occurs
sub LoadFull
{
   my ($this, $track) = @_;
   my (@info, $query, $sql, @row, $trm);

   $sql = Sql->new($this->{DBH});
   $query = qq|select trm.id, trm.trm
                 from trm, trmjoin
                where trmjoin.track = $track and
                      trmjoin.trm = trm.id|;
   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
           $trm = TRM->new($this->{DBH});
           $trm->SetId($row[0]);
           $trm->SetTRM($row[1]);
           push @info, $trm;
       }
       $sql->Finish;

       return \@info;
   }

   return undef;
}

sub IncrementLookupCount
{
	my ($class, $trm) = @_;
	
	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"TRM::IncrementLookupCount",
		$trm,
	);
}

1;
# vi: set ts=4 sw=4 :
