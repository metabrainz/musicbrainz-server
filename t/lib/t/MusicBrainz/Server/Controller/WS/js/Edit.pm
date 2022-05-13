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
    $EDIT_RECORDING_EDIT
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_RELEASEGROUP_EDIT
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_EDIT
    $EDIT_MEDIUM_DELETE
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
    $STATUS_APPLIED
    $WS_EDIT_RESPONSE_OK
    $WS_EDIT_RESPONSE_NO_CHANGES
);
use MusicBrainz::Server::Test qw( capture_edits post_json );
use Test::More;
use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;

with 't::Mechanize', 't::Context';

sub prepare_test_database {
    my $c = shift;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database($c, '+ws_js_edit');
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
                artist => { id => 39282, name => '  Boredoms  ' },
                name => '  Boredoms  ',
                join_phrase => '  plus  ',
            },
            {
                artist => { id => 66666, name => 'a fake artist' },
                name => 'a fake artist',
                join_phrase => '  and  a  trailing  join  phrase  ',
            },
        ]
    };

    my $cleaned_artist_credit = {
        names => [
            {
                artist => { id => 39282, name => 'Boredoms' },
                name => 'Boredoms',
                join_phrase => ' plus ',
            },
            {
                artist => { id => 66666, name => 'a fake artist' },
                name => 'a fake artist',
                join_phrase => ' and a trailing join phrase',
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

    is($response->{edits}->[0]->{response}, $WS_EDIT_RESPONSE_OK, 'ws response says OK');

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
            editNote => ' .  ',
            makeVotable => 0,
        }));
    } $c;

    is(scalar @edits, 0, 'release not created with invalid note');

    $response = from_json($mech->content);

    is($response->{error}, 'editNote invalid', 'ws response says editNote invalid');


    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            editNote => 'foo',
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Release::Create', 'release created');
    ok($edits[0]->auto_edit, 'new release should be an auto edit');

    $response = from_json($mech->content);

    cmp_deeply($response->{edits}->[0], {
        edit_type => $EDIT_RELEASE_CREATE,
        entity => {
            script => undef,
            scriptID => 112,
            name => 'Vision Creation Newsun',
            status => undef,
            statusID => 1,
            barcode => '4943674011582',
            packagingID => undef,
            comment => 'limited edition',
            entityType => 'release',
            id => ignore(),
            language => undef,
            languageID => 486,
            last_updated => ignore(),
            length => 0,
            gid => ignore(),
            artist => 'Boredoms plus a fake artist and a trailing join phrase',
            artistCredit => {
                editsPending => JSON::false,
                entityType => 'artist_credit',
                id => 101,
                gid => ignore(),
                names => [
                    {
                        joinPhrase => ' plus ',
                        artist => {
                            area => undef,
                            begin_area_id => undef,
                            begin_date => undef,
                            comment => '',
                            editsPending => JSON::false,
                            end_area_id => undef,
                            end_date => undef,
                            ended => JSON::false,
                            entityType => 'artist',
                            gender_id => undef,
                            gid => '0798d15b-64e2-499f-9969-70167b1d8617',
                            id => 39282,
                            ipi_codes => [],
                            isni_codes => [],
                            last_updated => ignore,
                            name => 'Boredoms',
                            sort_name => 'Boredoms',
                            typeID => undef,
                        },
                        name => 'Boredoms',
                    },
                    {
                        joinPhrase => ' and a trailing join phrase',
                        artist => {
                            area => undef,
                            begin_area_id => undef,
                            begin_date => undef,
                            comment => '',
                            editsPending => JSON::false,
                            end_area_id => undef,
                            end_date => undef,
                            ended => JSON::false,
                            entityType => 'artist',
                            gender_id => undef,
                            gid => '1e6092a0-73d3-465a-b06a-99c81f7bec37',
                            id => 66666,
                            ipi_codes => [],
                            isni_codes => [],
                            last_updated => ignore,
                            name => 'a fake artist',
                            sort_name => 'a fake artist',
                            typeID => undef,
                        },
                        name => 'a fake artist',
                    },
                ],
            },
            events => [
                {
                    country => {
                        begin_date => undef,
                        comment => '',
                        editsPending => JSON::false,
                        end_date => undef,
                        ended => JSON::false,
                        entityType => 'area',
                        gid => '2db42837-c832-3c27-b4a3-08198f75693c',
                        id => 107,
                        last_updated => ignore,
                        name => 'Japan',
                        typeID => 1,
                        iso_3166_1_codes => ['JP'],
                        iso_3166_2_codes => [],
                        iso_3166_3_codes => [],
                        primary_code => 'JP',
                        country_code => 'JP',
                    },
                    date => {
                        day => 27,
                        month => 10,
                        year => 1999,
                    },
                }
            ],
            editsPending => JSON::false,
            cover_art_presence => undef,
            may_have_cover_art => JSON::true,
            may_have_discids => JSON::false,
            quality => 1,
            combined_format_name => '',
            combined_track_count => '',
            mediums => [],
        },
        response => $WS_EDIT_RESPONSE_OK,
    }, 'ws response contains serialized release data');

    my $release_id = $response->{edits}->[0]->{entity}->{id};

    my $medium_edits = [
        {
            edit_type   => $EDIT_MEDIUM_CREATE,
            release     => $release_id,
            position    => 1,
            format_id   => 1,
            name        => '',
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
            edit_type => $EDIT_MEDIUM_CREATE,
            entity => {
                position => 1,
                id => $medium2_id - 1
            },
            response => $WS_EDIT_RESPONSE_OK,
        },
        {
            edit_type => $EDIT_MEDIUM_CREATE,
            entity => {
                position => 2,
                id => $medium1_id + 1
            },
            response => $WS_EDIT_RESPONSE_OK,
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

    # MBS-9512
    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => [
                {
                    edit_type   => $EDIT_RECORDING_EDIT,
                    name        => '',
                    to_edit     => $medium2->tracks->[0]->recording->gid,
                },
            ],
            makeVotable => 0,
        }));
    } $c;

    ok(scalar(@edits) == 0, 'recording edit with empty name is not created');
    $response = from_json($mech->content);
    like($response->{error}, qr/^empty name/, 'error is returned for empty recording name');

    $medium_edits = [
        {
            # No changes. Shouldn't cause an error, but should be indicated
            # in the response.
            edit_type   => $EDIT_RECORDING_EDIT,
            name        => $medium2->tracks->[0]->recording->name,
            to_edit     => $medium2->tracks->[0]->recording->gid,
        },
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
            makeVotable => 1,
        }));
    } $c;

    $response = from_json($mech->content);

    cmp_deeply($response, {
        edits => [
            {response => $WS_EDIT_RESPONSE_NO_CHANGES},
            {edit_type => 53, response => $WS_EDIT_RESPONSE_OK},
            {edit_type => 52, response => $WS_EDIT_RESPONSE_OK},
        ],
    });

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
                    id => 45,
                    artist_credit => $cleaned_artist_credit,
                    is_data_track => 0
                },
                {
                    length => 2138333,
                    number => 'B',
                    name => '[hourglass!]',
                    recording_id => 28,
                    position => 2,
                    id => 46,
                    artist_credit => $cleaned_artist_credit,
                    is_data_track => 0
                },
                {
                    length => 333826,
                    number => 'C',
                    name => '~◌~',
                    recording_id => 29,
                    position => 3,
                    id => 47,
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
        release         => { name => 'Vision Creation Newsun', id => 4, gid => ignore() },
        label           => { name => 'Deleted Label', id => 1, gid => 'f43e252d-9ebf-4e8e-bba8-36d080756cc1' },
        catalog_number  => 'FOO 123',
    });

    cmp_deeply($edits[1]->data, {
        release         => { name => 'Vision Creation Newsun', id => 4, gid => ignore() },
        label           => undef,
        catalog_number  => 'BAR 456',
    });

    cmp_deeply($edits[2]->data, {
        release         => { name => 'Vision Creation Newsun', id => 4, gid => ignore() },
        label           => { name => 'Warp Records', id => 2, gid => '46f0f4cd-8aab-4b33-b698-f459faf64190' },
        catalog_number  => undef,
    });


    # Add release annotation.

    my $annotation_edits = [ {
        edit_type       => $EDIT_RELEASE_ADD_ANNOTATION,
        entity          => $release_id,
        text            => "    * Test annotation\x{0007} in release editor  \r\n\r\n\t\x{00A0}\r\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets  \t\t",
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $annotation_edits }));
    } $c;

    is(scalar(@edits), 1);

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Release::AddAnnotation');

    cmp_deeply($edits[0]->data, {
        editor_id         => 1,
        entity            => { id => $release_id, name => 'Vision Creation Newsun' },
        old_annotation_id => undef,
        text              => "    * Test annotation in release editor\n\n    * This anno\x{200B}tation has\ttwo bul\x{00AD}lets",
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
        linkTypeID  => 148,
        attributes  => [
            { type => { gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f' } },
            { type => { gid => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea' } },
            { type => { gid => '63021302-86cd-4aee-80df-2270d54f4978' }, credited_as => 'crazy guitar' },
        ],
        entities => [
            { gid => '745c079d-374e-4436-9448-da92dedef3ce' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1999, month => 1, day => 1 },
        end_date     => { year => 1999, month => 2, day => undef },
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
            id                  => 148,
            name                => 'instrument',
            link_phrase         => '{additional} {guest} {solo} {instrument:%|instruments}',
            long_link_phrase    => 'performed {additional} {guest} {solo} {instrument:%|instruments} on',
            reverse_link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
        },
        entity1         => { id => 2, gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', name => 'King of the Mountain' },
        entity0         => { id => 3, gid => '745c079d-374e-4436-9448-da92dedef3ce', name => 'Test Artist' },
        begin_date      => { year => 1999, month => 1, day => 1 },
        end_date        => { year => 1999, month => 2, day => undef },
        ended           => 1,
        edit_version    => 2,
    );

    cmp_deeply($edits[0]->data,  {
        %edit_data,
        attributes => [$additional_attribute, $crazy_guitar]
    });

    cmp_deeply($edits[1]->data,  {
        %edit_data,
        attributes => [$additional_attribute, $string_instruments_attribute]
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
        linkTypeID  => 148,
        attributes  => [],
        entities => [
            { gid => '745c079d-374e-4436-9448-da92dedef3ce' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1994, month => 2, day => 29 },
        end_date     => { year => 1999, month => 2, day => undef },
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for invalid date is not created');

    my $response = from_json($mech->content);
    like($response->{error}, qr/^invalid date/, 'error is returned for invalid begin date');
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
        linkTypeID  => 148,
        attributes  => [
            { type => { gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f' } },
            { type => { gid => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea' } },
            { type => { gid => '63021302-86cd-4aee-80df-2270d54f4978' }, credited_as => 'crazy guitar' },
        ],
        entities => [
            { gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1999, month => 1, day => 1 },
        end_date     => { year => 2009, month => 9, day => 9 },
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
                id                  => 148,
                name                => 'instrument',
                link_phrase         => '{additional} {guest} {solo} {instrument:%|instruments}',
                long_link_phrase    => 'performed {additional} {guest} {solo} {instrument:%|instruments} on',
                reverse_link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
            },
            entity1 => { id => 2, gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', name => 'King of the Mountain' },
            entity0 => { id => 8, gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', name => 'Test Alias' },
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
            attributes  => [$additional_attribute, $crazy_guitar, $string_instruments_attribute]
        },
        old => {
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => [$guitar_attribute]
        },
        entity0_credit => '',
        entity1_credit => '',
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
        linkTypeID  => 148,
        entities => [
            { gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1999, month => 1, day => 1 },
        end_date     => { year => 2009, month => 9, day => 9 },
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
                id                  => 148,
                name                => 'instrument',
                link_phrase         => '{additional} {guest} {solo} {instrument:%|instruments}',
                long_link_phrase    => 'performed {additional} {guest} {solo} {instrument:%|instruments} on',
                reverse_link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
            },
            entity1 => { id => 2, gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', name => 'King of the Mountain' },
            entity0 => { id => 8, gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', name => 'Test Alias' },
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
        entity0_credit => '',
        entity1_credit => '',
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
        linkTypeID  => 148,
        entities => [
            { gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        attributes  => [{%$guitar_attribute, removed => 1}],
        begin_date   => { year => undef, month => undef, day => undef },
        end_date     => { year => undef, month => undef, day => undef },
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
                id                  => 148,
                name                => 'instrument',
                link_phrase         => '{additional} {guest} {solo} {instrument:%|instruments}',
                long_link_phrase    => 'performed {additional} {guest} {solo} {instrument:%|instruments} on',
                reverse_link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
            },
            entity1 => { id => 2, gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', name => 'King of the Mountain' },
            entity0 => { id => 8, gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', name => 'Test Alias' },
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
        entity0_credit => '',
        entity1_credit => '',
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
        linkTypeID  => 148,
        entities => [
            { gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
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
        linkTypeID  => 179,
        entities => [
            { gid => '0798d15b-64e2-499f-9969-70167b1d8617' },
            { name => 'HAHAHA' }
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
        linkTypeID  => 179,
        entities => [
            { gid => '0798d15b-64e2-499f-9969-70167b1d8617' },
            { name => 'gopher://example.com/' }
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
        linkTypeID  => 179,
        entities => [
            { gid => '0798d15b-64e2-499f-9969-70167b1d8617' },
            { name => 'http://en.Wikipedia.org:80/wiki/Boredoms' }
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
    is($response->{error}, 'a verified email address is required', 'error is returned for unconfirmed email');
};


test 'Duplicate relationships are ignored' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 148,
        attributes  => [
            { type => { gid => '63021302-86cd-4aee-80df-2270d54f4978' }, credited_as => 'crazy guitar' },
        ],
        entities => [
            { gid => '745c079d-374e-4436-9448-da92dedef3ce' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1999, month => 1, day => 1 },
        end_date     => { year => 1999, month => 2, day => undef },
    } ];

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    is(scalar(@edits), 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Create');

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    is(scalar(@edits), 0);
};

test 'undef relationship begin_date/end_date fields are ignored (MBS-8317)' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        linkTypeID  => 148,
        attributes  => [{ type => { gid => '63021302-86cd-4aee-80df-2270d54f4978' } }],
        entities => [
            { gid => '745c079d-374e-4436-9448-da92dedef3ce' },
            { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8' }
        ],
        begin_date   => { year => 1999, month => undef, day => undef },
        end_date     => { year => 1999, month => undef, day => undef },
    };

    my @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => [$edit_data] }));
    } $c;

    $edit_data = {
        edit_type   => $EDIT_RELATIONSHIP_EDIT,
        id          => $edits[0]->entity_id,
        linkTypeID  => 148,
        begin_date   => undef
        # implied undef end_date
    };

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => [$edit_data] }));
    } $c;

    # should be a noop
    is(scalar(@edits), 0);
};

test 'Release group types are loaded before creating edits (MBS-8212)' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    my $editor_id = $c->model('Editor')->insert({
        name => 'new_editor',
        password => 'password'
    });

    $c->model('Editor')->update_email($editor_id, 'noreply@example.com');

    my $artist = $c->model('Artist')->insert({
        name => 'Test',
        sort_name => 'Test'
    });

    my $artist_credit_id = $c->model('ArtistCredit')->find_or_insert({
        names => [
            {
                name => 'Test',
                artist => { id => $artist->{id} },
                join_phrase => ''
            }
        ]
    });

    my $release_group = $c->model('ReleaseGroup')->insert({
        name => 'Test',
        primary_type_id => 1,
        secondary_type_ids => [1],
        artist_credit => $artist_credit_id
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $edit_data = [
        {
            edit_type => $EDIT_RELEASEGROUP_EDIT,
            gid => $release_group->{gid},
            name => 'test?',
            # Should be a no-op.
            primary_type_id => 1,
            secondary_type_ids => [1]
        }
    ];

    my ($edit) = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $edit_data }));
    } $c;

    cmp_deeply($edit->data, {
        new => { name => 'test?' },
        old => { name => 'Test' },
        entity => {
            name => 'Test',
            id => ignore(),
            gid => ignore()
        }
    });
};

test 'Invalid release event dates are rejected' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    my $response;
    my @edits;

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $artist_credit = {
        names => [
            {
                artist => { id => 39282, name => 'Boredoms' },
                name => 'Boredoms',
                join_phrase => '',
            }
        ]
    };

    my $release_edits = [
        {
            edit_type => $EDIT_RELEASE_CREATE,
            name => 'Vision  Creation  Newsun',
            release_group_id => undef,
            artist_credit => $artist_credit,
            events => [
                { date => { year => '0000', month => '0', day => '0' } }
            ]
        }
    ];

    my $release_group_edits = [
        {
            edit_type => $EDIT_RELEASEGROUP_CREATE,
            name => 'Vision  Creation  Newsun',
            artist_credit => $artist_credit,
        }
    ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $release_group_edits }));
    } $c;

    $response = from_json($mech->content);
    $release_edits->[0]->{release_group_id} = $response->{edits}->[0]->{entity}->{id};

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            editNote => 'foo',
            makeVotable => 0,
        }));
    } $c;

    ok(scalar(@edits) == 0, 'release with invalid event date is not created');

    $response = from_json($mech->content);
    like($response->{error}, qr/^invalid date: 0000-0-0/, 'error is returned for invalid release event date');
};

test 'Releases can be added without any mediums' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    my $response;
    my @edits;

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $artist_credit = {
        names => [
            {
                artist => { id => 5, name => 'David Bowie' },
                name => 'David Bowie',
                join_phrase => '',
            }
        ]
    };

    my $release_edits = [{
        edit_type         => $EDIT_RELEASE_CREATE,
        name              => 'NoMedium',
        release_group_id  => undef,
        artist_credit     => $artist_credit,
    }];

    my $release_group_edits = [{
        edit_type     => $EDIT_RELEASEGROUP_CREATE,
        name          => 'NoMedium',
        artist_credit => $artist_credit,
    }];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $release_group_edits }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::ReleaseGroup::Create', 'release group created');

    $response = from_json($mech->content);
    is($response->{edits}->[0]->{response}, $WS_EDIT_RESPONSE_OK, 'ws response says OK');

    my $release_group_id = $response->{edits}->[0]->{entity}->{id};
    $release_edits->[0]->{release_group_id} = $release_group_id;

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            editNote => 'foo',
            makeVotable => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Release::Create', 'release added without any mediums');
};


test 'Empty artist credit name defaults to the artist name' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $artist_credit = {
        names => [
            {
                artist => { id => 5, name => 'David Bowie' },
                # An empty AC name is disallowed at the DB level;
                # this should default to the artist name.
                name => '',
                join_phrase => '',
            }
        ]
    };

    my $release_group_edits = [{
        edit_type     => $EDIT_RELEASEGROUP_CREATE,
        name          => 'empty AC name test',
        artist_credit => $artist_credit,
    }];

    my ($edit) = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $release_group_edits }));
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Create', 'release group edit was created');
    is($edit->status, $STATUS_APPLIED, 'release group edit was applied');

    my $response = from_json($mech->content);
    is($response->{edits}->[0]->{response}, $WS_EDIT_RESPONSE_OK, 'ws response says OK');
};

1;
