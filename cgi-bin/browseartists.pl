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
                                                                               
use strict;
use CGI;
use DBI;
use MusicBrainz;

my ($o, $cd, $sth, $sth2, @row, @row2, $ind, $i, $offset, $num_artists);
my $max_items = 50;

sub PrintPrevButton
{
    my ($offset, $num, $text) = @_;

    print '<td width="15%">';
    if ($offset > 0)
    {
        print "<a href=\"browse_artists.pl?index=$ind&offset=";
        print (($offset - $num) . "\">$text</a>");
    }
    else
    {
        print "$text";
    }
    print "</td>";
}

sub PrintNextButton
{
    my ($offset, $num, $text, $rows) = @_;

    print '<td width="15%">';
    if ($offset + $num < $rows)
    {
        print "<a href=\"browse_artists.pl?index=$ind&offset=";
        print (($offset + $num) . "\">$text</a>");
    }
    else
    {
        print "$text";
    }
    print "</td>";
}

$cd = new MusicBrainz;
$o = $cd->GetCGI;
$cd->Header('Browse Artists');

print "<center>\n";
$ind = $o->param("index");
if (!defined $ind || $ind eq '')
{
    print "Select a letter to see the Artists that begin with that letter:<br>";
}
$offset = $o->param("offset");
$offset = 0 if not defined $offset;
$offset = 0 if $offset < 0;

print $cd->ArtistBrowseForm;
print "</center>\n"; 

if (!defined $ind || $ind eq '')
{
    $cd->Footer;  
    exit(0);
}

$cd->Login();

$sth = $cd->{DBH}->prepare("select count(*) from Artist where left(name, 1) = '$ind'");
$sth->execute();
$num_artists = ($sth->fetchrow_array)[0]; 
$sth->finish;

$sth = $cd->{DBH}->prepare("select id, name from Artist where left(name, 1) = '$ind' order by name limit $offset, $max_items");
$sth->execute();

print '<table width="100%"><tr>';
PrintPrevButton($offset, $max_items, "< Prev");
PrintPrevButton($offset, $max_items * 2, "<< Prev");
print '<td width="40%">&nbsp;</td>';
PrintNextButton($offset, $max_items * 2, "Next >>", $num_artists);
PrintNextButton($offset, $max_items, "Next >", $num_artists);
print '</tr></table>';

if ($sth->rows > 0)  
{
    print '<p><table align="center" width="100%">';
    for($i = $offset; @row = $sth->fetchrow_array; $i++)
    {
        print "<tr><td valign=top>" . ($i + 1);
        print ".</td><td valign=top width=\"50%\">";
        print "<font size=+1><a href=\"showartist.pl?artistid=$row[0]\">";
        print "$row[1]</font></td><td valign=top>\n";
        if (@row = $sth->fetchrow_array)
        {
            $i++;
            print (($i + 1) . ".</td><td valign=top width=\"50%\">");
            print "<font size=+1><a href=\"showartist.pl?artistid=$row[0]\">";
            print "$row[1]</font>\n";
        }
        else
        {
            print "&nbsp;</td><td>&nbsp;";
        }
        print "</td></tr>";
    }
    print "</table>";
}
$sth->finish;

$cd->Logout;
$cd->Footer;  
