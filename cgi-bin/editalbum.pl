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
use strict;
use MusicBrainz;

my ($o, $cd); 
my ($i, $toc);
my ($dbh, $sth, $rv, $sql); 

$cd = new MusicBrainz;
$o = $cd->GetCGI; 

$cd->Header('Edit Album Information');

my $albumid = $o->param('albumid');

$dbh = DBForm::DBConnect();
my (%Query,$key,%NewAlbum,%Types);

my %ParamData = DBForm::DBGetPostedData();
if (exists $ParamData{'albumid'})
{
    $Query{'Id'} = $albumid;

    my($ReturnCode,%Album) = DBForm::DBLoadSingle($dbh,"Album",%Query);
    if($ReturnCode)
    {
       print("Database error: $ReturnCode") 
    }
    else
    {
       my %Defaults = %Album;

       print DBForm::DBMakeForm($dbh,"Album",\%Defaults, ['Name']);
    }
}
else
{
    if (exists $ParamData{'Id'})
    {
        my($ReturnCode,%Album) = DBForm::DBSaveSingle($dbh,"Album",%ParamData);
        print("Thank you for editing the database!<p>");

        print $cd->SearchForm();
    }
    else
    {
        printf("<FONT SIZE=+1 COLOR=RED> Error: </FONT>");
        printf("The albumid argument must be given to this page.");
    }
}

DBForm::DBDisconnect($dbh);  

$cd->Footer;
