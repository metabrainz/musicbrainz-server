\set ON_ERROR_STOP 1
begin;

create table artist_relation_raw (
   GID char(36) not null,
   GID_ref char(36) not null,
   weight integer not null);

create table artist_relation (
   Id serial primary key,
   artist int not null references Artist, 
   ref int not null references Artist, 
   weight integer not null);

copy artist_relation_raw from '/tmp/mbart2art.tsv';

create index artist_relation_raw_gid  on artist_relation_raw (gid);
create index artist_relation_raw_ref  on artist_relation_raw (gid_ref);

create table artist_base as 
    select distinct artist.id, artist_relation_raw.gid 
      from artist_relation_raw, artist 
     where artist.gid = artist_relation_raw.gid;
create unique index artist_base_gid  on artist_base (gid);

create table artist_ref as 
    select distinct artist.id, artist_relation_raw.gid_ref 
      from artist_relation_raw, artist 
     where artist.gid = artist_relation_raw.gid_ref;
create unique index artist_ref_gid  on artist_ref (gid_ref);

insert into artist_relation (artist, ref, weight) 
    select artist_base.id, artist_ref.id, weight 
      from artist_relation_raw, artist_base, artist_ref 
     where artist_relation_raw.gid = artist_base.gid and 
           artist_relation_raw.gid_ref = artist_ref.gid_ref;
create index artist_relation_artist  on artist_relation (artist);
create index artist_relation_ref  on artist_relation (ref);

drop table artist_ref;
drop table artist_base;
drop table artist_relation_raw;

commit;
