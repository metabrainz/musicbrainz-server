select * from Artist into outfile '/tmp/mbdump/Artist';
select * from Album into outfile '/tmp/mbdump/Album';
select * from Diskid into outfile '/tmp/mbdump/Diskid';
select * from GUIDJoin into outfile '/tmp/mbdump/Guidjoin';
select * from GUID into outfile '/tmp/mbdump/Guid';
select * from AlbumJoin into outfile '/tmp/mbdump/Albumjoin';
select * from Track into outfile '/tmp/mbdump/Track';
select * from TOC into outfile '/tmp/mbdump/TOC';
