Begin;

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Various Artists', 'Various Artists', 
              'e06d2236-5806-409f-ac9f-9245844ce5d9', 0, 0); 

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
