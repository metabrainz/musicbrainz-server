INSERT INTO editor (id, name, password, privs, email, website, bio, member_since,
        email_confirm_date, last_login_date, edits_accepted, edits_rejected,
        auto_edits_accepted, edits_failed)
    VALUES
         (1, 'autoeditor1', 'password', 1, 'autoeditor1@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (2, 'autoeditor2', 'password', 1, 'autoeditor2@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (3, 'autoeditor3', 'password', 1, 'autoeditor3@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (5, 'noob1', 'password', 0, 'noob1@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (6, 'noob2', 'password', 0, 'noob2@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (7, 'autoeditor4', 'password', 1, 'autoeditor4@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (8, 'autoeditor5', 'password', 1, 'autoeditor5@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (4, 'ModBot', 'mb', 0, '', 'http://musicbrainz.org/doc/ModBot',
         'See the above link for more information.', NULL, NULL, NULL, 2, 1, 99951, 3560);

ALTER SEQUENCE autoeditor_election_id_seq RESTART 1;

