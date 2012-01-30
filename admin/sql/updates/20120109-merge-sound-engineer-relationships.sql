BEGIN;

UPDATE link SET link_type = (SELECT id FROM link_type WHERE gid = '271306ca-c77f-4fe0-94bc-dd4b87ae0205')
WHERE link.id IN (
    SELECT link.id FROM link
    JOIN link_type ON link_type.id = link.link_type
    WHERE link_type.gid = '4eb323ef-0c3e-4cfd-a5c1-db876e9e81e6'
);

DELETE FROM link_type_attribute_type
WHERE link_type = (SELECT id FROM link_type WHERE gid = '4eb323ef-0c3e-4cfd-a5c1-db876e9e81e6');
DELETE FROM link_type WHERE gid = '4eb323ef-0c3e-4cfd-a5c1-db876e9e81e6';

UPDATE link SET link_type = (SELECT id FROM link_type WHERE gid = '0cd6aa63-c297-42ed-8725-c16d31913a98')
WHERE link.id IN (
    SELECT link.id FROM link
    JOIN link_type ON link_type.id = link.link_type
    WHERE link_type.gid = '793acda8-6884-4f7e-ace0-87038b76d042'
);

DELETE FROM link_type_attribute_type
WHERE link_type = (SELECT id FROM link_type WHERE gid = '793acda8-6884-4f7e-ace0-87038b76d042');
DELETE FROM link_type WHERE gid = '793acda8-6884-4f7e-ace0-87038b76d042';

COMMIT;
