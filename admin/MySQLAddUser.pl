#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   Obsequeium -- the Internet MP3 Jukebox
#
#   Copyright (C) 1998 GoodNoise Corp. 
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
use DBI;
require "MySQLdb.pl";

if($#ARGV < 0)
{
    print STDERR "MySql_adduser <username> <host> <rootpwd> gives <username> full access to mysql ";
    print STDERR "databases\n";

    exit;
}

$Password = $ARGV[2] ? $ARGV[2] : '';
($ReturnCode, $hDB) = &InitializeConnection("mysql", "mysql", "root", $Password);

#First, delete any blank users from the database, which would supercede this 
#one:
die "Unable to connect to database:  $ReturnCode" if($ReturnCode);

$Command = "delete from user where user=\"\"";
$hCommand = $hDB->prepare($Command) || 
    die "Can't prepare command:  $DBI::errstr";
$hCommand->execute;


#Now, add each user:
$Arg = $ARGV[0];

$Host = "localhost";
$Host = $ARGV[1] if($ARGV[1]);

print "Adding $Arg...\n";

#Delete the user in case he exists with different privs:
$Command = "delete from user where user=\"$Arg\" and Host=\"$Host\"";
$hCommand = $hDB->prepare($Command) || 
    die "Can't prepare command:  $DBI::errstr";
$hCommand->execute;


undef(%User);

$User{"Host"} = $Host;
$User{"User"} = $Arg;
$User{"Password"} = "";
$User{"Select_priv"} = "Y";
$User{"Insert_priv"} = "Y";
$User{"Update_priv"} = "Y";
$User{"Delete_priv"} = "Y";
$User{"Create_priv"} = "Y";
$User{"Drop_priv"} = "Y";
$User{"Reload_priv"} = "Y";
$User{"Shutdown_priv"} = "Y";
$User{"Process_priv"} = "Y";
$User{"File_priv"} = "Y";
$User{"Alter_priv"} = "Y";

($ReturnCode, %User) = &SaveSingleObject($hDB, "user", %User);

die "Unable to save user $Arg:  $ReturnCode" if($ReturnCode);

&ShutdownConnection($hDB);

@Admin = ("/usr/local/bin/mysqladmin",
	  "/usr/local/mysql/bin/mysqladmin");

@PathDirs = split(/:/, $ENV{"PATH"});

foreach $Dir (@PathDirs)
{
    #Strip trailing slashes, if any:
    $Dir =~ s/\/$//;
    $Admin[$#Admin + 1] = "${Dir}/mysqladmin";
}

$Admin = "";
$Index = 0;

while((!$Admin) && ($Index <= $#Admin))
{
    if(-x $Admin[$Index])
    {
	$Admin = $Admin[$Index];
    }
    $Index++;
}

if($Admin)
{
    print "Running \"mysqladmin reload\" to resynch permissions...\n";
    system("$Admin -u root --password=\"$Password\" reload") && die "Can't run $Admin!\n";
}
else
{
    print STDERR "Unable to find mysqladmin; be sure to run ";
    print STDERR "\"mysqladmin reload\" so that changes\ntake effect.\n";
    exit;
}

print "Complete.\n";

		       





