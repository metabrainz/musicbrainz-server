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
use MusicBrainz;

sub CreateTables
{
    my ($dbh, $host) = @_;

    # create the tables
    $dbh->do("create table Artist (" .
             "   Id int auto_increment primary key," .
             "   Name varchar(255) NOT NULL," . 
             "   SortName varchar(100) NOT NULL," . 
             "   GID varchar(64) NOT NULL," . 
             "   WebPage blob," . 
             "   AuxPage blob," .
             "   ModPending int," .
             "   LastChanged datetime) ") 
          or die("Cannot create Artist table");

    print "Created Artist table.\n";

    $dbh->do("create table Album (" .
             "   Id int auto_increment primary key," .
             "   Name varchar(255) NOT NULL," .
             "   GID varchar(64) NOT NULL," . 
             "   Artist int NOT NULL," .
             "   WebPage blob," .
             "   AuxPage blob," .
             "   ModPending int," .
             "   LastChanged datetime) ")
          or die("Cannot create Album table");

    print "Created Album table.\n";

    $dbh->do("create table Track (" .
             "   Id int auto_increment primary key," .
             "   Name varchar(255) not null ," .
             "   GID varchar(64) NOT NULL," . 
             "   Artist int not null," .
             "   Length int," .
             "   Year int," .
             "   Genre int," .
             "   Filename varchar(255)," .
             "   Comment text," .
             "   WebPage blob," .
             "   AuxPage blob," .
             "   ModPending int," .
             "   LastChanged datetime) ")
          or die("Cannot create Track table");

    print "Created Track table.\n";

    $dbh->do("create table GUID (" .
             "   Id int auto_increment primary key," .
             "   GUID char(36) NOT NULL)")
          or die("Cannot create GUID table");

    print "Created GUID table.\n";

    $dbh->do("create table AlbumJoin (" .
             "   Id int auto_increment primary key," .
             "   Album int NOT NULL," .
             "   Track int NOT NULL," .
             "   Sequence int NOT NULL," .
             "   ModPending int)")
          or die("Cannot create AlbumJoin table");

    print "Created AlbumJoin table.\n";

    $dbh->do("create table GUIDJoin (" .
             "   Id int auto_increment primary key," .
             "   GUID int NOT NULL," . 
             "   Track int NOT NULL)")
          or die("Cannot create GUIDJoin table");

    print "Created GUIDJoin table.\n";

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
             "   Sequence int," .
             "   Length int," .
             "   Year int," .
             "   Genre varchar(64)," .
             "   Filename varchar(255)," .
             "   Comment text) ")
          or die("Cannot create Pending table");

    print "Created Pending table.\n";

    $dbh->do("create table PendingArchive (" .
             "   Id int auto_increment primary key," .
             "   Name varchar(255)," .
             "   GUID varchar(64) not null," . 
             "   Artist varchar(100)," .
             "   Album varchar(100)," .
             "   Sequence int," .
             "   Length int," .
             "   Year int," .
             "   Genre varchar(64)," .
             "   Filename varchar(255)," .
             "   Comment text) ")
          or die("Cannot create Pending table");

    print "Created PendingArchive table.\n";

    $dbh->do("create table Diskid (" .
             "   Id int auto_increment primary key," .
             "   Disk char(32) not null ," .
             "   Album int not null," .
             "   Crc int unsigned," .
             "   TimeCreated datetime, ".
             "   Toc varchar(255), ".
             "   LastChanged datetime) ")
          or die("Cannot create Diskid table");

    print "Created Diskid table.\n";

    $query = "create table TOC (" .
             "   Id int auto_increment primary key," .
             "   Diskid varchar(32) not null,".
             "   Album int not null,".
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
             "   Name varchar(64) not null," .
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
             "   Artist int not null, ".
             "   Type tinyint not null, ".
             "   Status tinyint not null, ".
             "   Rowid int not null, ".
             "   PrevValue varchar(255), ".
             "   NewValue varchar(255), ".
             "   TimeSubmitted datetime not null, ".
             "   Moderator int not null, ".
             "   YesVotes int, ".
             "   NoVotes int)")
          or die("Cannot create Changes table");
          
    print "Created Changes table.\n";
    
    $dbh->do("create table Votes (" .
             "   Id int auto_increment primary key," .
             "   Uid int not null, ".
             "   Rowid int not null, ".
             "   vote tinyint not null)")
          or die("Cannot create Votes table");
    
    print "Created Votes table.\n";    

    if (DBDefs->USE_LYRICS)
    {
       # create the Lyrics table.
       #The Lyrics table contains the text of the track indicated with the 
       #Track int value.
       #With this structure 1 track could have 0,1, or more Lyrics records.
       #Currently the Insert scripts only allow 0 or 1 Lyrics record.
       $dbh->do("create table Lyrics (" .
                "   Id        int      auto_increment primary key," .
                "   Track     int      not null," .
                "   Text      text     not null," .
                "   Writer    varchar(64)) ")
             or die("Cannot create Lyrics table");
       print "Created Lyrics table.\n";
 
       #this table contains the index of SyncEvents. 1 set of SyncEvents has
       #1 entry in this table. For each entry the track is registered for which the 
       #SyncEvents are valid. The type indicates if these are humorous remarks,
       #facts about the artist, facts about the songs, facts of life, 
       #or the actual lyrics of the song. The URL field contains a pointer to the 
       #Usenet message that contained the SyncEvents, optional field. The submittor 
       #field contains the nickname, realname or nickname <e-mail> of the 
       #submittor. Submitted contains the time/date when the entry is inserted.
       $dbh->do("create table SyncText (" .
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
                "   Text     text     not null) ")
             or die("Cannot create SyncEvent table");
       print "Created SyncEvent table.\n";
      }
    else
    {
       print "Skipping creation of lyrics tables.\n";
    }

    print "\nCreated tables successfully.\n";
}


sub CreateIndices
{
    my ($dbh) = @_;

    $dbh->do(qq/alter table Artist add unique index NameIndex (Name), 
                                   add unique index SortNameIndex (SortName), 
                                   add unique index GIDIndex (GID)/)
          or die("Could not add indices to Artist table");
    print "Added indices to Artist table.\n";

    $dbh->do(qq/alter table Album add index NameIndex (Name), 
                                  add unique index GIDIndex (GID)/)
          or die("Could not add indices to Album table");
    print "Added indices to Album table.\n";

    $dbh->do(qq/alter table Track add index NameIndex (Name), 
                                  add unique index GIDIndex (GID), 
                                  add index ArtistIndex (Artist)/)
          or die("Could not add indices to Track table");
    print "Added indices to Track table.\n";

    $dbh->do(qq/alter table GUID add unique index GUIDIndex (GUID)/)
          or die("Could not add indices to GUID table");
    print "Added indices to GUID table.\n";

    $dbh->do(qq/alter table AlbumJoin add index AlbumIndex (Album), 
                                      add index TrackIndex (Track)/)
          or die("Could not add indices to AlbumJoin table");
    print "Added indices to AlbumJoin table.\n";

    $dbh->do(qq/alter table GUIDJoin add index GUIDIndex (GUID), 
                                     add index TrackIndex (Track)/)
          or die("Could not add indices to GUIDJoin table");
    print "Added indices to GUIDJoin table.\n";

    $dbh->do(qq/alter table Genre add unique index NameIndex (Name)/)
          or die("Could not add indices to Genre table");
    print "Added indices to Genre table.\n";

    $dbh->do(qq/alter table Pending add index GUIDIndex (GUID)/)
          or die("Could not add indices to Pending table");
    print "Added indices to Pending table.\n";

    $dbh->do(qq/alter table PendingArchive add index GUIDIndex (GUID)/)
          or die("Could not add indices to PendingArchive table");
    print "Added indices to PendingArchive table.\n";

    $dbh->do(qq/alter table Diskid add index AlbumIndex (Album), 
                                   add index DiskIndex (Disk)/)
          or die("Could not add indices to Diskid table");
    print "Added indices to Diskid table.\n";

    $dbh->do(qq/alter table TOC add index DiskIndex (Diskid), 
                                add index AlbumIndex (Album) /)
          or die("Could not add indices to TOC table");
    print "Added indices to TOC table.\n";

    $dbh->do(qq/alter table ModeratorInfo add index NameIndex (Name)/)
          or die("Could not add indices to ModeratorInfo table");
    print "Added indices to ModeratorInfo table.\n";

    $dbh->do(qq/alter table Changes add index ModeratorIndex (Moderator), 
                            add index TimeSubmittedIndex (TimeSubmitted),
                            add index StatusIndex (Status)/)
          or die("Could not add indices to Changes table");
    print "Added indices to Changes table.\n";

    $dbh->do(qq/alter table Votes add index UidIndex (Uid)/)
          or die("Could not add indices to Votes table");
    print "Added indices to Votes table.\n";

    if (DBDefs->USE_LYRICS)
    {
       $dbh->do(qq/alter table Lyrics add index TrackIndex (Track)/)
             or die("Could not add indices to Lyrics table");
       print "Added indices to Lyrics table.\n";

       $dbh->do(qq/alter table SyncText add index TrackIndex (Track), 
                                        add index TypeIndex (Type) /)
             or die("Could not add indices to SyncText table");
       print "Added indices to SyncText table.\n";

       $dbh->do(qq/alter table SyncEvent add index SyncTextIndex (SyncText)/)
             or die("Could not add indices to SyncEvent table");
       print "Added indices to SyncEvent table.\n";
    }
    else
    {
       print "Skipping creation of lyrics indices.\n";
    }
    print "\nCreated indices successfully.\n";
}

my ($indices, $tables, $arg, $mb, $host);

$indices = 0;
$tables = 0;

while(defined($arg = shift))
{
    if ($arg eq '-t')
    {
        $tables = 1 
    }
    elsif ($arg eq '-i')
    {
        $indices = 1 
    }
    else
    {
        $host = $arg;
    }
}

if ($indices == 0 && $tables == 0)
{
    print "Usage: CreateTables.pl <options> [hostname]\n\n";
    print "Options:\n";
    print "   -t   Create database tables\n";
    print "   -i   Create database indices\n";
    exit(0);
}

$mb = MusicBrainz->new;
$mb->Login;

print "Connected to database.\n";

if ($tables)
{
    print "Creating MusicBrainz Tables.\n\n";
    CreateTables($mb->{DBH}, $host);
}
if ($indices)
{
    print "Adding indices to MusicBrainz Tables.\n\n";
    CreateIndices($mb->{DBH});
}

# Disconnect
$mb->Logout;
