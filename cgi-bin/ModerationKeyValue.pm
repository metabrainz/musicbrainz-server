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

   for($i = 1;; $i++)
   {
      last if (!exists $nw->{"Track$i"});
      push @tracks, { track=> $nw->{"Track$i"}, tracknum => $i };
   }
   $info{tracks} = \@tracks;

   # TODO: Support for inserting partial albums
   $in = Insert->new($this->{DBH});
   if (defined $in->Insert(\%info))
   {
       $nw->{AlbumId} = $info{album_insertid};
       foreach $track (@tracks)
       {
           next if (!exists $track->{track_insertid});
           $key = "Track" . $track->{tracknum} . "Id";
           $nw->{$key} = $track->{track_insertid};
       }

       $this->{new} = $this->ConvertHashToNew($nw);
       print STDERR "After insert: $this->{new}\n";
   }
}
