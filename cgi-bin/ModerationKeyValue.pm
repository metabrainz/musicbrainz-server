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
   
   ($id) = $sql->GetSingleRow("Moderation", ["id"], 
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

   if ($sql->Select(qq|select newvalue, id from Moderation where type = | .
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
      my $tmp = {};
      last if (!exists $nw->{"Track$i"});
      if (exists $this->{artist} &&
          $this->{artist} == ModDefs::VARTIST_ID)
      {
          $$tmp{artist} = $nw->{"Artist$i"};
      }

      # print STDERR $nw->{"TrackDur$i"};
      if (exists $nw->{"TrackDur$i"})
      {
          $$tmp{duration} = $nw->{"TrackDur$i"};
      }
      $$tmp{track} = $nw->{"Track$i"};
      $$tmp{tracknum} = $i;
      push @tracks, $tmp;
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
           $nw->{Discid} = $info{cdindexid_insertid};
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

   if (exists $newval->{"AlbumId"})
   {
      my ($al, $di);

      $al = Album->new($this->{DBH});
      $al->SetId($newval->{"AlbumId"});
      $al->Remove();

      if (exists $newval->{"ArtistId"})
      {
         my $ar;
   
         if ($newval->{"ArtistId"} != ModDefs::VARTIST_ID)
         {
             $ar = Artist->new($this->{DBH});
             $ar->SetId($newval->{"ArtistId"});
             $ar->Remove();
         }
      }
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
       else
       {
           $this->{error} = "The artist <a href=\"/showartist.html?artistid=$info{_artistid}\">$info{artist}</a> exists already.";
           return 0;
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
      $sql->Do("update Moderation set artist = " . ModDefs::DARTIST_ID . 
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
   if ($this->GetArtist() == ModDefs::VARTIST_ID)
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
   ($id) = $sql->GetSingleRow("Moderation", ["id"], 
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

   if ($this->{artist} == ModDefs::VARTIST_ID)
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
      my ($tr, $sql);

      $sql = Sql->new($this->{DBH});
      $sql->Do("delete from AlbumJoin where track = " . $newval->{"TrackId"});

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

package MoveDiscidModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;

   my $name = "Unknown";
   my $Discid = "Unknown";
   my $new = $this->{new};

   if ($new =~ /^OldAlbumName=(.*)$/m)
   {
       $name = $1;
   }
   if ($new =~ /^DiscId=(.*)$/m)
   {
       $Discid = $1;
   }
   return "Old: <a href=\"/showalbum.html?albumid=" . $this->GetPrev() .
          "\">$name</a><br>$Discid";
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
   $quote = $sql->Quote($nw->{Discid});
   $sql->Do(qq|update Discid set album=$nw->{NewAlbumId} where disc = $quote|);
   $sql->Do(qq|update TOC set album=$nw->{NewAlbumId} where Discid = $quote|);
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
   $quote = $sql->Quote($nw->{Discid});
   $sql->Do("update Discid set album= " . $this->GetPrev() . 
            " where disc = $quote");
   $sql->Do("update TOC set album= " . $this->GetPrev() . 
            " where Discid = $quote");
}

package RemoveTRMIdModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;
   my ($nw);

   $nw = $this->ConvertNewToHash($this->{new});
   return "Error!" if (!defined $nw);

   if (exists $nw->{TrackId} && $nw->{TrackId} != 0)
   {
       return "Old: <a href=\"/showtrack.html?trackid=" . $nw->{TrackId} .
          "\">" . $this->GetPrev() . "</a>";
   }
   return "Error!";
}

sub ShowNewValue
{
   my ($this) = @_;
   
   return "New: DELETE"; 
}

# I don't think removing a trmid warrants any dependencies
sub DetermineDependencies
{
}

sub PreVoteAction
{
   my ($this) = @_;

   my $gu = TRM->new($this->{DBH});
   $gu->RemoveTRMByTRMJoin($this->GetRowId());
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

   if (exists $nw->{TrackId} && $nw->{TrackId} != 0)
   {
       my $gu = TRM->new($this->{DBH});
       $gu->Insert($this->GetPrev(), $nw->{TrackId});
   }
}

package MergeAlbumModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;
   my ($nw, $key, $i, $out);

   $out = "Error!";
   $nw = $this->ConvertNewToHash($this->{new});
   return $out if (!defined $nw);

   $out = "Old: ";
   for($i = 1;; $i++)
   {
       $key = "AlbumId$i";
       if (exists $nw->{$key} && $nw->{$key} != 0)
       {
           $out .= "<br>" if ($i > 1);
           if ($this->GetStatus() == ModDefs::STATUS_OPEN)
           {
               $out .= "<a href=\"/showalbum.html?albumid=" . 
                  $nw->{$key} . "\">" . $nw->{"AlbumName$i"} . "</a>";
           }
           else
           {
               $out .= $nw->{"AlbumName$i"};
           }
       }
       else
       {
           last;
       }
   }

   return $out;
}

sub ShowNewValue
{
   my ($this) = @_;
   my ($nw, $key, $out);

   $out = "Error!";
   $nw = $this->ConvertNewToHash($this->{new});
   return $out if (!defined $nw);

   $out = "Merged into: ";
   $key = "AlbumId0";
   if (exists $nw->{$key} && $nw->{$key} != 0)
   {
      $out .= "<a href=\"/showalbum.html?albumid=" . 
              $nw->{$key} . "\">" . $nw->{"AlbumName0"} . "</a>";
   }
   else
   {
      return "Error!";
   }

   return $out;
}

sub DetermineDependencies
{
}

sub PreVoteAction
{
    return 1;
}

#returns STATUS_XXXX
sub ApprovedAction
{
   my ($this) = @_;
   my ($nw, $key, $i, $al, @list);

   $nw = $this->ConvertNewToHash($this->{new});
   return "Error!" if (!defined $nw);

   $al = Album->new($this->{DBH});
   for($i = 0;; $i++)
   {
       $key = "AlbumId$i";
       if (exists $nw->{$key} && $nw->{$key} != 0)
       {
           push @list, $nw->{$key};
       }
       else
       {
           last;
       }
   }

   $al->SetId(shift @list);
   if (defined $al->LoadFromId())
   {
       $al->MergeAlbums($this->GetType() == ModDefs::MOD_MERGE_ALBUM_MAC, 
                        @list);
       return ModDefs::STATUS_APPLIED;
   }
   else
   {
       return ModDefs::STATUS_FAILEDPREREQ;
   }
}

#returns nothing
sub DeniedAction
{
}

package RemoveAlbumsModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;
   my ($nw, $key, $key2, $i, $out);

   $out = "Error!";
   $nw = $this->ConvertNewToHash($this->{new});
   return $out if (!defined $nw);

   $out = "Old: ";
   for($i = 0;; $i++)
   {
       $key = "AlbumId$i";
       if (exists $nw->{$key} && $nw->{$key} != 0)
       {
           $out .= "<br>" if ($i > 0);
           if ($this->GetStatus() == ModDefs::STATUS_OPEN)
           {
               $out .= "<a href=\"/showalbum.html?albumid=" . 
                   $nw->{$key} . "\">" . $nw->{"AlbumName$i"} . "</a>";
           }
           else
           {
               $out .= $nw->{"AlbumName$i"};
           }
       }
       else
       {
           last;
       }
   }

   return $out;
}

sub ShowNewValue
{
   return "New: DELETE"; 
}

sub DetermineDependencies
{
}

sub PreVoteAction
{
    return 1;
}

#returns STATUS_XXXX
sub ApprovedAction
{
   my ($this) = @_;
   my ($nw, $key, $i, $al, @list);

   $nw = $this->ConvertNewToHash($this->{new});
   return "Error!" if (!defined $nw);

   $al = Album->new($this->{DBH});
   for($i = 0;; $i++)
   {
       $key = "AlbumId$i";
       if (exists $nw->{$key} && $nw->{$key} != 0)
       {
           $al->SetId($nw->{$key});
           $al->Remove();
       }
       else
       {
           last;
       }
   }

   return ModDefs::STATUS_APPLIED;
}

#returns nothing
sub DeniedAction
{
}

package EditAlbumAttributesModeration;
use vars qw(@ISA);
@ISA = 'Moderation';

sub ShowPreviousValue
{
   my ($this) = @_;
   my ($nw, $text, $value);
   
   $nw = $this->ConvertNewToHash($this->{new});
   $text = "<b>Album:</b> <a href=\"/showalbum.html?albumid=" . $this->{rowid} .
           "\">" . $nw->{AlbumName} .  "</a><br>Old: ";
   $value = $this->ConvertToText(split /,/, $this->{prev});
   $value = "None" if ($value eq '');
   return $text . $value;
}

sub ShowNewValue
{
   my ($this) = @_;
   my ($nw, $key, $text, $value);
   
   $nw = $this->ConvertNewToHash($this->{new});
   $value = $this->ConvertToText(split /,/, $nw->{Attributes});
   $value = "None" if ($value eq '');
   return "New: " . $value
}

sub ConvertToText
{
   my $this = shift;
   my ($text, $al, $num);

   $al = Album->new($this->{DBH});
   while(defined($num = shift))
   {
       $text .= $al->GetAttributeName($num) . ", ";
   }
   chop($text);
   chop($text);

   return $text;
}

sub DetermineDependencies
{
}

sub PreVoteAction
{
   my ($this) = @_;
   my ($nw, $key, $text);

   $nw = $this->ConvertNewToHash($this->{new});

   $text = "Attributes=";
   foreach $key (sort { $a <=> $b } keys %{$nw})
   {
      if ($key =~ /^\d+$/)
      {
          $text .= $key . ",";
      }
   }
   chop($text);
   $text .= "\nAlbumName=$nw->{AlbumName}\n";
   $this->{new} = $text;

   return 1;
}

#returns STATUS_XXXX
sub ApprovedAction
{
   my ($this) = @_;
   my ($nw, $key, $text, @attrs, $al);

   $nw = $this->ConvertNewToHash($this->{new});
   @attrs = split /,/, $nw->{Attributes};

   $al = Album->new($this->{DBH});
   $al->SetId($this->{rowid});
   $al->SetAttributes(@attrs);
   if (defined $al->UpdateAttributes($nw->{Attributes}))
   {
        return ModDefs::STATUS_APPLIED;
   }
   return ModDefs::STATUS_FAILEDDEP;
}

#returns nothing
sub DeniedAction
{
}
