#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 1998 Robert Kaye
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

use CGI::Pretty qw/:standard/;
use DBForm; 
use MusicBrainz;
use strict;

sub RemoveDuplicateArtist
{
   my ($dbh, $ArtistId, $ArtistName) = @_;
   my %Query;

   $Query{'Name'} = $ArtistName;

   my($ReturnCode,%Artist) = DBForm::DBLoadSingle($dbh,"Artist",%Query);
   if ($ReturnCode)
   {
       print "Error: Duplicate artists found, but could not merge artists.<br>";
       return;
   }

   $dbh->do("update Album set artist = $Artist{Id} where artist = $ArtistId");
   $dbh->do("update Track set artist = $Artist{Id} where artist = $ArtistId");
   $dbh->do("delete from Artist where id = $ArtistId");
}

my ($o, $cd); 
my ($i, $toc);
my ($dbh, $sth, $rv, $sql); 

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Edit Artist Information');

my $artistid = $o->param('artistid');

$dbh = DBForm::DBConnect();
my (%Query,$key,%NewArtist,%Types);

my %ParamData = DBForm::DBGetPostedData();
if (exists $ParamData{'artistid'})
{
    $Query{'Id'} = $artistid;

    my($ReturnCode,%Artist) = DBForm::DBLoadSingle($dbh,"Artist",%Query);
    if($ReturnCode)
    {
       print("Database error: $ReturnCode") 
    }
    else
    {
       my %Defaults = %Artist;
       print DBForm::DBMakeForm($dbh,"Artist",\%Defaults, ['Name']);
    }
}
else
{
    if (exists $ParamData{'Id'})
    {
        my($ReturnCode,%Artist) = DBForm::DBSaveSingle($dbh,"Artist",%ParamData);
        if ($ReturnCode)
        {
           if ($ReturnCode =~ m/Duplicate/i)
           {
               RemoveDuplicateArtist($dbh, $ParamData{Id}, $ParamData{Name});
           }
           else
           {
               print "Error: $ReturnCode<br><p>";
           }
        }
        print("Thank you for editing the database!<p>");

        print $cd->SearchForm();
    }
    else
    {
        printf("<FONT SIZE=+1 COLOR=RED> Error: </FONT>");
        printf("The artistid argument must be given to this page.");
    }
}

DBForm::DBDisconnect($dbh);  

$cd->Footer;
