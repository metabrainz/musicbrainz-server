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
                                                                               
use CGI;
use DBI;
use strict;
use MusicBrainz;

my ($o, $cd, $num_tracks, $i, $sth, $album); 

$cd = new MusicBrainz;
$o = $cd->GetCGI;
$cd->Header("Submit a New CD");
$cd->CheckArgs('id', 'tracks', 'toc');

my $id = $o->param('id');
my $tracks = $o->param('tracks');
my $toc = $o->param('toc');

if (length($id) == 32 || !defined $toc || $toc eq '')
{
    $cd->PrintError('Please <a href="/cdi_img/download.html">download</a> ' .
                   'the latest client software.');
}

my $valid = $id;
$valid =~ tr/_.\-A-Za-z0-9//d;

if (length($id) != 28 || substr($id, -1, 1) ne "-" || $valid ne "")
{
    $cd->PrintError("The disk id you are trying to submit ($id) is invalid.");
}

$cd->Login();
$album = $cd->GetAlbumFromDiskId($id);
if ($album >= 0)
{
    print <<END;

    Thank you for your submission, but this CD is already in the index. 
    <p>If you cannot retrieve this
    CD for some reason, please <a href="mailto:rob\@emusic.com">
    send</a> me some mail.
    </TD></TR></TABLE>
END

    $cd->Logout;
    $cd->Footer;
    exit();
}

print <<END;
Please follow the instructions below:
<p>
<center>
Does the CD have a single artist or multiple artists?
</center>
<p>

<table cellspacing=0 width=100%>
<tr>
<th bgcolor="#D60021" valign=top>
<font color="#FFFFFF">
Single Artist CDs
</font>
</th>
<th bgcolor="#D60021" valign=top>
&nbsp;
</th>
<th bgcolor="#D60021">
<font color="#FFFFFF">
Multiple Artists CDs
</font>
</th>
</tr>
<td align=center>
END
                          
print $o->start_form(-action=>'artist.pl');

print "<br>Enter the name of the <font color=red>Artist</font><br> and\n";
print "click on <b>search</b>:<p>";
print $o->textfield(-name=>'search',size=>'30');
print $o->hidden(-name=>'id',-default=>'$id');
print $o->hidden(-name=>'toc',-default=>$toc);
print $o->hidden(-name=>'tracks',-default=>'$tracks');

print $o->p,$o->submit('Search>>');
print $o->end_form;

print '</td><td bgcolor="#D60021">&nbsp;</td><td align=center valign=top>';

print $o->start_form(-action=>'malbum.pl');

print "<br>Enter the name of the <font color=red>CD</font><br> and\n";
print "click on <b>search</b>:<p>";
print $o->textfield(-name=>'search',size=>'30');
print $o->hidden(-name=>'id',-default=>'$id');
print $o->hidden(-name=>'toc',-default=>$toc);
print $o->hidden(-name=>'tracks',-default=>'$tracks');

print $o->p,$o->submit('Search>>');
print $o->end_form;

print "</td></tr></table>\n";


print <<END;
<center>
<br><br>
All data submitted to the CD Index will be covered by the 
<a href="http://opencontent.org/opl.shtml">OpenContent</a> license.
</center>
END

$cd->Logout;
$cd->Footer;
