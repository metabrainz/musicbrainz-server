Begin;

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Various Artists', 'Various Artists', 
              '89ad4ac3-39f7-470e-963a-56509c546377', 0, 0); 

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Deleted Artist', 'Deleted Artist', 
              'c06aa285-520e-40c0-b776-83d2c9e8a6d1', 0, 0); 

insert into Moderator (Name, Password, Privs, 
      ModsAccepted, ModsRejected, MemberSince) values 
      ('Anonymous', '', 0, 0, 0, now());
insert into Moderator (Name, Password, Privs, 
      ModsAccepted, ModsRejected, MemberSince) 
      values ('FreeDB', '', 0, 0, 0, now());
insert into Moderator (Name, Password, Privs, 
      ModsAccepted, ModsRejected, MemberSince) 
      values ('rob', '', 1, 0, 0, now());
insert into Moderator (Name, Password, Privs, 
      ModsAccepted, ModsRejected, MemberSince) 
      values ('ModBot', '', 0, 0, 0, now());

insert into ClientVersion (Id, Version) 
      values (1, 'unknown');

Commit;
