package t::MusicBrainz::Server::Controller::WS::js::Edit;
use t::MusicBrainz::Server::Controller::RelationshipEditor qw(
    $additional_attribute
    $string_instruments_attribute
    $guitar_attribute
    $crazy_guitar
);
use utf8;
use JSON;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_EDIT
    $EDIT_MEDIUM_DELETE
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
);
use MusicBrainz::Server::Test qw( capture_edits );
use Test::More;
use Test::Deep qw( bag cmp_deeply ignore );
use Test::Routine;

with 't::Mechanize', 't::Context';

sub prepare_test_database {
    my $c = shift;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $c->sql->do(
    q{
        INSERT INTO language (id, iso_code_2t, iso_code_2b, iso_code_1, iso_code_3, name)
        VALUES (486, 'zxx', 'zxx', '', 'zxx', 'No linguistic content');

        INSERT INTO script (id, iso_code, iso_number, name)
        VALUES (112, 'Zsym', '996', 'Symbols');

        INSERT INTO area (id, gid, name, type)
        VALUES (107, '2db42837-c832-3c27-b4a3-08198f75693c', 'Japan', 1);

        INSERT INTO country_area (area) VALUES (107);

        INSERT INTO artist (id, gid, name, sort_name)
        VALUES (39282, '0798d15b-64e2-499f-9969-70167b1d8617', 'Boredoms', 'Boredoms'),
               (66666, '1e6092a0-73d3-465a-b06a-99c81f7bec37', 'a fake artist', 'a fake artist');

        INSERT INTO url (id, gid, url)
        VALUES (2, 'de409476-4ad8-4ce8-af2f-d47bee0edf97', 'http://en.wikipedia.org/wiki/Boredoms');

        INSERT INTO link_type (id, name, gid, link_phrase, long_link_phrase, reverse_link_phrase, entity_type0, entity_type1, description)
        VALUES (3, 'wikipedia', 'fcd58926-4243-40bb-a2e5-c7464b3ce577', 'wikipedia', 'wikipedia', 'wikipedia', 'artist', 'url', '-');

        ALTER SEQUENCE track_id_seq RESTART 100;
        ALTER SEQUENCE l_artist_recording_id_seq RESTART 100;
    });
}

sub post_json {
    my ($mech, $uri, $json) = @_;

    my $req = HTTP::Request->new('POST', $uri);

    $req->header('Content-Type' => 'application/json');
    $req->content($json);

    return $mech->request($req);
}

test 'previewing/creating/editing a release group and release' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    my $response;
    my $html;
    my @edits;

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $artist_credit = {
        names => [
            {
                artist => { id => 39282, name => "  Boredoms  " },
                name => "  Boredoms  ",
                join_phrase => "  plus  ",
            },
            {
                artist => { id => 66666, name => "a fake artist" },
                name => "a fake artist",
                join_phrase => "  and  a  trailing  join  phrase  ",
            },
        ]
    };

    my $cleaned_artist_credit = {
        names => [
            {
                artist => { id => 39282, name => "Boredoms" },
                name => "Boredoms",
                join_phrase => " plus ",
            },
            {
                artist => { id => 66666, name => "a fake artist" },
                name => "a fake artist",
                join_phrase => " and a trailing join phrase",
            },
        ]
    };

    my $release_edits = [ {
        edit_type         => $EDIT_RELEASE_CREATE,
        name              => '  Vision  Creation  Newsun  ',
        release_group_id  => undef,
        comment           => '  limited  edition  ',
        barcode           => '4943674011582',
        language_id       => 486,
        packaging_id      => undef,
        script_id         => 112,
        status_id         => 1,
        artist_credit     => $artist_credit,
        events => [
            {
                date => { year => 1999, month => 10, day => 27 },
                country_id => 107
            }
        ]
    } ];

    post_json($mech, '/ws/js/edit/preview', encode_json({ edits => $release_edits }));
    $response = from_json($mech->content);

    is($response->{previews}->[0]->{editName}, 'Add release', 'ws preview has correct editName');

    $html = $response->{previews}->[0]->{preview};

    like($html, qr{<bdi>Boredoms</bdi></a> plus <a href=".*" title="a fake artist"><bdi>a fake artist</bdi></a> and a trailing join phrase}, 'preview has artist name');
    like($html, qr/0798d15b-64e2-499f-9969-70167b1d8617/, 'preview has artist gid');
    like($html, qr/Vision Creation Newsun/, 'preview has release name');
    like($html, qr/limited edition/, 'preview has release comment');
    like($html, qr/4943674011582/, 'preview has barcode');
    like($html, qr/No linguistic content/, 'preview has language');
    like($html, qr/Symbols/, 'preview has script');
    like($html, qr/Official/, 'preview has release status');
    like($html, qr/1999-10-27/, 'preview has release date');
    like($html, qr/Japan/, 'preview has release country');

    my $release_group_edits = [ {
        edit_type     => $EDIT_RELEASEGROUP_CREATE,
        name          => '  Vision  Creation  Newsun  ',
        artist_credit => $artist_credit,
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $release_group_edits }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::ReleaseGroup::Create', 'release group created');
    ok($edits[0]->auto_edit, 'new release group should be an auto edit');

    $response = from_json($mech->content);

    is($response->{edits}->[0]->{message}, 'OK', 'ws response says OK');

    my $release_group_id = $response->{edits}->[0]->{entity}->{id};
    $release_edits->[0]->{release_group_id} = $release_group_id;

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            makeVotable => 0,
        }));
    } $c;

    is(scalar @edits, 0, 'release not created without edit note');

    $response = from_json($mech->content);

    is($response->{error}, 'editNote required', 'ws response says editNote required');

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            editNote => 'foo',
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Release::Create', 'release created');
    ok(!$edits[0]->auto_edit, 'new release should not be an auto edit');

    $response = from_json($mech->content);

    cmp_deeply($response->{edits}->[0], {
       entity => {
           scriptID => 112,
           name => 'Vision Creation Newsun',
           statusID => 1,
           barcode => '4943674011582',
           packagingID => undef,
           comment => 'limited edition',
           entityType => 'release',
           id => ignore(),
           languageID => 486,
           gid => ignore(),
       },
       message => 'OK'
    }, 'ws response contains serialized release data');

    my $release_id = $response->{edits}->[0]->{entity}->{id};

    my $medium_edits = [
        {
            edit_type   => $EDIT_MEDIUM_CREATE,
            release     => $release_id,
            position    => 1,
            format_id   => 1,
            tracklist   => [
                {
                    position        => 1,
                    number          => ' 1 ',
                    name            => ' ○ ',
                    length          => 822093,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 2,
                    number          => '2',
                    name            => '☆',
                    length          => 322933,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 3,
                    number          => '3',
                    name            => '♡',
                    length          => 411573,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 4,
                    number          => '4',
                    name            => '[うずまき]',
                    length          => 393000,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 5,
                    number          => '5',
                    name            => '〜',
                    length          => 379226,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 6,
                    number          => '6',
                    name            => '◎',
                    length          => 441240,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 7,
                    number          => '7',
                    name            => '↑',
                    length          => 386026,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 8,
                    number          => '8',
                    name            => 'Ω',
                    length          => 456266,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 9,
                    number          => '9',
                    name            => 'ずっと',
                    length          => 451133,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
            ]
        },
        {
            edit_type   => $EDIT_MEDIUM_CREATE,
            release     => $release_id,
            position    => 2,
            format_id   => 1,
            name        => '  bonus  disc  ',
            tracklist   => [
                {
                    position        => 1,
                    number          => '1',
                    name            => '☉',
                    length          => 92666,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 2,
                    number          => '2',
                    name            => '[hourglass]',
                    length          => 2138333,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
                {
                    position        => 3,
                    number          => '3',
                    name            => '◌',
                    length          => 333826,
                    artist_credit   => $artist_credit,
                    recording_gid   => undef,
                },
            ]
        },
    ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $medium_edits,
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::Create', 'medium 1 created');
    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Medium::Create', 'medium 2 created');

    is($edits[0]->data->{tracklist}->[0]->{name}, '○', 'track name is trimmed');
    is($edits[1]->data->{name}, 'bonus disc', 'medium name is trimmed');

    ok($edits[0]->auto_edit, 'new medium should be an auto edit');
    ok($edits[1]->auto_edit, 'new medium should be an auto edit');

    $response = from_json($mech->content);

    my $medium1_id = $response->{edits}->[0]->{entity}->{id};
    my $medium2_id = $response->{edits}->[1]->{entity}->{id};

    cmp_deeply($response->{edits}, [
        {
            entity => {
                position => 1,
                id => $medium2_id - 1
            },
            message => 'OK',
        },
        {
            entity => {
                position => 2,
                id => $medium1_id + 1
            },
            message => 'OK',
        }
    ], 'ws response contains new medium info');


    # Not editing the artist credit should not cause an ISE.
    # Fixed by 4cacdcea86ad5b907a33b531261114055ec7885c.

    $release_edits = [ {
        edit_type   => $EDIT_RELEASE_EDIT,
        name        => '  Vision  Creation  Newsun!  ',
        to_edit     => $release_id,
    } ];

    post_json($mech, '/ws/js/edit/preview', encode_json({ edits => $release_edits }));
    $response = from_json($mech->content);

    is($response->{error}, undef, 'editing just the release title does not cause an ISE');


    # Try making some edits. Delete the first disc, move the second disc to
    # position one, and make edits to its tracklist.

    my $medium2 = $c->model('Medium')->get_by_id($medium2_id);

    $c->model('Track')->load_for_mediums($medium2);
    $c->model('Recording')->load($medium2->all_tracks);

    $medium_edits = [
        {
            edit_type   => $EDIT_MEDIUM_DELETE,
            medium      => $medium1_id,
        },
        {
            edit_type   => $EDIT_MEDIUM_EDIT,
            to_edit     => $medium2_id,
            position    => 1,
            format_id   => 1,
            tracklist   => [
                {
                    id              => $medium2->tracks->[0]->id,
                    position        => 1,
                    number          => ' A ',
                    name            => '~☉~',
                    length          => 92666,
                    artist_credit   => $artist_credit,
                    recording_gid   => $medium2->tracks->[0]->recording->gid,
                },
                {
                    id              => $medium2->tracks->[1]->id,
                    position        => 2,
                    number          => 'B',
                    name            => '[hourglass!]',
                    length          => 2138333,
                    artist_credit   => $artist_credit,
                    recording_gid   => $medium2->tracks->[1]->recording->gid,
                },
                {
                    id              => $medium2->tracks->[2]->id,
                    position        => 3,
                    number          => 'C',
                    name            => '~◌~',
                    length          => 333826,
                    artist_credit   => $artist_credit,
                    recording_gid   => $medium2->tracks->[2]->recording->gid,
                },
            ]
        }
    ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $medium_edits,
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::Delete', 'medium 1 edit');
    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Medium::Edit', 'medium 2 edit');

    cmp_deeply($edits[1]->data, {
        entity_id => 8,
        release => {
            name => 'Vision Creation Newsun',
            id => 4
        },
        new => {
            position => 1,
            tracklist => [
                {
                    length => 92666,
                    number => 'A',
                    name => '~☉~',
                    recording_id => 27,
                    position => 1,
                    id => 109,
                    artist_credit => $cleaned_artist_credit,
                    is_data_track => 0
                },
                {
                    length => 2138333,
                    number => 'B',
                    name => '[hourglass!]',
                    recording_id => 28,
                    position => 2,
                    id => 110,
                    artist_credit => $cleaned_artist_credit,
                    is_data_track => 0
                },
                {
                    length => 333826,
                    number => 'C',
                    name => '~◌~',
                    recording_id => 29,
                    position => 3,
                    id => 111,
                    artist_credit => $cleaned_artist_credit,
                    is_data_track => 0
                }
            ]
        },
        old => ignore(),
    });


    # Add some release labels.

    my $release_label_edits = [
        {
            edit_type       => $EDIT_RELEASE_ADDRELEASELABEL,
            release         => 4,
            label           => 1,
            catalog_number  => '  FOO  123  ',
        },
        {
            edit_type       => $EDIT_RELEASE_ADDRELEASELABEL,
            release         => 4,
            label           => undef,
            catalog_number  => 'BAR 456',
        },
        {
            edit_type       => $EDIT_RELEASE_ADDRELEASELABEL,
            release         => 4,
            label           => 2,
            catalog_number  => undef,
        },
    ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_label_edits,
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Release::AddReleaseLabel', 'release label 1 edit');
    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Release::AddReleaseLabel', 'release label 2 edit');
    isa_ok($edits[2], 'MusicBrainz::Server::Edit::Release::AddReleaseLabel', 'release label 3 edit');

    cmp_deeply($edits[0]->data, {
        release         => { name => 'Vision Creation Newsun', id => 4 },
        label           => { name => 'Deleted Label', id => 1 },
        catalog_number  => 'FOO 123',
    });

    cmp_deeply($edits[1]->data, {
        release         => { name => 'Vision Creation Newsun', id => 4 },
        label           => undef,
        catalog_number  => 'BAR 456',
    });

    cmp_deeply($edits[2]->data, {
        release         => { name => 'Vision Creation Newsun', id => 4 },
        label           => { name => 'Warp Records', id => 2 },
        catalog_number  => undef,
    });
};


test 'adding a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 1,
        attributes  => [
            { type => { gid => '36990974-4f29-4ea1-b562-3838fa9b8832' } },
            { type => { gid => '4f7bb10f-396c-466a-8221-8e93f5e454f9' } },
            { type => { gid => 'c3273296-91ba-453d-94e4-2fb6e958568e' }, credit => 'crazy guitar' },
        ],
        entities    => [
            {
                gid         => '745c079d-374e-4436-9448-da92dedef3ce',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
        beginDate   => { year => 1999, month => 1, day => 1 },
        endDate     => { year => 1999, month => 2, day => undef },
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    is(scalar(@edits), 2);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Create');
    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Create');

    my %edit_data = (
        type1       => 'recording',
        type0       => 'artist',
        link_type   => {
            id                  => 1,
            name                => 'instrument',
            link_phrase         => 'performed {additional} {instrument} on',
            long_link_phrase    => 'performer',
            reverse_link_phrase => 'has {additional} {instrument} performed by',
        },
        entity1         => { id => 2, name => 'King of the Mountain' },
        entity0         => { id => 3, name => 'Test Artist' },
        begin_date      => { year => 1999, month => 1, day => 1 },
        end_date        => { year => 1999, month => 2, day => undef },
        ended           => 1,
        edit_version    => 2,
    );

    cmp_deeply($edits[0]->data,  {
        %edit_data,
        attributes => [$additional_attribute, $string_instruments_attribute]
    });

    cmp_deeply($edits[1]->data,  {
        %edit_data,
        attributes => [$additional_attribute, $crazy_guitar]
    });
};

test 'adding a relationship with an invalid date' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 1,
        attributes  => [],
        entities    => [
            {
                gid         => '745c079d-374e-4436-9448-da92dedef3ce',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
        beginDate   => { year => 1994, month => 2, day => 29 },
        endDate     => { year => 1999, month => 2, day => undef },
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for invalid date is not created');

    my $response = from_json($mech->content);
    like($response->{error}, qr/^invalid begin_date/, 'error is returned for invalid begin date');
};


test 'editing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_EDIT,
        id          => 1,
        linkTypeID  => 1,
        attributes  => [
            { type => { gid => '36990974-4f29-4ea1-b562-3838fa9b8832' } },
            { type => { gid => '4f7bb10f-396c-466a-8221-8e93f5e454f9' } },
            { type => { gid => 'c3273296-91ba-453d-94e4-2fb6e958568e' }, credit => 'crazy guitar' },
        ],
        entities    => [
            {
                gid         => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
        beginDate   => { year => 1999, month => 1, day => 1 },
        endDate     => { year => 2009, month => 9, day => 9 },
        ended       => 1,
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    my $edit = $edits[0];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply($edit->data, {
        type0 => 'artist',
        type1 => 'recording',
        link => {
            link_type => {
                id                  => 1,
                name                => 'instrument',
                link_phrase         => 'performed {additional} {instrument} on',
                long_link_phrase    => 'performer',
                reverse_link_phrase => 'has {additional} {instrument} performed by',
            },
            entity1 => { id => 2, name => 'King of the Mountain' },
            entity0 => { id => 8, name => 'Test Alias' },
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => [$guitar_attribute],
        },
        relationship_id => 1,
        new => {
            begin_date  => { month => 1, day => 1, year => 1999 },
            end_date    => { month => 9, day => 9, year => 2009 },
            ended       => 1,
            attributes  => [$additional_attribute, $string_instruments_attribute, $crazy_guitar]
        },
        old => {
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => [$guitar_attribute]
        },
        edit_version => 2,
    });
};


test 'editing a relationship with an unchanged attribute' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_EDIT,
        id          => 1,
        linkTypeID  => 1,
        entities    => [
            {
                gid         => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
        beginDate   => { year => 1999, month => 1, day => 1 },
        endDate     => { year => 2009, month => 9, day => 9 },
        ended       => 1,
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    my $edit = $edits[0];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply($edit->data, {
        type0 => 'artist',
        type1 => 'recording',
        link => {
            link_type => {
                id                  => 1,
                name                => 'instrument',
                link_phrase         => 'performed {additional} {instrument} on',
                long_link_phrase    => 'performer',
                reverse_link_phrase => 'has {additional} {instrument} performed by',
            },
            entity1 => { id => 2, name => 'King of the Mountain' },
            entity0 => { id => 8, name => 'Test Alias' },
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => [$guitar_attribute],
        },
        relationship_id => 1,
        new => {
            begin_date  => { month => 1, day => 1, year => 1999 },
            end_date    => { month => 9, day => 9, year => 2009 },
            ended       => 1,
        },
        old => {
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
        },
        edit_version => 2,
    });
};


test 'removing an attribute from a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_EDIT,
        id          => 1,
        linkTypeID  => 1,
        entities    => [
            {
                gid         => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
        attributes  => [],
        beginDate   => { year => undef, month => undef, day => undef },
        endDate     => { year => undef, month => undef, day => undef },
        ended       => 0,
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    my $edit = $edits[0];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply($edit->data, {
        type0 => 'artist',
        type1 => 'recording',
        link => {
            link_type => {
                id                  => 1,
                name                => 'instrument',
                link_phrase         => 'performed {additional} {instrument} on',
                long_link_phrase    => 'performer',
                reverse_link_phrase => 'has {additional} {instrument} performed by',
            },
            entity1 => { id => 2, name => 'King of the Mountain' },
            entity0 => { id => 8, name => 'Test Alias' },
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => [$guitar_attribute],
        },
        relationship_id => 1,
        new => {
            attributes  => [],
        },
        old => {
            attributes  => [$guitar_attribute],
        },
        edit_version => 2,
    });
};


test 'removing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_DELETE,
        id          => 1,
        linkTypeID  => 1,
        entities    => [
            {
                gid         => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                entityType  => 'artist',
            },
            {
                gid         => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                entityType  => 'recording',
            }
        ],
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    my $edit = $edits[0];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');
};


test 'MBS-7464: URLs are validated/canonicalized' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    my $response;
    my @edits;

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $invalid_url = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 3,
        entities    => [
            {
                entityType  => 'artist',
                gid         => '0798d15b-64e2-499f-9969-70167b1d8617',
            },
            {
                entityType  => 'url',
                name        => 'HAHAHA',
            }
        ],
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $invalid_url }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for invalid URL is not created');

    $response = from_json($mech->content);
    like($response->{error}, qr/^invalid URL: HAHAHA/, 'error is returned for invalid URL');

    my $unsupported_protocol = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 3,
        entities    => [
            {
                entityType  => 'artist',
                gid         => '0798d15b-64e2-499f-9969-70167b1d8617',
            },
            {
                entityType  => 'url',
                name        => 'gopher://example.com/',
            }
        ],
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $unsupported_protocol }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for URL with unsupported protocol is not created');

    $response = from_json($mech->content);
    like($response->{error}, qr/^unsupported URL protocol: gopher/, 'error is returned for unsupported protocol');

    my $non_canonical_url = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 3,
        entities    => [
            {
                entityType  => 'artist',
                gid         => '0798d15b-64e2-499f-9969-70167b1d8617',
            },
            {
                entityType  => 'url',
                name        => 'http://en.Wikipedia.org:80/wiki/Boredoms',
            }
        ],
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $non_canonical_url }));
    } $c;

    my $url = $c->model('URL')->get_by_id($edits[0]->data->{entity1}->{id});

    is($url->url, 'http://en.wikipedia.org/wiki/Boredoms', 'URL is canonicalized');
    is($url->id, 2, 'existing URL is used');
};


test 'Edits are rejected without a confirmed email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    prepare_test_database($c);

    $c->model('Editor')->insert({
        name => 'stupid editor',
        password => 'password'
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'stupid editor', password => 'password' } );

    post_json($mech, '/ws/js/edit/create', encode_json({ edits => [] }));

    my $response = from_json($mech->content);
    is($response->{error}, 'a confirmed email address is required', 'error is returned for unconfirmed email');
};

1;
