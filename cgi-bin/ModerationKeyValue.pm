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

   return "Album: <a href=\"/showalbum.html?albumid=$id\">$name</a>";
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, %info, @tracks, $track, $i, $in, $key);

   $nw = $this->ConvertNewToHash($this->{new});
   return undef if (!defined $nw);

   $info{artistid} = $this->{artist}; 
   $info{album} = $nw->{AlbumName};
   $info{cdindexid} = "borOdvYNUkc2SF8GrzPepad0H3M-";
   $info{toc} = "1 2 157005 150 77950";

   #TODO: Support multiple artists!
   for($i = 1;; $i++)
   {
      last if (!exists $nw->{"Track$i"});
      push @tracks, { track=> $nw->{"Track$i"}, tracknum => $i, 
                      trmid=>"feb4b180-c5f0-4465-9926-fc5704444c83" };
   }
   $info{tracks} = \@tracks;

   print STDERR "Before insert:\n$this->{new}\n";
   # TODO: Support for inserting partial albums
   $in = Insert->new($this->{DBH});
   if (defined $in->Insert(\%info))
   {
       if (exists $info{album_insertid})
       {
           $nw->{AlbumId} = $info{album_insertid};
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
               print STDERR "kv: got trm id\n";
               $nw->{$key} = $track->{trm_insertid};
           }
           else
           {
               print STDERR "kv: got no trm id\n";
           }
           $key = "Artist" . $track->{tracknum} . "Id";
           if (exists $track->{artist_insertid})
           {
               $nw->{$key} = $track->{artist_insertid};
           }
       }

       $this->{new} = $this->ConvertHashToNew($nw);
       print STDERR "After insert:\n$this->{new}\n";
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
