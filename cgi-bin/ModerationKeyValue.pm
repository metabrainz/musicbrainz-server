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
use DBDefs;
use ModDefs;
use Moderation;
use Track;
use Artist;
use Album;
use Insert;

package AddAlbumModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: N/A";
}

sub ShowNewValue
{
   my ($this) = @_;
   my ($new, $name, $id);
   
   $name = "[Error]";
   $new = $this->{new};
   if ($new =~ /^AlbumName=(.*)$/m)
   {
       $name = $1;
   }
   if ($new =~ /^AlbumId=(.*)$/m)
   {
       $id = $1;
   }
   elsif ($new =~ /^_albumid=(.*)$/m)
   {
       $id = $1;
   }

   if ($this->{status} != ModDefs::STATUS_OPEN &&
       $this->{status} != ModDefs::STATUS_APPLIED)
   {
       return "Album: $name";
   }
   else
   {
       return "Album: <a href=\"/showalbum.html?albumid=$id\">$name</a>";
   }
}

sub DetermineDependencies
{
   my ($this) = @_;
   my ($nw, $sql, $id, $numdeps, @row);

   #TODO: ArtistId is not defined at this point. Do a lookup to see if
   #      the artist is defined. If not, bail, otherwise check depends.

   $nw = $this->ConvertNewToHash($this->{new});
   $numdeps = 0;
   $sql = Sql->new($this->{DBH}); 

   return if (!defined $this->GetArtist());
   
   ($id) = $sql->GetSingleRow("Changes", ["id"], 
                              ["type", ModDefs::MOD_ADD_ARTIST,
                               "rowid", $this->GetArtist(),
                               "status", ModDefs::STATUS_OPEN]);
   if (defined $id)
   {
       if (defined $nw)
       {
          $nw->{"Dep$numdeps"} = $id;
          $numdeps++;
       }
   }

   if ($sql->Select(qq|select newvalue, id from Changes where type = | .
                       ModDefs::MOD_ADD_ALBUM . " and status = " .
                       ModDefs::STATUS_OPEN))
   {
       while(@row = $sql->NextRow())
       {
          if ($row[0] =~ /ArtistId=(\d+)/m)
          {
              if ($this->GetArtist() == $1)
              {
                 $nw->{"Dep$numdeps"} = $row[1];
                 $numdeps++;
              }
          }
       }
       $sql->Finish();
   }

   $this->{new} = $this->ConvertHashToNew($nw);
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, %info, @tracks, $track, $i, $in, $key);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   if (defined $this->{artist})
   {
      $info{artistid} = $this->{artist}; 
   }
   else
   {
      $info{artist} = $nw->{"Artist"}; 
      $info{sortname} = $nw->{"Sortname"}; 
   }
   $info{album} = $nw->{AlbumName};
   if (exists $nw->{CDIndexId})
   {
       $info{cdindexid} = $nw->{CDIndexId};
       $info{toc} = $nw->{TOC};
   }

   # Prevent name clashes with existing albums
   $info{forcenewalbum} = 1;

   for($i = 1;; $i++)
   {
      last if (!exists $nw->{"Track$i"});
      if (exists $this->{artist} &&
          $this->{artist} == Artist::VARTIST_ID)
      {
          push @tracks, { track=> $nw->{"Track$i"}, 
                          tracknum => $i, 
                          artist=> $nw->{"Artist$i"} };
      }
      else
      {
          push @tracks, { track=> $nw->{"Track$i"}, 
                          tracknum => $i };
      }
   }
   $info{tracks} = \@tracks;

   $in = Insert->new($this->{DBH});
   if (defined $in->Insert(\%info))
   {
       if (exists $info{album_insertid})
       {
           $nw->{AlbumId} = $info{album_insertid};
           $this->{rowid} = $info{album_insertid};
       }
       if (exists $info{artist_insertid})
       {
           $nw->{ArtistId} = $info{artist_insertid};
       }
       if (exists $info{cdindexid_insertid})
       {
           $nw->{DiskId} = $info{cdindexid_insertid};
       }
       foreach $track (@tracks)
       {
           $key = "Track" . $track->{tracknum} . "Id";
           if (exists $track->{track_insertid})
           {
               $nw->{$key} = $track->{track_insertid};
           }

           $key = "Trm" . $track->{tracknum} . "Id";
           if (exists $track->{trm_insertid})
           {
               $nw->{$key} = $track->{trm_insertid};
           }

           $key = "Artist" . $track->{tracknum} . "Id";
           if (exists $track->{artist_insertid})
           {
               $nw->{$key} = $track->{artist_insertid};
           }
       }

       $nw->{_artistid} = $info{_artistid};
       $nw->{_albumid} = $info{_albumid};
       $this->{new} = $this->ConvertHashToNew($nw);

       return 1;
   }
   else
   {
       $this->{error} = $in->GetError();
       return 0;
   }
}

#returns STATUS_XXXX
sub ApprovedAction
{
   return ModDefs::STATUS_APPLIED;
}

#returns nothing
sub DeniedAction
{
   my ($this) = @_;
   my ($newval, $i, $done);

   $newval = $this->ConvertNewToHash($this->{new});

   # Remove all the tracks, trm ids and track/artists inserted
   # for this album.
   for($i = 1;; $i++)
   {
      $done = 1;
      if (exists $newval->{"Track".$i."Id"})
      {
          my $tr;

          $tr = Track->new($this->{DBH});
          $tr->SetId($newval->{"Track".$i."Id"});
          $tr->Remove();

          $done = 0;
      }
      if (exists $newval->{"Trm".$i."Id"})
      {
          my $gu;

          $gu = GUID->new($this->{DBH});
          $gu->SetId($newval->{"Trm".$i."Id"});
          $gu->Remove();

          $done = 0;
      }
      if (exists $newval->{"Artist".$i."Id"})
      {
          my $ar;

          $ar = Artist->new($this->{DBH});
          $ar->SetId($newval->{"Artist".$i."Id"});
          $ar->Remove();

          $done = 0;
      }
      last if ($done);
   }
   if (exists $newval->{"AlbumId"})
   {
      my ($al, $di);

      $al = Album->new($this->{DBH});
      $al->SetId($newval->{"AlbumId"});
      $al->Remove();
   }
   if (exists $newval->{"DiskId"})
   {
      my $di;

      $di = Diskid->new($this->{DBH});
      $di->Remove($newval->{"DiskId"});
   }
   if (exists $newval->{"ArtistId"})
   {
      my $ar;

      $ar = Artist->new($this->{DBH});
      $ar->SetId($newval->{"ArtistId"});
      $ar->Remove();
   }
}

package AddArtistModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   return "Old: N/A";
}

sub ShowNewValue
{
   my ($this) = @_;
   my ($new, $artist, $sortname, $id);
   
   $new = $this->{new};
   if ($new =~ /^ArtistName=(.*)$/m)
   {
       $artist = $1;
   }
   if ($new =~ /^SortName=(.*)$/m)
   {
       $sortname = $1;
   }
   if ($new =~ /^ArtistId=(.*)$/m)
   {
       $id = $1;
   }

   if ($this->{status} == ModDefs::STATUS_FAILEDVOTE ||
       $this->{status} == ModDefs::STATUS_FAILEDPREREQ)
   {
       return "Artist: <font style=\"bold\">$artist</font>";
   }
   else
   {
       return qq|Artist: <a href=\"/showartist.html?artistid=$id\">
                 <font style=\"bold\">$artist</font></a><br>
                 Sortname: <font style=\"bold\">$sortname</font>|;
   }
}

# An artist is not dependent on anything, so no dependency information needs
# to be determined.
sub DetermineDependencies
{
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, %info, @tracks, $track, $i, $in, $key);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   if (!exists $nw->{SortName} || $nw->{SortName} eq "")
   {
      $nw->{SortName} = $nw->{ArtistName};
   }
   $info{artist} = $nw->{"ArtistName"}; 
   $info{sortname} = $nw->{"SortName"}; 
   $info{artist_only} = $nw->{"SortName"}; 

   # TODO: Support for inserting partial albums
   $in = Insert->new($this->{DBH});
   if (defined $in->Insert(\%info))
   {
       if (exists $info{artist_insertid})
       {
           $nw->{ArtistId} = $info{artist_insertid};
           $this->{rowid} = $info{artist_insertid};
       }
       $this->{new} = $this->ConvertHashToNew($nw);

       return 1;
   }
   else
   {
       $this->{error} = $in->GetError();
       return 0;
   }
}

#returns STATUS_XXXX
sub ApprovedAction
{
   return ModDefs::STATUS_APPLIED;
}

#returns nothing
sub DeniedAction
{
   my ($this) = @_;
   my ($newval, $i, $done, $sql);

   $newval = $this->ConvertNewToHash($this->{new});
   if (exists $newval->{"ArtistId"})
   {
      my $ar;

      $ar = Artist->new($this->{DBH});
      $ar->SetId($newval->{"ArtistId"});
      $ar->Remove();

      $sql = Sql->new($this->{DBH});
      $sql->Do("update Changes set artist = " . Artist::DARTIST_ID . 
               " where artist = " . $newval->{"ArtistId"});
   }
}

package AddTrackModerationKV;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;
   my ($id, $name, $nw);

   $nw = $this->{new};
   if ($nw =~ /^AlbumId=(.*)$/m)
   {
       $id = $1;
   }

   if (defined $id)
   {
       return "Album: <a href=\"/showalbum.html?albumid=$id\">" .
              $this->GetPrev() . "</a>";
   }
   else
   {
       return "N/A";
   }
}

sub ShowNewValue
{
   my ($this) = @_;
   my ($nw, $out);
   
   $nw = $this->ConvertNewToHash($this->{new});

   $out = qq\Track: <span class="bold">$nw->{TrackName}</span>\;
   $out .= qq\<br>TrackNum: <span class="bold">$nw->{TrackNum}</span>\;
   if ($this->GetArtist() == Artist::VARTIST_ID)
   {
       $out .= qq\<br>Artist: <span class="bold">$nw->{ArtistName}</span>\;
       $out .= qq\<br>Sortname: <span class="bold">$nw->{SortName}</span>\
           if (exists $nw->{SortName});
   }
   return $out;
}

sub DetermineDependencies
{
   my ($this) = @_;
   my ($nw, $sql, $id);

   $sql = Sql->new($this->{DBH}); 
   ($id) = $sql->GetSingleRow("Changes", ["id"], 
                              ["type", ModDefs::MOD_ADD_ALBUM,
                               "rowid", $this->GetRowId(),
                               "status", ModDefs::STATUS_OPEN]);
   if (defined $id)
   {
      $nw = $this->ConvertNewToHash($this->{new});
      return if (!defined $nw);
      $nw->{Dep0} = $id;
      $this->{new} = $this->ConvertHashToNew($nw);
   }
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, %info, @tracks, $track, $i, $in, $key);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   $info{artistid} = $this->{artist}; 
   $info{albumid} = $nw->{AlbumId}; 

   if ($this->{artist} == Artist::VARTIST_ID)
   {
      if (!exists $nw->{SortName} || $nw->{SortName} eq "")
      {
         $nw->{SortName} = $nw->{ArtistName};
      }
      push @tracks, { track=> $nw->{"TrackName"}, 
                      tracknum => $nw->{"TrackNum"}, 
                      artist=> $nw->{"ArtistName"},
                      sortname=> $nw->{"SortName"} };
   }
   else
   {
      push @tracks, { track=> $nw->{"TrackName"}, 
                      tracknum => $nw->{"TrackNum"} };
   }
   $info{tracks} = \@tracks;

   $in = Insert->new($this->{DBH});
   if (defined $in->Insert(\%info))
   {
       foreach $track (@tracks)
       {
           if (exists $track->{track_insertid})
           {
               $nw->{"TrackId"} = $track->{track_insertid};
               $this->{rowid} = $track->{track_insertid};
           }

           if (exists $track->{artist_insertid})
           {
               $nw->{"ArtistId"} = $track->{artist_insertid};
           }
       }

       $this->{new} = $this->ConvertHashToNew($nw);

       return 1;
   }
   else
   {
       $this->{error} = $in->GetError();
       return 0;
   }
}

sub ApprovedAction
{
   return ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
   my ($this) = @_;
   my ($newval, $i, $done);

   $newval = $this->ConvertNewToHash($this->{new});
   if (exists $newval->{"TrackId"})
   {
      my $tr;

      $tr = Track->new($this->{DBH});
      $tr->SetId($newval->{"TrackId"});
      $tr->Remove();
   }
   if (exists $newval->{"ArtistId"})
   {
      my $ar;

      $ar = Artist->new($this->{DBH});
      $ar->SetId($newval->{"ArtistId"});
      $ar->Remove();
   }
}

package MoveDiskidModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   my $name = "Unknown";
   my $diskid = "Unknown";
   my $new = $this->{new};
   if ($new =~ /^OldAlbumName=(.*)$/m)
   {
       $name = $1;
   }
   if ($new =~ /^DiskId=(.*)$/m)
   {
       $diskid = $1;
   }
   return "Old: <a href=\"/showalbum.html?albumid=" . $this->GetPrev() .
          "\">$name</a><br>$diskid";
}

sub ShowNewValue
{
   my ($this) = @_;
   
   my $nw = $this->ConvertNewToHash($this->{new});
   return "New: <a href=\"/showalbum.html?albumid=$nw->{NewAlbumId}\">" .
          "$nw->{NewAlbumName}</a>";
}

# I don't think moving an id warrants any dependencies
sub DetermineDependencies
{
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, $sql, $quote);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   $sql = Sql->new($this->{DBH});
   $quote = $sql->Quote($nw->{DiskId});
   $sql->Do(qq|update Diskid set album=$nw->{NewAlbumId} where disk = $quote|);
   $sql->Do(qq|update TOC set album=$nw->{NewAlbumId} where diskid = $quote|);
}

#returns STATUS_XXXX
sub ApprovedAction
{
   return ModDefs::STATUS_APPLIED;
}

#returns nothing
sub DeniedAction
{
   my ($this) = @_;
   my ($nw, $sql, $quote);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   $sql = Sql->new($this->{DBH});
   $quote = $sql->Quote($nw->{DiskId});
   $sql->Do("update Diskid set album= " . $this->GetPrev() . 
            " where disk = $quote");
   $sql->Do("update TOC set album= " . $this->GetPrev() . 
            " where diskid = $quote");
}
