\set ON_ERROR_STOP 1
begin;

create view open_moderations as
     select Moderation.id as moderation_id, tab, col, rowid, 
            Moderation.artist, type, prevvalue, newvalue, 
            ExpireTime, yesvotes, novotes, status, automod,
            Moderator.id as moderator_id, 
            Moderator.name as moderator_name, 
            Artist.name as artist_name
       from Moderation, Moderator, Artist
      where Moderation.Artist = Artist.id and 
            Moderator.id = Moderation.moderator and 
            Moderation.moderator != 2 and 
            status = 1;

create view open_moderations_freedb as
     select Moderation.id as moderation_id, tab, col, rowid, 
            Moderation.artist, type, prevvalue, newvalue, 
            ExpireTime, yesvotes, novotes, status, automod,
            Moderator.id as moderator_id, 
            Moderator.name as moderator_name, 
            Artist.name as artist_name
       from Moderation, Moderator, Artist
      where Moderation.Artist = Artist.id and 
            Moderator.id = Moderation.moderator and 
            Moderation.moderator = 2 and 
            status = 1;

commit;
