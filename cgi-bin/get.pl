MusicBrainzusr/bin/perl -w
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
use DBDefs;
use MusicBrainz;

my ($o, $cd); 
my ($tracks, $i, $artist, $artistname, $title, $album, $albumid, $id);
my ($dbh, $sth, $rv);

sub DumpAlbum
{
   my $albumid = $_[0];
	my $sth;
	my $artistid;
	my $albumname;
	my $artistname;
	my $i;

	$sth = $dbh->prepare("select name,artist from Album where id='$albumid'");
   if ($sth->execute)
   {
       my @row;
   
       @row = $sth->fetchrow_array;
  	    $albumname = $row[0];
  	    $artistid = $row[1];
    
       $sth->finish;

       if ($artistid)
		 {
	        $sth = $dbh->prepare("select name from Artist where id='$artistid'");
           if ($sth->execute)
           {
               @row = $sth->fetchrow_array;
  	            $artistname = $row[0];
    
               $sth->finish;
           }
       }
		 else
		 {
		     $artistname = "(various)";
       }

       print "Artist: $artistname\n";
       print "Album: $albumname\n";

		 my (@tracks, @artists, @artistids);

	    $sth = $dbh->prepare("select name,artist from Track where " . 
		                      "album='$albumid' order by sequence");
       if ($sth->execute)
     	 {
		     print "Tracks: " . $sth->rows . 
			        "\n";
           $i = 0;
	        while(@row = $sth->fetchrow_array)
			  {
			      $tracks[$i] = $row[0]; 
			      $artistids[$i] = $row[1]; 
			      $i++;
           }
       } 
		 $sth->finish;

       if ($artistid == 0)
		 {
           $i = 0;
	        for($i = 0; $i < scalar(@tracks); $i++)
		     {
	            print "Track";
					print $i + 1;
					print ": $tracks[$i]\n";

	            $sth = $dbh->prepare("select name from Artist where " . 
		                          "id='$artistids[$i]'");
               if ($sth->execute)
     	         {
	                @row = $sth->fetchrow_array;
	                print "Artist";
						 print $i + 1;
					    print ": $row[0]\n";
               } 
		         $sth->finish;

           }
       }
       else
		 {
	        for($i = 0; $i < scalar(@tracks); $i++)
		     {
	            print "Track";
					print $i + 1;
					print ": $tracks[$i]\n";
           }
       }
   }
}

$cd = new MusicBrainz;
$o = $cd->GetCGI;  

print("Content-type: text/plain\n\n");

if ($o->param('id') eq '')
{
print <<END;

	 Error:
	 You must specify the 'id' argument as part of the URL for this page.
END
	 exit;
}

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "Sorry, the database is currently\n";
    print "not available. Please try again in a few minutes.\n";
	 print "(Error: ".$DBI::errstr.")";
} 
else
{
    $id = $o->param('id');

	 $sth = $dbh->prepare("select Album from Diskid where disk='$id'");
    $sth->execute;
    if ($sth->rows)
    {
        my @row;

        print "NumMatches: " . $sth->rows;
        print "\n";
    	  while(@row = $sth->fetchrow_array)
    	  {
    			DumpAlbum($row[0]);
        }
        $sth->finish;
    }
    else
    {
        $sth->finish;
        if (defined $o->param('tracks') && defined $o->param('toc'))
        {
            my $toc;
            my (@fuzzy, $last);

            $toc = $o->param('toc');
            @fuzzy = $cd->FindFuzzy($dbh, $o->param('tracks'), $toc);
            if (scalar(@fuzzy) == 0)
            {
                 print "NumMatches: 0\n";
            }
            else
            {
                 while(defined($last = pop @fuzzy))
                 {
    			        DumpAlbum($last);
                 }
            }
        }
        else
        {
            print "NumMatches: 0\n";
        }
    }
	 print "\n\n";
}

if ($dbh)
{
    $dbh->disconnect();
}
