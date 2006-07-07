\set ON_ERROR_STOP 1

BEGIN;

create table puidtemp (track varchar(255), puid varchar(255));

\copy puidtemp from 'mbid_puid.txt' with delimiter ','

create sequence puidjoinnew_seq;
create sequence puidnew_seq;

select distinct puid into puiddist from puidtemp;
select nextval('puidnew_seq') as id, puid, 0 as lookupcount, 1 as version into puid from puiddist;

create index puid_id_index on puid (id);
create index puid_puid_index on puid (puid);
create index puidnew_id_index on puid (id);
create index puidtemp_puid_index on puidtemp (puid);
create index puidtemp_track_index on puidtemp (track);

select nextval('puidjoinnew_seq') as id, puid.id as puid, track.id as track, 0 as usecount into puidjoin from puid, track, puidtemp where puidtemp.track = track.gid and puidtemp.puid = puid.puid;

drop table puidtemp;
drop table puiddist;
drop sequence puidjoinnew_seq;
drop sequence puidnew_seq;

\copy puid to 'puid.dat'
\copy puidjoin to 'puidjoin.dat'

drop table puid;
drop table puidjoin;

COMMIT;

-- vi: set ts=4 sw=4 et :
