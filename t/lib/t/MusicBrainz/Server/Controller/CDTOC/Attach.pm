package t::MusicBrainz::Server::Controller::CDTOC::Attach;
use Test::Routine;

with 't::Context', 't::Mechanize';

=head2 Test description

This test checks whether release and CD stub matches are shown when a user
tries to submit a CD TOC / disc ID to MusicBrainz.

=cut

test 'Logged in users can see matching CD stubs' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL');
        INSERT INTO release_raw (id, title, artist)
            VALUES (1, 'CD stub name', 'CD stub artist');
        INSERT INTO cdtoc_raw (id, release, discid, track_count, leadout_offset, track_offset)
            VALUES (1, 1, 'dhfB1yuFe9rrpZjS.z9HwXQO5ck-', 1, 171327, ARRAY[150]);
        INSERT INTO track_raw (id, release, title, artist, sequence)
            VALUES (1, 1, 'CD stub track', NULL, 1);

        INSERT INTO editor (
            id, name, password, privs,
            email, website, bio,
            email_confirm_date, member_since, last_login_date, ha1
        ) VALUES (
            1, 'new_editor', '{CLEARTEXT}password', 0,
            'test@editor.org', 'http://musicbrainz.org', 'biography',
            '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478'
        );
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok(
        '/cdtoc/attach?toc=1 1 171327 150',
        'Fetched the attach page for CD TOC matching existing CD stub',
    );
    $mech->text_contains(
        'A CD Stub was found that matches the disc ID',
        'The matching CD stub message is displayed',
    );
    $mech->text_contains('CD stub name', 'The CD stub name is displayed');
    $mech->text_contains('CD stub artist', 'The CD stub artist is displayed');
    $mech->text_contains('CD stub track', 'The CD stub track is displayed');

    $mech->text_lacks(
        'we also found the following releases',
        'The matching releases message is not displayed since there are none',
    );
};

test 'A matching CD stub searches for possible releases' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL');
        INSERT INTO release_raw (id, title, artist)
            VALUES (1, 'Release stub name', 'CD stub artist');
        INSERT INTO cdtoc_raw (id, release, discid, track_count, leadout_offset, track_offset)
            VALUES (1, 1, 'dhfB1yuFe9rrpZjS.z9HwXQO5ck-', 1, 171327, ARRAY[150]);
        INSERT INTO track_raw (id, release, title, artist, sequence)
            VALUES (1, 1, 'CD stub track', NULL, 1);

        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '7bcffca6-e8f5-11e0-866d-00508db50876', 'Artist name', 'Artist name');
        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'Artist name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
        INSERT INTO artist_credit_name (artist_credit, name, artist, position)
            VALUES (1, 'Artist name', 1, 1);

        INSERT INTO recording (id, gid, name, artist_credit)
            VALUES (1, '3bcffca6-e8f5-11e0-866d-00508db50876', 'Release track', 1),
                   (2, 'fe445777-685c-48e5-ab29-a6905ace4ca8', 'Pregap track', 1);

        INSERT INTO release_group (id, gid, name, artist_credit)
            VALUES (1, '1bcffca6-e8f5-11e0-866d-00508db50876', 'Release stub name', 1);

        INSERT INTO release (id, gid, name, release_group, artist_credit)
            VALUES (1, '2bcffca6-e8f5-11e0-866d-00508db50876', 'Release stub name', 1, 1),
                   (2, '3850dad5-8010-476c-9b19-d3bab89548aa', 'Release + pregap stub name', 1, 1),
                   (3, '3850dad5-8010-476c-9b19-d3bab89548ab', 'Release stub name', 1, 1),
                   (4, '3850dad5-8010-476c-9b19-d3bab89548ac', 'Release stub name', 1, 1);

        INSERT INTO medium (id, release, track_count, position)
            VALUES (1, 1, 0, 1), (2, 2, 0, 1), (3, 3, 0, 1), (4, 4, 0, 1);

        INSERT INTO track (id, gid, medium, name, recording, position, number, artist_credit, is_data_track)
            VALUES (1, 'c53c3e26-192e-4a9d-bd46-7682f2154d6b', 1, 'Release track', 1, 1, 1, 1, FALSE),
                   (2, '1d6aca46-d9be-4f05-b459-723afb74395d', 2, 'Pregap track', 2, 0, 0, 1, FALSE),
                   (3, 'ca94f034-48bf-4b78-a019-0f4eadd1fdbc', 2, 'Release track', 1, 1, 1, 1, FALSE),
                   (4, '1d6aca46-d9be-4f05-b459-723afb74395e', 3, 'Release track', 1, 1, 1, 1, FALSE),
                   (5, 'ca94f034-48bf-4b78-a019-0f4eadd1fdbd', 3, 'Another release track', 2, 2, 2, 1, FALSE),
                   (6, '1d6aca46-d9be-4f05-b459-723afb74395f', 4, 'Release track', 1, 1, 1, 1, FALSE),
                   (7, 'ca94f034-48bf-4b78-a019-0f4eadd1fdbe', 4, 'Data track', 2, 2, 2, 1, TRUE);

        INSERT INTO editor (
            id, name, password, privs,
            email, website, bio,
            email_confirm_date, member_since, last_login_date, ha1
        ) VALUES (
            1, 'new_editor', '{CLEARTEXT}password', 0,
            'test@editor.org', 'http://musicbrainz.org', 'biography',
            '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478'
        );
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok(
        '/cdtoc/attach?toc=1 1 171327 150',
        'Fetched the attach page for CD TOC matching existing CD stub',
    );
    $mech->text_contains(
        'A CD Stub was found that matches the disc ID',
        'The matching CD stub message is displayed',
    );
    $mech->text_contains(
        'Release stub name',
        'The CD stub name is displayed',
    );
    $mech->text_contains('CD stub artist', 'The CD stub artist is displayed');
    $mech->text_contains('CD stub track', 'The CD stub track is displayed');
    $mech->text_contains(
        'we also found the following releases',
        'The matching releases message is displayed',
    );
    $mech->content_contains(
        '/release/2bcffca6-e8f5-11e0-866d-00508db50876',
        'A link to the first matching release is present',
    );
    $mech->content_contains(
        '/release/3850dad5-8010-476c-9b19-d3bab89548aa',
        'A link to the second matching release is present; pregap track does not preclude matching',
    );
    $mech->content_lacks(
        '/release/3850dad5-8010-476c-9b19-d3bab89548ab',
        'A link to the release with a second standard track is not present',
    );
    $mech->content_contains(
        '/release/3850dad5-8010-476c-9b19-d3bab89548ac',
        'A link to the second matching release is present; data track does not preclude matching',
    );
    $mech->text_contains(
        'Release + pregap stub name',
        'Matching release names are displayed',
    );
    $mech->text_contains('Artist name', 'Release artists are displayed');
    $mech->text_contains('Release track', 'Release tracks are displayed');
    $mech->text_contains('Pregap track', 'Pregap tracks are displayed');
    $mech->text_contains('Data track', 'Data tracks are displayed');
};

1;
