#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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
use DBDefs;
use ModDefs;
use Moderation;
use Track;
use Artist;
use Album;
use Insert;

package AddTrackModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Album: <a href=\"/showalbum.html?albumid=" .
          "$this->{rowid}\">" . $this->GetPrev() . "</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   my (@data) = split(/\n/, $this->{new});
   my $out;

   $out = qq\Name: <span class="bold">$data[0]</span>\;
   $out .= qq\ Track: <span class="bold">$data[1]</span>\;
   if ($this->GetArtist() == Artist::VARTIST_ID)
   {
       $out .= qq\<br>Artist: <span class="bold">$data[3]</span>\;
       if (defined $data[4])
       {
          $out .= qq\ (<span class="bold">$data[4]</span>)\;
       }
   }
   return $out;
}

sub DeniedAction
{
}

# The approved action functions in this module, all load the 
# data from the DB again, even though the data is already loaded
# into the current object. The following ApprovedAction functions
# ought to be improved at a later point in time to avoid this.
sub ApprovedAction
{
   my ($this, $id) = @_;
   my (@data, $in, $tid, $status, %info);

   $status = ModDefs::STATUS_ERROR;
   $in = Insert->new($this->{DBH});

   # Is this a single artist that we're adding a track to?
   if ($this->GetArtist() != Artist::VARTIST_ID)
   {
       my ($trackname, $tracknum, $album) = split(/\n/, $this->GetNew());

       # Single artist album
       $info{artistid} = $this->GetArtist();
       $info{albumid} = $album;
       $info{tracks} =
         [
            {
               track => $trackname,
               tracknum => $tracknum
            }
         ];

       $status = ModDefs::STATUS_APPLIED 
           if (defined $in->Insert(\%info));
   }
   else
   {
       my ($newartistid);
       my ($trackname, $tracknum, $album, $artistname, $sortname) = 
             split(/\n/, $this->GetNew());

       # Multiple artist album
       $info{artistid} = Artist::VARTIST_ID;
       $info{albumid} = $album;
       $info{tracks} =
         [
            {
               track => $trackname,
               tracknum => $tracknum,
               artist => $artistname,
               sortname => $sortname
            }
         ];

       $status = ModDefs::STATUS_APPLIED 
           if (defined $in->Insert(\%info));
   }

   return $status;
}

package MergeArtistModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: <a href=\"/showartist.html?artistid" . 
          "=$this->{rowid}\">" . $this->{prev} . "</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   my $out;
   my $new = $this->GetNew(); 
   if ($new =~ /\n/)
   {
      my (@data) = split(/\n/, $new);
      $out = qq\Artist: <span class="bold">$data[1]</span>\;
      $out .= qq\ (<span class="bold">$data[0]</span>)\;
   }
   else
   {
      $out = qq\Artist: <a href="/showartist.html?artistid=\ .
             $this->GetArtist() . qq\"><span class="bold">$new</span></a>\;
   }
   return $out;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $id) = @_;
   my (@row, $prevval, $rowid, $status, $newid);
   my ($name, $sortname);

   $status = ModDefs::STATUS_ERROR;
   my $sql = Sql->new($this->{DBH});

   $prevval = $this->GetPrev();
   $rowid = $this->GetRowId();
   $name = $this->GetNew();
   if ($name =~ /\n/)
   {
      ($sortname, $name) = split /\n/, $name;
   }

   # Check to see that the old value is still what we think it is
   if ($sql->Select(qq/select name from Artist where id = $rowid/))
   {
       @row = $sql->NextRow();
       $sql->Finish;
       if ($row[0] eq $prevval)
       {
          $name = $sql->Quote($name);
          # Check to see that the new artist is still around 
          if ($sql->Select(qq/select id from Artist where name = $name/))
          {
              @row = $sql->NextRow();
              $newid = $row[0];
              $status = ModDefs::STATUS_APPLIED;
              $sql->Finish;
          }
          else
          {
              $status = ModDefs::STATUS_FAILEDDEP;
          }
       }
       else
       {
          $status = ModDefs::STATUS_FAILEDDEP;
       }
   }

   if ($status == ModDefs::STATUS_APPLIED)
   {
       $sql->Do(qq/update Album set artist = $newid where artist = $rowid/);
       $sql->Do(qq/update Track set artist = $newid where artist = $rowid/);
       $sql->Do("delete from Artist where id = $rowid");
       $sql->Do("update Changes set artist = $newid where artist = $rowid");

       my $al = Alias->new($this->{DBH});
       $al->SetTable("ArtistAlias");
       $al->Insert($newid, $prevval);
   }

   return $status;
}

package EditModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   my $type = $this->GetType();
   my $prev = $this->GetPrev();
   if ($type == ModDefs::MOD_EDIT_ARTISTNAME ||
       $type == ModDefs::MOD_EDIT_ARTISTSORTNAME)
   {
       return "Old: <a href=\"/showartist.html?artistid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == ModDefs::MOD_EDIT_ALBUMNAME)
   {
       return "Old: <a href=\"/showalbum.html?albumid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == ModDefs::MOD_EDIT_TRACKNAME)
   {
       return "Old: <a href=\"/showtrack.html?trackid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == ModDefs::MOD_EDIT_TRACKNUM)
   {
       return "Old: <a href=\"/showtrack.html?albumjoinid=$this->{rowid}\">$prev</a>";
   }
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $prevval, $newval);
   my ($status, $table, $column, $datarowid);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   
   $table = $this->GetTable();
   $column = $this->GetColumn();
   $prevval = $this->GetPrev();
   $newval = $sql->Quote($this->GetNew());
   $datarowid = $this->GetRowId();

   if ($sql->Select(qq/select $column from $table where id = $datarowid/))
   {
       @row = $sql->NextRow;
       if ($row[0] eq $prevval)
       {
           $sql->Do(qq/update $table set $column = $newval  
                               where id = $datarowid/); 
           if ($table eq 'Artist' && $column eq 'Name')
           {
               my $al = Alias->new($this->{DBH});
               $al->SetTable("ArtistAlias");
               $al->Insert($datarowid, $prevval);
           }
           $status = ModDefs::STATUS_APPLIED;
       }
       else
       {
           $status = ModDefs::STATUS_FAILEDDEP;
       }
       $sql->Finish;
   }

   return $status;
}

package MoveAlbumModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   if ($this->{type} == ModDefs::MOD_MOVE_ALBUM)
   {
      return "Old: <a href=\"/showartist.html?artistid=" .
             "$this->{artist}\">$this->{prev}</a>"; 
   }
   if ($this->{type} == ModDefs::MOD_MAC_TO_SAC)
   {
      return "Old: <a href=\"/showalbum.html?albumid=" .
             "$this->{rowid}\">$this->{prev}</a>";
   }
}

sub ShowNewValue
{
   my ($this) = @_;

   my $out;
   my $new = $this->GetNew(); 
   if ($new =~ /\n/)
   {
      my (@data) = split(/\n/, $new);
      $out = qq\Artist: <span class="bold">$data[1]</span>\;
      $out .= qq\ (<span class="bold">$data[0]</span>)\;
   }
   else
   {
      $out = qq\Artist: <span class="bold">$new</span>\;
   }

   return $out;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $id) = @_;
   my ($sql, @row, $rowid, $status, $ar, $newid);
   my ($name, $sortname, $qname);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   $name = $this->GetNew();
   if ($name =~ /\n/)
   {
      ($sortname, $name) = split /\n/, $name;
   }
   else
   {
      $sortname = $name;
   }
   $qname = $sql->Quote($name);
   $rowid = $this->GetRowId();

   if ($sql->Select(qq/select id from Artist where name = $qname/))
   {
       @row = $sql->NextRow;
       $newid = $row[0];
       $sql->Finish;
   }
   else
   {
       $ar = Artist->new($this->{DBH});
       $ar->SetName($name);
       $ar->SetSortName($sortname);
       $newid = $ar->Insert();
   }
   if ($sql->Select(qq/select track from AlbumJoin where Album = $rowid/))
   {
       while(@row = $sql->NextRow)
       {
           $sql->Do(qq/update Track set artist = $newid 
                       where id = $row[0]/);
       }

       $sql->Do(qq/update Album set artist = $newid where id = $rowid/);
       $status = ModDefs::STATUS_APPLIED;
       $sql->Finish;
   }

   return $status;
}

package SACToMACModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: <a href=\"/showalbum.html?albumid=" .
          "$this->{rowid}\">$this->{prev}</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $id) = @_;
   my ($status, $sql);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   $sql->Do("update Album set Artist = " . 
                    Artist::VARTIST_ID . "  where id = " . $this->GetRowId());
   $status = ModDefs::STATUS_APPLIED; 

   return $status;
}

package ChangeTrackArtistModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: <a href=\"/showtrack.html?trackid=" . 
          "$this->{rowid}\">$this->{prev}</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   my $out;
   my $new = $this->GetNew(); 
   if ($new =~ /\n/)
   {
      my (@data) = split(/\n/, $new);
      $out = qq\Artist: <span class="bold">$data[1]</span>\;
      $out .= qq\ (<span class="bold">$data[0]</span>)\;
   }
   else
   {
      $out = qq\Artist: <span class="bold">$new</span>\;
   }

   return $out;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $id) = @_;
   my ($sql, @row, $rowid, $status, $ar, $newid);
   my ($name, $sortname, $qname);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   $name = $this->GetNew();
   $rowid = $this->GetRowId();

   if ($name =~ /\n/)
   {
      ($sortname, $name) = split /\n/, $name;
   }
   else
   {
      $sortname = $name;
   }
   $qname = $sql->Quote($name);

   if ($sql->Select(qq/select id from Artist where name = $qname/))
   {
       @row = $sql->NextRow;
       $newid = $row[0];
       $sql->Finish;
   }
   else
   {
       $ar = Artist->new($this->{DBH});
       $ar->SetName($name);
       $ar->SetSortName($sortname);
       $newid = $ar->Insert();
   }

   $sql->Do("update Track set Artist = $newid where id = $rowid");
   $status = ModDefs::STATUS_APPLIED;

   return $status;
}

package RemoveTrackModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   my ($name, $id) = split /\n/, $this->{prev};

   if ($this->GetStatus() == ModDefs::STATUS_APPLIED)
   {
       return "Old: $name";
   }
   else
   {
       return "Old: <a href=\"/showtrack.html?trackid=$this->{rowid}\">$name</a>";
   }   
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($sql, $trackid);
   my ($status, $album);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   $trackid = $this->GetRowId();
   $album = $this->GetPrev();
   $album =~ s/^.*?\n//s;

   # Remove the album join for this track
   $sql->Do(qq/delete from AlbumJoin where Album = $album and
                    track = / . $this->GetRowId());

   # Now remove the track. The track will only be removed
   # if there are not more references to it.
   my $tr = Track->new($this->{DBH});
   $tr->SetId($trackid);
   if ($tr->Remove())
   {
       $status = ModDefs::STATUS_APPLIED;
   }
   else
   {
       $status = ModDefs::STATUS_FAILEDDEP;
   }


   return $status;
}

package RemoveAlbumModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: <a href=\"/showalbum.html?albumid=" .
          "$this->{rowid}\">$this->{prev}</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($sql, $trackid);
   my ($status, $album);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   $album = $this->GetRowId();

   my $al = Album->new($this->{DBH});
   $al->SetId($album);
   if ($al->Remove())
   {
       $status = ModDefs::STATUS_APPLIED;
   }
   else
   {
       $status = ModDefs::STATUS_FAILEDDEP;
   }

   return $status;
}

package RemoveArtistModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   my ($name, $id) = split /\n/, $this->{prev};

   if ($this->GetStatus() == ModDefs::STATUS_APPLIED)
   {
       return "Old: " . $this->{prev};
   }
   else
   {
       return "Old: <a href=\"/showartist.html?artistid=$this->{rowid}\">$this->{prev}</a>";
   }   
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($sql, $trackid);
   my ($status);

   $status = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   
   # Now remove the Artist. The Artist will only be removed
   # if there are not more references to it.
   my $ar = Artist->new($this->{DBH});
   $ar->SetId($this->GetRowId());
   if ($ar->Remove())
   {
       $status = ModDefs::STATUS_APPLIED;
   }
   else
   {
       $status = ModDefs::STATUS_FAILEDDEP;
   }

   return $status;
}

package RemoveArtistAliasModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: <a href=\"/showaliases.html?artistid=" .
          "$this->{artist}\">$this->{prev}</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($al, $status);

   $status = ModDefs::STATUS_ERROR;

   $al = Alias->new($this->{DBH});
   $al->SetTable("ArtistAlias");
   if ($al->Remove($this->GetRowId()))
   {
       $status = ModDefs::STATUS_APPLIED;
   }
   else
   {
       $status = ModDefs::STATUS_FAILEDDEP;
   }

   return $status;
}

package AddArtistAliasModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Aliases: <a href=\"/showaliases.html?artistid=" . 
          "$this->{rowid}\">$this->{prev}</a>";
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($al, $status);

   $status = ModDefs::STATUS_ERROR;

   $al = Alias->new($this->{DBH});
   $al->SetTable("ArtistAlias");
   $status = ModDefs::STATUS_APPLIED
        if (defined $al->Insert($this->GetRowId(), $this->GetNew()));

   return $status;
}

package RemoveDiskidModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   if ($this->GetStatus != ModDefs::STATUS_APPLIED)
   {
       return "Old: <a href=\"/showalbum.html?diskid=" .
              "$this->{prev}\">$this->{prev}</a>";
   }
   else
   {
       return "Old: $this->{prev}";
   }
}

sub ShowNewValue
{
   my ($this) = @_;

   return qq\New: <span class="bold">$this->{new}</span>\;
}

sub DeniedAction
{
}

sub ApprovedAction
{
   my ($this, $rowid) = @_;
   my ($status);

   $status = ModDefs::STATUS_ERROR;

   my $di = Diskid->new($this->{DBH});
   if ($di->Remove($this->GetPrev()))
   {
      $status = ModDefs::STATUS_APPLIED;
   }
   else
   {
      $status = ModDefs::STATUS_FAILEDDEP;
   }

   return $status;
}
