-- Abstract: Splitting the moderation data into "open" and "closed" tables.
-- Abstract: Part 1: create the tables

\set ON_ERROR_STOP 1

BEGIN;

-- These tables are like the old tables they replace except for:
-- * "moderation" becomes "moderation_open" and "moderation_closed"
-- * "moderationnote" becomes "moderation_note_open" and "moderation_note_closed"
-- * "votes" becomes "vote_open" and "vote_closed"
-- * the _closed tables have an "integer" primary key, not a "serial"
-- * moderationnote.modid is now called "moderation"
-- * moderationnote.uid is now called "moderator"
-- * votes.rowid is now called "moderation"
-- * votes.uid is now called "moderator"

create table moderation_open (
   id serial,
   artist int not null, -- references Artist
   moderator int not null, -- references Moderator
   tab varchar(32) not null,
   col varchar(64) not null, 
   type smallint not null, 
   status smallint not null, 
   rowid int not null, 
   prevvalue varchar(255) not null, 
   newvalue text not null, 
   yesvotes int default 0, 
   novotes int default 0,
   depmod int default 0,
   automod smallint default 0,
   opentime timestamp with time zone default now(),
   closetime timestamp with time zone,
   expiretime timestamp with time zone not null
   );

create table moderation_note_open (
   id serial,
   moderation int not null, 
   moderator int not null, 
   text TEXT not null);

create table vote_open (
   id serial,
   moderator int not null, -- references Moderator
   moderation int not null, -- references Moderation
   vote smallint not null,
   votetime timestamp with time zone default now(),
   superseded BOOLEAN NOT NULL DEFAULT FALSE
   );

create table moderation_closed (
   id int not null,
   artist int not null, -- references Artist
   moderator int not null, -- references Moderator
   tab varchar(32) not null,
   col varchar(64) not null, 
   type smallint not null, 
   status smallint not null, 
   rowid int not null, 
   prevvalue varchar(255) not null, 
   newvalue text not null, 
   yesvotes int default 0, 
   novotes int default 0,
   depmod int default 0,
   automod smallint default 0,
   opentime timestamp with time zone default now(),
   closetime timestamp with time zone,
   expiretime timestamp with time zone not null
   );

create table moderation_note_closed (
   id int not null,
   moderation int not null, 
   moderator int not null, 
   text TEXT not null);

create table vote_closed (
   id int not null,
   moderator int not null, -- references Moderator
   moderation int not null, -- references Moderation
   vote smallint not null,
   votetime timestamp with time zone default now(),
   superseded BOOLEAN NOT NULL DEFAULT FALSE
   );

COMMIT;

-- vi: set ts=4 sw=4 et :
