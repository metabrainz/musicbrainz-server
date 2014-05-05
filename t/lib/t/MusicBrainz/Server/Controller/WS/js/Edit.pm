package t::MusicBrainz::Server::Controller::WS::js::Edit;
use JSON;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_RELATIONSHIP_CREATE
);
use MusicBrainz::Server::Test qw( capture_edits );
use Test::More;
use Test::Deep qw( cmp_deeply ignore );
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
        VALUES (39282, '0798d15b-64e2-499f-9969-70167b1d8617', 'Boredoms', 'Boredoms');

        INSERT INTO url (id, gid, url)
        VALUES (2, 'de409476-4ad8-4ce8-af2f-d47bee0edf97', 'http://en.wikipedia.org/wiki/Boredoms');

        INSERT INTO link_type (id, name, gid, link_phrase, long_link_phrase, reverse_link_phrase, entity_type0, entity_type1)
        VALUES (2, 'wikipedia', 'fcd58926-4243-40bb-a2e5-c7464b3ce577', 'wikipedia', 'wikipedia', 'wikipedia', 'artist', 'url');

        ALTER SEQUENCE track_id_seq RESTART 100;
    });
}

sub post_json {
    my ($mech, $uri, $json) = @_;

    my $req = HTTP::Request->new('POST', $uri);

    $req->header('Content-Type' => 'application/json');
    $req->content($json);

    return $mech->request($req);
}

test 'previewing/creating a release group and release' => sub {
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
                artist => { id => 39282, name => "Boredoms" },
                name => "Boredoms"
            }
        ]
    };

    my $release_edits = [ {
        edit_type         => $EDIT_RELEASE_CREATE,
        name              => 'Vision Creation Newsun',
        release_group_id  => undef,
        comment           => 'limited edition',
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

    like($html, qr/Boredoms/, 'preview has artist name');
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
        name          => 'Vision Creation Newsun',
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
            as_auto_editor => 0,
        }));
    } $c;

    is(scalar @edits, 0, 'release not created without edit note');

    $response = from_json($mech->content);

    is($response->{error}, 'edit_note required', 'ws response says edit_note required');

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({
            edits => $release_edits,
            edit_note => 'foo',
            as_auto_editor => 0,
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
           type => 'release',
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
                    number          => '1',
                    name            => '○',
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
            as_auto_editor => 0,
        }));
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::Create', 'medium 1 created');
    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Medium::Create', 'medium 2 created');

    ok($edits[0]->auto_edit, 'new medium should be an auto edit');
    ok($edits[1]->auto_edit, 'new medium should be an auto edit');

    $response = from_json($mech->content);

    cmp_deeply($response->{edits}, [
        {
            entity => {
                position => 1,
                id => $response->{edits}->[1]->{entity}->{id} - 1
            },
            message => 'OK',
        },
        {
            entity => {
                position => 2,
                id => $response->{edits}->[0]->{entity}->{id} + 1
            },
            message => 'OK',
        }
    ], 'ws response contains new medium info');


    # Not editing the artist credit should not cause an ISE.
    # Fixed by 4cacdcea86ad5b907a33b531261114055ec7885c.

    $release_edits = [ {
        edit_type   => $EDIT_RELEASE_EDIT,
        name        => 'Vision Creation Newsun!',
        to_edit     => $release_id,
    } ];

    post_json($mech, '/ws/js/edit/preview', encode_json({ edits => $release_edits }));
    $response = from_json($mech->content);

    is($response->{error}, undef, 'editing just the release title does not cause an ISE');
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
        link_type   => 2,
        entity0     => 39282,
        entity1     => 'HAHAHA',
        type0       => 'artist',
        type1       => 'url',
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $invalid_url }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for invalid URL is not created');

    $response = from_json($mech->content);
    like($response->{error}, qr/^invalid URL: HAHAHA/, 'error is returned for invalid URL');

    my $unsupported_protocol = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        link_type   => 2,
        entity0     => 39282,
        entity1     => 'gopher://example.com/',
        type0       => 'artist',
        type1       => 'url',
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $unsupported_protocol }));
    } $c;

    ok(scalar(@edits) == 0, 'relationship for URL with unsupported protocol is not created');

    $response = from_json($mech->content);
    like($response->{error}, qr/^unsupported URL protocol: gopher/, 'error is returned for unsupported protocol');

    my $non_canonical_url = [ {
        edit_type   => $EDIT_RELATIONSHIP_CREATE,
        link_type   => 2,
        entity0     => 39282,
        entity1     => 'http://en.Wikipedia.org:80/wiki/Boredoms',
        type0       => 'artist',
        type1       => 'url',
    } ];

    @edits = capture_edits {
        post_json($mech, '/ws/js/edit/create', encode_json({ edits => $non_canonical_url }));
    } $c;

    my $url = $c->model('URL')->get_by_id($edits[0]->data->{entity1}->{id});

    is($url->url, 'http://en.wikipedia.org/wiki/Boredoms', 'URL is canonicalized');
    is($url->id, 2, 'existing URL is used');
};

1;
