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

$DebugQueries = 0;

sub InitializeConnection
{
    my($Method, $Database, $UserID, $Password) = @_;
    my($dbh);

    $Password = "" if(!$Password);

    print STDERR "\n" if($DebugQueries);

    $drh = DBI->install_driver('mysql') ||
	return("Unable to install mysql driver", 0);

    $dbh = $drh->connect($Database, $UserID, $Password, $Method) ||
	return("Unable to connect to to database " .
	       "$Database as $UserID:\n$DBI::errstr", 0);
    return(0, $dbh);
}

sub ShutdownConnection
{
    my($dbh) = @_;

    $dbh->disconnect;
}


sub LoadSingleObject
{
    my($hDB, $Table, %Object) = @_;
    my($Command, $hCommand, $Row, $Rows);
    my($IsFirst) = 1;
    my(%NewObject, %Query);

    if($Object{"${Table}_id"})
    {
	$Query{"${Table}_id"} = $Object{"${Table}_id"};
    }
    else
    {
	%Query = %Object
    }

    $Command = "select * from $Table";
    foreach $Row (sort(keys(%Query)))
    {
#	if((0 ||
	if(($Row !~ /^${Table}_id$/i ||
	    ($Query{$Row} && ($Query{$Row} != 0))))
	{
	    if($IsFirst)
	    {
		$IsFirst = 0;
		$Command .= " where ";
	    }
	    else
	    {
		$Command .= " AND ";
	    }
#	    $Query{$Row} =~ s/\'/\\\'/;
#	    $Command .= " $Row='$Query{$Row}'";
	    $Command .= "$Row = ";
	    $Command .= $hDB->quote($Query{$Row});
	}
    }

    if(!$IsFirst) #Do we actually have a query?
    {
	print STDERR __LINE__ . ":$Command\n" if ($DebugQueries);

	$hCommand = $hDB->prepare($Command);
	$NumRows = $hCommand->execute || 
	    return("Can't execute command:  $DBI::errstr\n");
	
	if($NumRows > 1)
	{
	    $hCommand->finish;
	    return("Multiple matches");
	}
	
	if($Rows = $hCommand->fetchrow_hashref)
	{
	    %NewObject = %$Rows;
	}
	else
	{
	    return("No Matches");
	}
	
	$hCommand->finish;
    }

    return(0, %NewObject);
}

sub DumpObject
{
    my(%Object) = @_;
    my($Key);

    foreach $Key (sort(keys(%Object)))
    {
	print STDERR "$Key = $Object{$Key}\n" if($DebugQueries);
    }
}

sub SaveSingleObject
{
    my($hDB, $Table, %Object) = @_;
    my($Command, $hCommand, $Row);
    my($IsFirst) = 1;

    $Command = "replace into $Table (";
    foreach $Row (sort(keys(%Object)))
    {
	if($IsFirst)
	{
	    $IsFirst = 0;
	}
	else
	{
	    $Command .= ",";
	}
	$Command .= "$Row";
    }

    $Command .= ") values (";
    $IsFirst = 1;

    foreach $Row (sort(keys(%Object)))
    {
	if($IsFirst)
	{
	    $IsFirst = 0;
	}
	else
	{
	    $Command .= ",";
	}
	if($Object{$Row})
	{
#	    $Object{$Row} =~ s/\'/\\\'/;
#	    $Command .= "\'$Object{$Row}\'";
	    $Command .= $hDB->quote($Object{$Row});
	}
	else
	{
	    $Command .= "\'\'";
	}
    }

    $Command .= ")";

    print STDERR __LINE__  . ":$Command\n" if ($DebugQueries);
    $hCommand = $hDB->prepare($Command);
    $hCommand->execute || return("Can't execute command:  $DBI::errstr\n");
    $Object{"${Table}_id"} = $hCommand->{mysql_insertid};
    $hCommand->finish;

    return(0, %Object);
}

sub DeleteObjects
{
    my($hDB, $Table, %Object) = @_;
    my($Command, $hCommand, $Row, $Rows);
    my(%Query);

    if($Object{"${Table}_id"})
    {
	$Query{"${Table}_id"} = $Object{"${Table}_id"};
    }
    else
    {
	%Query = %Object
    }

    $Command = "delete from $Table where";
    foreach $Row (sort(keys(%Query)))
    {
	if($Row !~ /^${Table}_id$/i || 
	    ($Query{$Row} && ($Query{$Row} != 0)))
	{
	    if($IsFirst)
	    {
		$IsFirst = 0;
	    }
	    else
	    {
		$Command .= " AND";
	    }
	    $Command .= $hDB->quote($Query{$Row});
	}
    }

    print STDERR __LINE__  . ":$Command\n" if ($DebugQueries);

    $hCommand = $hDB->prepare($Command);
    $NumRows = $hCommand->execute || 
        return("Can't execute command:  $DBI::errstr\n");

    if(!$NumRows)
    {
	$hCommand->finish;
	return("No matches");
    }

    return(0);
}

sub BeginQuery
{
    my($hDB, $Table, $OrderBy, %Object) = @_;
    my($Command, $hCommand, $Row, $Rows);
    my($IsFirst) = 1;
    my(%NewObject);

    $Command = "select * from $Table";
    foreach $Row (sort(keys(%Object)))
    {
#	if($Row !~ /^${Table}_id$/i ||
#	   $Object{$Row} != 0)
	{
	    if($IsFirst)
	    {
		$IsFirst = 0;
		$Command .= " where";
	    }
	    else
	    {
		$Command .= " AND";
	    }
	    $Object{$Row} =~ s/\'/\\\'/;
	    $Command .= " $Row='$Object{$Row}'";
	}
    }

    if($OrderBy)
    {
	$Command .= " order by $OrderBy";
    }

    print STDERR __LINE__ . ":$Command\n" if ($DebugQueries);

    $hCommand = $hDB->prepare($Command);
    $NumRows = $hCommand->execute ||
	return("Can't execute command:  $DBI::errstr\n");

    $NumRows = 0 if($NumRows eq "0E0");

    if(!$NumRows)
    {
	$hCommand->finish;
	return("No Matches", 0);
    }

    return(0, $NumRows, $hCommand);
}

sub LoadNextMatch
{
    my($hCommand) = @_;

    if(($Rows = $hCommand->fetchrow_hashref))
    {
	%NewObject = %$Rows;
    }
    else
    {
	return;
    }
    return(%NewObject);
}

sub EndQuery
{
    my($hCommand) = @_;

    $hCommand->finish();
}

1;
