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

use lib "../cgi-bin";
use DBI;
use DBDefs;

# Make the connection to the database
$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD)
       or die "Cannot connect to database";

print "Connected to database.\n";

# create the tables
$dbh->do("create table Artist (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(100) NOT NULL," . 
         "   GID varchar(64) NOT NULL," . 
         "   WebPage blob," . 
         "   AuxPage blob," .
         "   LastChanged datetime," .
         "   ModPending int," .
         "   index NameIndex (Name)," .
         "   index GIDIndex (GID)," .
         "   unique (Name))")
      or die("Cannot create Artist table");

print "Created Artist table.\n";

$dbh->do("create table Album (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(100) NOT NULL," .
         "   GID varchar(64) NOT NULL," . 
         "   Artist int NOT NULL," .
         "   WebPage blob," .
         "   AuxPage blob," .
         "   LastChanged datetime," .
         "   ModPending int," .
         "   index GIDIndex (GID)," .
         "   index NameIndex (Name))")
      or die("Cannot create Album table");

print "Created Album table.\n";

$dbh->do("create table Track (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(255) not null ," .
         "   GID varchar(64) not null," . 
         "   GUID varchar(64)," . 
         "   Artist int not null," .
         "   Album int not null," .
         "   Sequence int not null," .
         "   Length int," .
         "   Year int," .
         "   Genre int," .
         "   Filename varchar(255)," .
         "   Comment text," .
         "   WebPage blob," .
         "   AuxPage blob," .
         "   LastChanged datetime," .
         "   ModPending int," .
         "   index GIDIndex (GID)," .
         "   index NameIndex (Name)," .
         "   index AlbumIndex (Album))") 
      or die("Cannot create Track table");
		
print "Created Track table.\n";

$dbh->do("create table Genre (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(64) not null," .
         "   ModPending int," .
         "   Description varchar(255))")
      or die("Cannot create Genre table");
		
print "Created Genre table.\n";

$dbh->do("create table Pending (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(255)," .
         "   GUID varchar(64) not null," . 
         "   Artist varchar(100)," .
         "   Album varchar(100)," .
         "   Sequence int not null," .
         "   Length int," .
         "   Year int," .
         "   Genre varchar(64)," .
         "   Filename varchar(255)," .
         "   Comment text," .
         "   index GUIDIndex (GUID))") 
      or die("Cannot create Pending table");
		
print "Created Pending table.\n";

$dbh->do("create table PendingArchive (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(255)," .
         "   GUID varchar(64) not null," . 
         "   Artist varchar(100)," .
         "   Album varchar(100)," .
         "   Sequence int not null," .
         "   Length int," .
         "   Year int," .
         "   Genre varchar(64)," .
         "   Filename varchar(255)," .
         "   Comment text," .
         "   index GUIDIndex (GUID))") 
      or die("Cannot create Pending table");
		
print "Created PendingArchive table.\n";

$dbh->do("create table Diskid (" .
         "   Id int auto_increment primary key," .
         "   Disk char(32) not null ," .
         "   Album int not null," .
         "   Crc int unsigned," .
         "   TimeCreated datetime, ".
         "   Toc varchar(255), ".
         "   LastChanged datetime," .
         "   ModPending int," .
         "   index AlbumIndex (Album)," .
         "   index DiskIndex (Disk))")
      or die("Cannot create Diskid table");

print "Created Diskid table.\n";

$query = "create table TOC (" .
         "   Id int auto_increment primary key," .
         "   Diskid varchar(32),".
         "   Album int,".
         "   Tracks int,".
         "   Leadout int";

for($i = 1; $i < 100; $i++)
{
    $query .= ", Track$i int";
}

$query .= ")";

$dbh->do($query)
      or die("Cannot create toc table");

print "Created TOC table.\n";

$host = shift;
if (!defined $host)
{
   $host = `hostname`;
   chop($host);
}

$host = $dbh->quote($host);
$dbh->do("create table GlobalId (" .
         "   Id int auto_increment primary key," .
         "   MaxIndex int," .
         "   Host varchar(255))")
      or die("Cannot create GlobalId table");
$dbh->do("insert into GlobalId (MaxIndex, Host) values (1, $host)")
      or die("Cannot insert default value into GlobalId table");

print "Created Globalid table.\n";

$dbh->do("create table ModeratorInfo (" .
         "   Id int auto_increment primary key," .
         "   Name varchar(64)," .
         "   Password varchar(64), ".
         "   Privs int, ".
         "   ModsAccepted int, ".
         "   ModsRejected int)")
      or die("Cannot create ModeratorInfo table");

print "Created ModeratorInfo table.\n";

$dbh->do("create table Changes (" .
         "   Id int auto_increment primary key," .
         "   Tab varchar(32) not null," .
         "   Col varchar(64) not null, ".
         "   Rowid int not null, ".
         "   PrevValue varchar(255), ".
         "   NewValue varchar(255), ".
         "   TimeSubmitted datetime not null, ".
         "   Moderator int, ".
         "   YesVotes int, ".
         "   NoVotes int)")
      or die("Cannot create Changes table");

print "Created Changes table.\n";

$dbh->do("create table Votes (" .
         "   Id int auto_increment primary key," .
         "   Uid int not null, ".
         "   Rowid int not null, ".
         "   vote tinyint not null, ".
         "   index UidIndex (Uid))") 
      or die("Cannot create Votes table");

print "Created Votes table.\n";

if (DBDefs->USE_LYRICS)
{
   # create theSyncText table.
   #this table contains the index of SyncEvents. 1 set of SyncEvents has
   #1 entry in this table. For each entry the track is registered for which the 
   #SyncEvents are valid. The type indicates if these are humorous remarks,
   #facts about the artist, facts about the songs, facts of life, 
   #or the actual lyrics of the song. The URL field contains a pointer to the 
   #Usenet message that contained the SyncEvents, optional field. The submittor 
   #field contains the nickname, realname or nickname <e-mail> of the 
   #submittor. Submitted contains the time/date when the entry is inserted.
   $dbh->do("create table SyncLyrics (" .
            "   Id        int      auto_increment primary key," .
            "   Track     int      not null," .
            "   Type      tinyint  not null," .
            "   URL       text     ," .
            "   Submittor text     ," .
            "   Submitted datetime not null)")
         or die("Cannot create SyncText table");
   print "Created SyncText table.\n";
   
   #The SyncEvent table contains a set of timestamps and text for a given 
   #SyncText. The SyncText field points back to the SyncText table, which 
   #must be present. Depending on the Type of the SyncText the SyncEvent 
   #table can contain facts #about the song, the lyrics, etc..
   $dbh->do("create table SyncEvent (" .
            "   Id       int      auto_increment primary key," .
            "   SyncText int      not null," .
            "   Ts       int      not null," .
            "   Text     text     not null," .
            "   index    SyncTextIndex (SyncText))") 
         or die("Cannot create SyncEvent table");
   print "Created SyncEvent table.\n";
}
else
{
   print "Skipping creation of lyrics tables.\n";
}

# Disconnect
$dbh->disconnect();

print "\nCreated tables successfully.\n";
