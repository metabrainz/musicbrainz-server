#____________________________________________________________________________
#
#   MusicBrainz -- the internet music database
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
package ParseFileName;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

# Filename: ParseFilename.pm
# Author: Patrick Sun
# Last updated: 09-28-00
# Purpose:  This perl script will attempt to either reduce the Pending table
# or update the Track table with a GUID, (once the freedb, emusic, and 
# cdindex data sources
# are loaded into the production tables).  The main logic is to parse out the 
# filename column and then attempting to match both the artist and track against
# the production tables.  If successfully matched, then it will either delete
# from the Pending table if the prod Track table already has a GUID.  Otherwise,
# the prod Track's GUID will be updated with the client's GUID.

# Also, there are three additional utility subroutines, IsNumber, 
# RemoveLeadingToken, and RemoveTrailingToken.  I used IsNumber to decipher 
# track sequences.  However, track sequences will not be used as a search 
# criteria here.  I used RemoveLeadingToken and RemoveTrailingToken 
# specifically to remove leading and trailing blank spaces from the
# filename tokens after performing splits, because a query againts MySQL 
# ie. SELECT Name from Artist where Name = ' Bush' does not equate to 
# 'Bush'.  However, MySQL does automatically remove trailing spaces.

use strict;

my ($sth, @row, $numrecs, $item, $final_item, @StageItems);
my ($NumFinalItems, @FinalItems, @SubArray, $SubArraySize, $SubItem);
my (@SubSubArray, $SubSubArraySize, $SubSubItem);
my ($guid, $filename);  
my ($rv, $token);
my ($ArtistFound, $TrackFound, $ArtistTrackFound, $CntArtistTrackFound);
my ($Artist, $ArtistId, $Track, $GUID);

sub ParseFilename
{
   my($mb, $guid, $filename, $InPendingFlag) = @_;

   #print "Inside ParseFilename\n";
   #print "filename: $filename\n";

   # treat underscores as blank spaces.
   $filename =~ s/_/ /g;

   # remove all '[' from filename.
   $filename =~ s/\[//g;

   @StageItems = split(/\//, $filename);
   foreach $item (@StageItems)
   {
      if ( ($item) && !($item =~ /\|/) && !($item =~ /file:/) )
      { 
         # remove .mp3 extension.
         $item =~ s/.mp3//g;
         #print "item is: $item\n";

         # Do another split on '-';
         $SubArraySize = @SubArray = split(/-/, $item);
         
         #print "SubArraySize: $SubArraySize\n";
         if ($SubArraySize > 1)
         {
            foreach $SubItem (@SubArray)
            {
               # do another split on ']'
               $SubSubArraySize = @SubSubArray = split(/]/, $SubItem);
               if ($SubSubArraySize > 1)
               {
                  foreach $SubSubItem (@SubSubArray)
                  {
                     # remove leading spaces.
                     $SubSubItem = RemoveLeadingToken($SubSubItem, ' ');

                     # remove trailing spaces.
                     $SubSubItem = RemoveTrailingToken($SubSubItem, ' ');

                     push(@FinalItems, $SubSubItem);
                  }
               }
               else
               {
                  # remove leading spaces.
                  $SubItem = RemoveLeadingToken($SubItem, ' ');

                  # remove trailing spaces.
                  $SubItem = RemoveTrailingToken($SubItem, ' ');

                  push(@FinalItems, $SubItem);
               }
            }        
         }
         else
         {
            # do another split on ']'
            $SubArraySize = @SubArray = split(/]/, $item);
            if ($SubArraySize > 1)
            {
               foreach $SubItem (@SubArray)
               {
                  #remove leading spaces.
                  $SubItem = RemoveLeadingToken($SubItem, ' ');

                  # remove trailing spaces.
                  $SubItem = RemoveTrailingToken($SubItem, ' ');

                  push(@FinalItems, $SubItem);
               }
            }
            else
            {
               #remove leading spaces.
               $item = RemoveLeadingToken($item, ' ');

               # remove trailing spaces.
               $item = RemoveTrailingToken($item, ' ');

               push(@FinalItems, $item);
            }
         }
      }
   }

   $NumFinalItems = @FinalItems;
   #print "Number of items in FinalItems: $NumFinalItems\n";

   # We now have the tokens stored in an array.  The logic
   # now is to loop through the array and for each token
   # perform a lookup against the Musicbrainz database.
   # First, we lookup artist.  If that is found, then we
   # lookup title and artist.  
   # Album can be left blank, which is OK.  So, a match is 
   # accepted if the lookup of both artist and title is successful.  
   # If we do not even match on artist, then ignore record
   # and move on.
   # We will use flags to indicate a match on a particular field.

   $ArtistFound = 'false';
   $ArtistTrackFound = 'false';
   foreach $final_item (@FinalItems)
   {
      #print "final item: $final_item\n";

      $rv = MusicBrainz::GetArtistId($mb, $final_item);
      if ($rv != -1)
      {
         #print "Found artist in prod table.  Try looking up title.\n";
         $ArtistFound = 'true';
         $ArtistId = $rv;
         #print "ArtistID: $ArtistId\n";
      }
      else
      {
         #print "Artist not found.\n";
      }

      # This section attempts to parse out the track number.  May use in the future.
      #$rv = IsNumber($final_item);
      #if ($rv == 1)
      #{
      #   print "$final_item is a number\n";
         # item is a number so we can use it for a sequence lookup.
      #}
      #else
      #{
         #print "$final_item is NOT a number\n";
      #}
   }

   if ($ArtistFound eq 'true')
   {
      # Now, try to match title and artist against production mb database.
      #print "Artist found so try to match title and artist.\n";
      foreach $final_item (@FinalItems)
      {
         $final_item = $mb->{DBH}->quote($final_item);
         $sth = $mb->{DBH}->prepare(qq/select t.Name, t.GUID, ar.ID, ar.Name 
                   from Track t, Artist ar where t.Artist=ar.Id and 
                   ar.Id=$ArtistId and t.Name=$final_item/);
         $sth->execute;
         if ($sth->rows)
         {
            while(@row = $sth->fetchrow_array)
            {
               $ArtistTrackFound = 'true';
               $Track = $row[0];
               $GUID = $row[1];
               $ArtistId = $row[2];
               $Artist = $row[3];
            }
         }
      }
   }
   else
   {
      #print "No artist found so ignore and continue.\n";
   }

   if ($ArtistTrackFound eq 'true')
   {
      # Return code with a match on Title and Artist.
      $rv = 0;
      #print "Matched artist and title.  Now check for GUID.\n";

      # Determine if GUID is null or not.  If it is then we update the
      # the production Track table with the GUID from the incoming client.
      # Else, if the production Track table has a GUID, then we delete
      # the record from Pending (indicating a duplicate).

      if ($GUID eq '')
      {
         #print "Prod record has no GUID so update record.\n";
         #print "Track: $Track\n";
         #print "guid: $guid\n";
         # Update Track with guid from client.
         $guid = $mb->{DBH}->quote($guid);
         $Track = $mb->{DBH}->quote($Track);
         $mb->{DBH}->do("update Track set GUID=$guid where Name=$Track and Artist=$ArtistId");
      }
      elsif ($InPendingFlag eq 'Y')
      {
         #print "Prod record has GUID so delete from Pending.\n";
         #print "Track: $Track\n";
         #print "guid: $guid\n";
         # Record already exists in production table so delete from Pending.
         MusicBrainz::DeletePendingData($mb, $guid);
      }
      elsif ($InPendingFlag eq 'N')
      {
         #print "Prod record has GUID so delete from Pending matching on title and artist.\n";
         #print "Track: $Track\n";
         #print "guid: $guid\n";
         #print "Artist: $Artist\n";
         # Record already exists in production table so delete from Pending where
         # the title and artist match.
         $guid = $mb->{DBH}->quote($guid);
         $Artist = $mb->{DBH}->quote($Artist);
         $Track = $mb->{DBH}->quote($Track);
         $mb->{DBH}->do("delete from Pending where Name=$Track and Artist=$Artist");
      }      
   }
   else
   {
      # Return code with no match on title and artist.
      $rv = -1;
   }

   $sth->finish;
   
   return $rv;

}

sub IsNumber
{
   sub IsDigit
   {
      my $char = $_[0];
      if ($char =~ /\d/)
      {
         #print "$char is a digit.\n";
         return 1;
      }
      else
      {
         #print "$char is NOT a digit.\n";
         return 0;
      }
   }

   #print "Inside IsNumber()\n";
   my($str, $strlen, $char, $i, $IsNumberCnt, $rv);
   $str = $_[0];
   #print "str: $str\n";

   $strlen = length($str);
   #print "strlen: $strlen\n";
   $IsNumberCnt = 0;
   for ($i = 0; $i < $strlen; $i++)
   {
      $char = chop($str);
      $rv = IsDigit($char);
      if ($rv == 1)
      {
         $IsNumberCnt += 1;
      }
	   }
   if ($IsNumberCnt == $strlen)
   {
      return 1;
   }
   else
   {
      return 0;
   }
}

sub RemoveLeadingToken
{
   my ($str, $token) = @_;

   my ($i, $strlen);

   $strlen = length($str);
   for ($i = 0; $i < $strlen; $i++)
   {
      if ($str =~ /^$token/)
      {
         #print "str contains leading $token, so remove it.\n";
         $str =~ s/^$token//g;
      }
      else
      {
         #print "$str does not contain leading $token.\n"
      }
   }
   return $str;
}

sub RemoveTrailingToken
{
   my ($str, $token) = @_;

   my ($i, $strlen);

   $strlen = length($str);
   for ($i = 0; $i < $strlen; $i++)
   {
      if ($str =~ /$token$/)
      {
         #print "str contains trailing $token, so remove it.\n";
         $str =~ s/$token$//g;
      }
      else
      {
         #print "$str does not contain trailing $token.\n"
      }
   }
   return $str;
}

1
