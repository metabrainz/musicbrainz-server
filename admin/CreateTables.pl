#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
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
use Artist;
use ModDefs;
use Sql;

# alter table album add column Attributes int[];
# alter table album alter column Attributes set default '{0}';
# update album set attributes = '{0}';
# alter table TRM add column LookupCount int;
# alter table TRM alter column LookupCount set default 0;
# update TRM set lookupcount = 0;

sub CreateTables
{
    my ($sql) = @_;

    eval
    {
        $sql->Begin;
        $sql->Do(qq|create table Artist (
                       Id serial primary key,
                       Name varchar(255) not null,
                       GID char(36) not null,
                       ModPending int default 0,
                       SortName varchar(255) not null)|)
              or die("Cannot create Artist table");
        print "Created Artist table.\n";
    
        $sql->Do(qq|create table ArtistAlias (
                        Id serial primary key,
                        Ref int not null references Artist, 
                        Name varchar(255) not null, 
                        LastUsed datetime not null,
                        TimesUsed int default 0,
                        ModPending int default 0)|)
              or die("Cannot create ArtistAlias table");
        
        print "Created ArtistAlias table.\n";    
    
        $sql->Do(qq|create table Album (
                       Id serial primary key,
                       Artist int not null references Artist,
                       Name varchar(255) not null,
                       GID char(36) not null, 
                       ModPending int default 0,
                       Attributes int[] default '{0}')| )
              or die("Cannot create Album table");
            
        print "Created Album table.\n";

        $sql->Do(qq|create table Track (
                       Id serial primary key,
                       Artist int not null references Artist,
                       Name varchar(255) not null,
                       GID char(36) not null, 
                       Length int default 0,
                       Year int default 0,
                       ModPending int default 0)| )
              or die("Cannot create Track table");

        print "Created Track table.\n";

        $sql->Do(qq|create table AlbumJoin (
                       Id serial primary key,
                       Album int not null references Album,
                       Track int not null references Track,
                       Sequence int not null,
                       ModPending int default 0)|)
              or die("Cannot create AlbumJoin table");

        print "Created AlbumJoin table.\n";

        $sql->Do(qq|create table TRM (
                       Id serial primary key,
                       TRM char(36) not null,
                       LookupCount int default 0)|)
              or die("Cannot create TRM table");

        print "Created TRM table.\n";

        $sql->Do(qq|create table TRMJoin (
                       Id serial primary key,
                       TRM int not null references TRM, 
                       Track int not null references Track)|)
              or die("Cannot create TRMJoin table");

        print "Created TRMJoin table.\n";

        $sql->Do(qq|create table Discid (
                       Id serial primary key,
                       Album int not null references Album,
                       Disc char(28) not null unique,
                       Toc text not null, 
                       ModPending int default 0)|)
              or die("Cannot create Discid table");

        print "Created Discid table.\n";

        $query = qq|create table TOC (
                       Id serial primary key,
                       Album int not null references Album,
                       Discid char(28) references Discid (Disc),
                       Tracks int,
                       Leadout int|;

        for($i = 1; $i < 100; $i++)
        {
            $query .= ", Track$i int";
        }

        $query .= ")";

        $sql->Do($query)
              or die("Cannot create toc table");

        print "Created TOC table.\n";

        $sql->Do(qq|create table Moderator (
                       Id serial primary key,
                       Name varchar(64) not null,
                       Password varchar(64) not null, 
                       Privs int default 0, 
                       ModsAccepted int default 0,
                       ModsRejected int default 0, 
                       EMail varchar(64) default null, 
                       WebUrl varchar(255) default null, 
                       MemberSince datetime default now(),
                       Bio text default null)|)
              or die("Cannot create Moderator table");
        
        print "Created Moderator table.\n";
        
        $sql->Do(qq|create table Moderation (
                       Id serial primary key,
                       Artist int not null references Artist, 
                       Moderator int not null references Moderator, 
                       Tab varchar(32) not null,
                       Col varchar(64) not null, 
                       Type smallint not null, 
                       Status smallint not null, 
                       Rowid int not null, 
                       PrevValue varchar(255) not null, 
                       NewValue text not null, 
                       ExpireTime timestamp not null, 
                       YesVotes int default 0, 
                       NoVotes int default 0,
                       Depmod int default 0,
                       Automod smallint default 0)|)
              or die("Cannot create Moderation table");
              
        print "Created Moderation table.\n";

        $sql->Do(qq|create table ModerationNote (
                          Id serial primary key,
                          ModId int not null, 
                          Uid int not null, 
                          Text varchar(255) not null)|)
              or die("Cannot create ModerationNote table");
        
        print "Created ModerationNote table.\n";

        $sql->Do(qq|create table Votes (
                       Id serial primary key,
                       Uid int not null references Moderator, 
                       Rowid int not null references Moderation, 
                       vote smallint not null)|)
              or die("Cannot create Votes table");
        
        print "Created Votes table.\n";    
        
        $sql->Do(qq|create table WordList (
                          Id serial primary key,
                          Word varchar(255) not null) |)
           or die("Cannot create WordList table");
        
        print "Created WordList table.\n";    
        
        $sql->Do(qq| create table ArtistWords (
                          Wordid int not null,
                          Artistid int not null) |)
              or die("Cannot create ArtistWords table");

        print "Created ArtistWords table.\n";    
        
        $sql->Do(qq| create table AlbumWords (
                          Wordid int not null,
                          Albumid int not null) |)
              or die("Cannot create AlbumWords table");

        print "Created AlbumWords table.\n";    
        
        $sql->Do(qq| create table TrackWords (
                          Wordid int not null,
                          Trackid int not null) |)
              or die("Cannot create TrackWords table");

        print "Created TrackWords table.\n";    

        $sql->Do(qq|create table Stats (
                          Id serial primary key,
                          artists int not null, 
                          albums int not null, 
                          tracks int not null, 
                          discids int not null, 
                          trmids int not null, 
                          moderations int not null, 
                          votes int not null, 
                          moderators int not null, 
                          timestamp date not null)|)
              or die("Cannot create Stats table");
        
        print "Created Stats table.\n";
  
        $sql->Commit;
    };
    if ($@)
    {
        $sql->Rollback;
        print "Failed to create tables.\n($@)\n";
        return 0;
    }
    print "Created tables successfully.\n\n";

    return 1;
}

sub InsertDefaultRows
{
    my ($sql) = @_;
    my ($ar, %mb);

    eval
    {
        $sql->Begin;

        $mb{DBH} = $sql;
        $ar = Artist->new($mb{DBH});
        $id = $sql->Quote($ar->CreateNewGlobalId());
        $sql->Do(qq|insert into Artist (Name, SortName, GID, ModPending) 
                    values ('Various Artists', 'Various Artists', $id, 0)|); 

        $id = $sql->Quote($ar->CreateNewGlobalId());
        $sql->Do(qq|insert into Artist (Name, SortName, GID, ModPending) 
                    values ('Deleted Artist', 'Deleted Artist', $id, 0)|); 

        $sql->Do(qq|insert into Moderator (Name, Password, Privs, 
                    ModsAccepted, ModsRejected, MemberSince) values 
                    ('Anonymous', '', 0, 0, 0, now())|);
        $sql->Do(qq|insert into Moderator (Name, Password, Privs, 
                    ModsAccepted, ModsRejected, MemberSince) 
                    values ('FreeDB', '', 0, 0, 0, now())|);
        $sql->Do(qq|insert into Moderator (Name, Password, Privs, 
                    ModsAccepted, ModsRejected, MemberSince) 
                    values ('rob', '', 1, 0, 0, now())|);
        $sql->Do(qq|insert into Moderator (Name, Password, Privs, 
                    ModsAccepted, ModsRejected, MemberSince) 
                    values ('ModBot', '', 0, 0, 0, now())|);
  
        $sql->Commit;
    };
    if ($@)
    {
        $sql->Rollback;
        print "Failed to insert default rows.\n($@)\n";
        return 0;
    }
    print "Inserted default rows.\n";
    return 1;
}

sub CreateIndices
{
    my ($sql) = @_;

    eval
    {
        $sql->Begin;

        $sql->Do(qq|create unique index Artist_NameIndex on Artist (Name)|)
            or die("Could not add indices to Artist table");
        $sql->Do(qq|create index Artist_SortNameIndex on Artist (SortName)|)
            or die("Could not add indices to Artist table");
        $sql->Do(qq|create unique index Artist_GIDIndex on Artist (GID)|)
            or die("Could not add indices to Artist table");
        print "Added indices to Artist table.\n";

        $sql->Do(qq|create index Album_NameIndex on Album (Name)|)
              or die("Could not add indices to Album table");
        $sql->Do(qq|create unique index Album_GIDIndex on Album (GID)|)
              or die("Could not add indices to Album table");
        $sql->Do(qq|create index Album_ArtistIndex on Album (Artist)|)
              or die("Could not add indices to Album table");
        print "Added indices to Album table.\n";

        $sql->Do(qq|create index Track_NameIndex on Track (Name)|)
              or die("Could not add indices to Track table");
        $sql->Do(qq|create unique index Track_GIDIndex on Track (GID)|)
              or die("Could not add indices to Track table");
        $sql->Do(qq|create index Track_ArtistIndex on Track (Artist)|)
              or die("Could not add indices to Track table");
        print "Added indices to Track table.\n";

        $sql->Do(qq|create unique index TRM_TRMIndex on TRM (TRM)|)
              or die("Could not add indices to TRM table");
        print "Added indices to TRM table.\n";

        $sql->Do(qq|create index TRMJoin_TRMIndex on TRMJoin (TRM)|)
              or die("Could not add indices to TRMJoin table");
        $sql->Do(qq|create index TRMJoin_TrackIndex on TRMJoin (Track)|)
              or die("Could not add indices to TRMJoin table");
        print "Added indices to TRMJoin table.\n";

        $sql->Do(qq|create index AlbumJoin_AlbumIndex on AlbumJoin (Album)|)
              or die("Could not add indices to AlbumJoin table");
        $sql->Do(qq|create index AlbumJoin_TrackIndex on AlbumJoin (Track)|)
              or die("Could not add indices to AlbumJoin table");
        print "Added indices to AlbumJoin table.\n";

        $sql->Do(qq|create unique index Discid_DiscIndex on Discid (Disc)|)
              or die("Could not add indices to Discid table");
        $sql->Do(qq|create index Discid_AlbumIndex on Discid (Album)|)
              or die("Could not add indices to Discid table");
        print "Added indices to Discid table.\n";

        $sql->Do(qq|create unique index TOC_DiscIndex on TOC (Discid)|)
              or die("Could not add indices to TOC table");
        $sql->Do(qq|create index TOC_AlbumIndex on TOC (Album)|)
              or die("Could not add indices to TOC table");
        print "Added indices to TOC table.\n";

        $sql->Do(qq|create index Moderator_NameIndex on Moderator (Name)|)
              or die("Could not add indices to Moderator table");
        print "Added indices to Moderator table.\n";

        $sql->Do(qq|create index Moderation_ModeratorIndex 
                    on Moderation (Moderator)|)
              or die("Could not add indices to Moderation table");
        $sql->Do(qq|create index Moderation_ExpireTimeIndex 
                    on Moderation (ExpireTime)|)
              or die("Could not add indices to Moderation table");
        $sql->Do(qq|create index Moderation_StatusIndex on Moderation (Status)|)
              or die("Could not add indices to Moderation table");
        print "Added indices to Moderation table.\n";

        $sql->Do(qq|create index Votes_UidIndex on Votes (Uid)|)
              or die("Could not add indices to Votes table");
        $sql->Do(qq|create index Votes_RowidIndex on Votes (Rowid)|)
              or die("Could not add indices to Votes table");
        print "Added indices to Votes table.\n";

        $sql->Do(qq|create unique index ArtistAlias_NameIndex on ArtistAlias (Name)|)
              or die("Could not add indices to ArtistAlias table");
        $sql->Do(qq|create index ArtistAlias_RefIndex on ArtistAlias (Ref)|)
              or die("Could not add indices to ArtistAlias table");
        print "Added indices to ArtistAlias table.\n";
        
        $sql->Do(qq|create unique index WordList_WordIndex on WordList (Word)|)
              or die("Could not add indices to WordList table");
        print "Added indices to WordList table.\n";

        $sql->Do(qq|create index AlbumWords_WordidIndex on AlbumWords (Wordid)|)
              or die("Could not add indices to AlbumWords table");
        $sql->Do(qq|create index AlbumWords_AlbumidIndex on AlbumWords (Albumid)|)
              or die("Could not add indices to AlbumWords table");
        $sql->Do(qq|create unique index AlbumWords_AlbumWordIndex on 
                                        AlbumWords (Wordid,Albumid)|)
              or die("Could not add indices to AlbumWords table");
        print "Added indices to AlbumWords table.\n";

        $sql->Do(qq|create index ArtistWords_WordidIndex on ArtistWords (Wordid)|)
              or die("Could not add indices to ArtistWords table");
        $sql->Do(qq|create index ArtistWords_ArtistidIndex 
                    on ArtistWords (Artistid)|)
              or die("Could not add indices to ArtistWords table");
        $sql->Do(qq|create unique index ArtistWords_ArtistWordIndex  
                    on ArtistWords (Wordid,Artistid)|)
              or die("Could not add indices to ArtistWords table");
        print "Added indices to ArtistWords table.\n";

        $sql->Do(qq|create index TrackWords_WordidIndex on TrackWords (Wordid)|)
              or die("Could not add indices to TrackWords table");
        $sql->Do(qq|create index TrackWords_TrackidIndex on TrackWords (Trackid)|)
              or die("Could not add indices to TrackWords table");
        $sql->Do(qq|create unique index TrackWords_TrackWordIndex 
                    on TrackWords (Wordid,Trackid)|)
              or die("Could not add indices to TrackWords table");
        print "Added indices to TrackWords table.\n";

        $sql->Do(qq|create index ModerationNote_ModIndex on ModerationNote (Modid)|)
              or die("Could not add indices to ModerationNote table");
        print "Added indices to ModerationNote table.\n";

        $sql->Do(qq|create unique index Stats_TimestampIndex on Stats (timestamp)|)
              or die("Could not add indices to Stats table");
        print "Added indices to Stats table.\n";
        $sql->Commit;
    };
    if ($@)
    {
        $sql->Rollback;
        print "Failed to create indices.\n($@)\n";
        return 0;
    }

    print "Created indices successfully.\n\n";
    return 1;
}

sub CreateViews
{
    my ($sql) = @_;

    eval
    {
        $sql->Begin;

        $sql->Do(qq|create view open_moderations as
                    select Moderation.id as moderation_id, tab, col, rowid, 
                           Moderation.artist, type, prevvalue, newvalue, 
                           ExpireTime, yesvotes, novotes, status, automod,
                           Moderator.id as moderator_id, 
                           Moderator.name as moderator_name, 
                           Artist.name as artist_name
                      from Moderation, Moderator, Artist
                     where Moderation.Artist = Artist.id and 
                           Moderator.id = Moderation.moderator and 
                           Moderation.moderator != | . 
                           ModDefs::FREEDB_MODERATOR . qq| and 
                           status = | . ModDefs::STATUS_OPEN)
              or die("Cannot create open_moderations view");
        print "Created open_moderations view.\n";

        $sql->Do(qq|create view open_moderations_freedb as
                    select Moderation.id as moderation_id, tab, col, rowid, 
                           Moderation.artist, type, prevvalue, newvalue, 
                           ExpireTime, yesvotes, novotes, status, automod,
                           Moderator.id as moderator_id, 
                           Moderator.name as moderator_name, 
                           Artist.name as artist_name
                      from Moderation, Moderator, Artist
                     where Moderation.Artist = Artist.id and 
                           Moderator.id = Moderation.moderator and 
                           Moderation.moderator = | . 
                           ModDefs::FREEDB_MODERATOR . qq| and 
                           status = | . ModDefs::STATUS_OPEN)
              or die("Cannot create open_moderations_freedb view");
        print "Created open_moderations_freedb view.\n";

        $sql->Commit;
    };
    if ($@)
    {
        $sql->Rollback;
        print "Failed to create views.\n($@)\n";
        return 0;
    }

    print "Created views successfully.\n\n";
    return 1;
}

sub Usage
{
    print "Usage: CreateTables.pl [all] [tables] [views] [indexes] ";
    print "[default]\n\n";
    print " all      - create tables, views, indexes, default rows\n";  
    print " tables   - create tables\n";  
    print " indexes  - create indexes\n";  
    print " views    - create views\n";  
    print " defaults - create default rows\n";  
}

my ($indices, $tables, $arg, $mb, $sql, $ret);

$tables = 0;
$default = 0;
$views = 0;
$index = 0;
$ret = 1;

while(defined($arg = shift))
{
    if ($arg eq 'all')
    {
        $tables = 1;
        $default = 1;
        $views = 1;
        $index = 1;
    }
    elsif ($arg eq 'defaults')
    {
        $default = 1; 
    }
    elsif ($arg eq 'indexes')
    {
        $index = 1; 
    }
    elsif ($arg eq 'tables')
    {
        $tables = 1; 
    }
    elsif ($arg eq 'views')
    {
        $views = 1; 
    }
    elsif ($arg eq '-h' || $arg eq '--help')
    {
        Usage();
    }
}

if ($tables == 0 && $default == 0 && $views == 0 && $index == 0)
{
    Usage();
    exit(0);
}

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

print "Connected to database.\n";

if ($tables)
{
    print "Creating MusicBrainz Tables.\n";
    $ret = CreateTables($sql);
}

if ($index && $ret)
{
    print "Adding indices to MusicBrainz Tables.\n";
    $ret = CreateIndices($sql);
}

if ($views && $ret)
{
    print "Creating MusicBrainz views.\n";
    $ret = CreateViews($sql);
}

if ($default && $ret)
{
    print "Adding default rows to MusicBrainz Tables.\n";
    $ret = InsertDefaultRows($sql);
}

# Disconnect
$mb->Logout;
