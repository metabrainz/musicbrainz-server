\set ON_ERROR_STOP 1
begin;

create table Artist (
   Id serial primary key,
   Name varchar(255) not null,
   GID char(36) not null,
   ModPending int default 0,
   SortName varchar(255) not null,
   Page int not null);

create table ArtistAlias (
   Id serial primary key,
   Ref int not null references Artist, 
   Name varchar(255) not null, 
   LastUsed datetime not null,
   TimesUsed int default 0,
   ModPending int default 0);

create table Album (
   Id serial primary key,
   Artist int not null references Artist,
   Name varchar(255) not null,
   GID char(36) not null, 
   ModPending int default 0,
   Attributes int[] default '{0}',
   Page int not null);

create table AlbumMeta (
   Id int primary key,
   tracks int default 0,
   discids int default 0,
   trmids int default 0);

create table Track (
   Id serial primary key,
   Artist int not null references Artist,
   Name varchar(255) not null,
   GID char(36) not null, 
   Length int default 0,
   Year int default 0,
   ModPending int default 0);

create table AlbumJoin (
   Id serial primary key,
   Album int not null references Album,
   Track int not null references Track,
   Sequence int not null,
   ModPending int default 0);

create table ClientVersion (
   Id serial primary key,
   Version varchar(64) not null);

create table TRM (
   Id serial primary key,
   TRM char(36) not null,
   LookupCount int default 0,
   Version int not null references ClientVersion);

create table TRMJoin (
   Id serial primary key,
   TRM int not null references TRM, 
   Track int not null references Track);

create table Discid (
   Id serial primary key,
   Album int not null references Album,
   Disc char(28) not null unique,
   Toc text not null, 
   ModPending int default 0);

create table TOC (
   Id serial primary key,
   Album int not null references Album,
   Discid char(28) references Discid (Disc),
   Tracks int,
   Leadout int, Track1 int, Track2 int, Track3 int, Track4 int, Track5 int, Track6 int, Track7 int, 
   Track8 int, Track9 int, Track10 int, Track11 int, Track12 int, Track13 int, Track14 int, 
   Track15 int, Track16 int, Track17 int, Track18 int, Track19 int, Track20 int, Track21 int, 
   Track22 int, Track23 int, Track24 int, Track25 int, Track26 int, Track27 int, Track28 int, 
   Track29 int, Track30 int, Track31 int, Track32 int, Track33 int, Track34 int, Track35 int, 
   Track36 int, Track37 int, Track38 int, Track39 int, Track40 int, Track41 int, Track42 int, 
   Track43 int, Track44 int, Track45 int, Track46 int, Track47 int, Track48 int, Track49 int, 
   Track50 int, Track51 int, Track52 int, Track53 int, Track54 int, Track55 int, Track56 int, 
   Track57 int, Track58 int, Track59 int, Track60 int, Track61 int, Track62 int, Track63 int, 
   Track64 int, Track65 int, Track66 int, Track67 int, Track68 int, Track69 int, Track70 int, 
   Track71 int, Track72 int, Track73 int, Track74 int, Track75 int, Track76 int, Track77 int, 
   Track78 int, Track79 int, Track80 int, Track81 int, Track82 int, Track83 int, Track84 int, 
   Track85 int, Track86 int, Track87 int, Track88 int, Track89 int, Track90 int, Track91 int, 
   Track92 int, Track93 int, Track94 int, Track95 int, Track96 int, Track97 int, Track98 int, 
   Track99 int);

create table Moderator (
   Id serial primary key,
   Name varchar(64) not null,
   Password varchar(64) not null, 
   Privs int default 0, 
   ModsAccepted int default 0,
   ModsRejected int default 0, 
   EMail varchar(64) default null, 
   WebUrl varchar(255) default null, 
   MemberSince datetime default now(),
   Bio text default null);

SELECT * INTO moderator_sanitised FROM moderator;

create table Moderation (
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
   Automod smallint default 0);

create table ModerationNote (
   Id serial primary key,
   ModId int not null, 
   Uid int not null, 
   Text varchar(255) not null);

create table Votes (
   Id serial primary key,
   Uid int not null references Moderator, 
   Rowid int not null references Moderation, 
   vote smallint not null);

create table WordList(
   Id serial primary key,
   Word varchar(255) not null);

create table ArtistWords(
   Wordid int not null,
   Artistid int not null);

create table AlbumWords(
   Wordid int not null,
   Albumid int not null);

create table TrackWords (
   Wordid int not null,
   Trackid int not null);

create table Stats (
   Id serial primary key,
   artists int not null, 
   albums int not null, 
   tracks int not null, 
   discids int not null, 
   trmids int not null, 
   moderations int not null, 
   votes int not null, 
   moderators int not null, 
   timestamp date not null);

commit;
