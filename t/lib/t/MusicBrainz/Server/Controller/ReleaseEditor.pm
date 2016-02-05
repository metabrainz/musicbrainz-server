package t::MusicBrainz::Server::Controller::ReleaseEditor;
use utf8;
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Controller::ReleaseEditor qw( _process_seeded_data );
use Test::More;
use Test::Deep qw( cmp_deeply cmp_bag ignore );
use Test::Routine;

with 't::Context';

test 'detecting indexes that start at 0 instead of 1' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'artist_credit.names.1.name' => 'Nithyasree Mahadevan',
        'labels.1.name' => 'Charsur Digital Workstation',
        'mediums.1.track.10.artist_credit.names.1.name' => 'Purvikalyani - Ragam - Violin',
        'mediums.1.track.11.artist_credit.names.1.name' => 'Parama Pavana Rama ',
        'mediums.1.track.12.artist_credit.names.1.name' => 'Tani ',
        'mediums.1.track.13.artist_credit.names.1.name' => 'Ramanai Bajitaal',
        'mediums.1.track.14.artist_credit.names.1.name' => 'Idu Bhagya ',
        'mediums.1.track.15.artist_credit.names.1.name' => 'Udayadi Nazhigail - Viruttam ',
        'mediums.1.track.16.artist_credit.names.1.name' => 'Velan Varuvaradi',
        'mediums.1.track.17.artist_credit.names.1.name' => 'Nambikettavar',
        'mediums.1.track.1.artist_credit.names.1.name' => 'Sami Daya Juda - Varnam',
        'mediums.1.track.2.artist_credit.names.1.name' => 'Sri Rama Padama',
        'mediums.1.track.3.artist_credit.names.1.name' => 'Gopalaka Pahimam',
        'mediums.1.track.4.artist_credit.names.1.name' => 'Varamu - Ragam - Vocal - Violin',
        'mediums.1.track.5.artist_credit.names.1.name' => 'Manasuloni',
        'mediums.1.track.6.artist_credit.names.1.name' => 'Enneramum',
        'mediums.1.track.7.artist_credit.names.1.name' => 'Sri Satya Narayana',
        'mediums.1.track.8.artist_credit.names.1.name' => 'Anadudanu',
        'mediums.1.track.9.artist_credit.names.1.name' => 'Purvikalyani - Ragam - Vocal',
        'name' => 'December Season 2000',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        "artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "labels.0 isn’t defined, do your indexes start at 0?",
        "mediums.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.1.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.2.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.3.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.4.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.5.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.6.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.7.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.8.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.9.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.10.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.11.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.12.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.13.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.14.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.15.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.16.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
        "mediums.1.track.17.artist_credit.names.0 isn’t defined, do your indexes start at 0?",
    ]);
};

test 'treating negative indexes as unknown fields' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.-1.track.0.name' => 'Smoking Gun in Wasco',
        'mediums.-1.track.0.length' => '320840',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'mediums must be an array',
        'Unknown field: mediums.-1',
    ]);
};

test 'returning an error for literal "n" as an index' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.n.format' => 'CD',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'mediums must be an array',
        'Unknown field: mediums.n',
    ]);
};

test 'returning an error for zero-padded indexes' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.0.track.00.name' => 'Foo',
        'mediums.0.track.01.name' => 'Bar',
        'mediums.0.track.02.name' => 'Baz',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'mediums.0.track must be an array',
        'Unknown field: mediums.0.track.01',
        'Unknown field: mediums.0.track.00',
        'Unknown field: mediums.0.track.02',
    ]);
};

test 'returning an error when multiple MBIDs are posted' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.0.track.0.artist_credit.names.0.name' => 'foo',
        'mediums.0.track.0.artist_credit.names.0.mbid' => [
            '9bffb20c-dd17-4895-9fd1-4e73e888d799',
            'bfcc3746-05ff-421f-ae02-c3e760b2c1ca',
        ],
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    like(
        $result->{errors}->[0],
        qr/^Invalid mediums.0.track.0.artist_credit.names.0.mbid/,
    );
};

test 'returning an error when a space appears before an MBID' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.0.track.0.artist_credit.names.0.name' => 'foo',
        'mediums.0.track.0.artist_credit.names.0.mbid' => ' 9bffb20c-dd17-4895-9fd1-4e73e888d799',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'Invalid mediums.0.track.0.artist_credit.names.0.mbid: “ 9bffb20c-dd17-4895-9fd1-4e73e888d799”.',
    ]);
};

our $japan = {
    'annotation' => '',
    'begin_date' => '',
    'code' => 'JP',
    'comment' => '',
    'containment' => [],
    'editsPending' => \0,
    'end_date' => '',
    'ended' => \0,
    'entityType' => 'area',
    'gid' => '2db42837-c832-3c27-b4a3-08198f75693c',
    'id' => 107,
    'name' => 'Japan',
    'typeID' => 1,
    'iso_3166_1_codes' => ['JP'],
};

test 'seeding a release with no tracklist' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');

    my $params = expand_hash({
        "name" => "大人なのよ!/1億3千万総ダイエット王国",
        "artist_credit.names.0.artist.name" => "Berryz工房",
        "date.year" => "2014",
        "date.month" => "02",
        "date.day" => "19",
        "country" => "JP",
        "status" => "official",
        "language" => "kpn",
        "script" => "Kpan",
        "type" => "single",
        "edit_note" => "http://www.helloproject.com/discography/berryz/s_036.html",
        "make_votable" => "1",
        "labels.4.name" => "PICCOLO TOWN",
        "labels.4.catalog_number" => "PKCP-5256",
        "labels.4.mbid" => "9f142207-1a9e-4530-98a3-de23f50e8472",
        "comment" => "通常盤B",
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        'errors' => [
            "Invalid language: “kpn”.",
            "Invalid script: “kpan”.",
            "labels.0 isn’t defined, do your indexes start at 0?",
            "Invalid labels.4.mbid: “9f142207-1a9e-4530-98a3-de23f50e8472”."
        ],
        'seed' => {
            'releaseGroup' => {
                'typeID' => 2,
                'name' => "大人なのよ!/1億3千万総ダイエット王国",
                'secondaryTypeIDs' => []
            },
            'statusID' => 1,
            'name' => "大人なのよ!/1億3千万総ダイエット王国",
            'editNote' => 'http://www.helloproject.com/discography/berryz/s_036.html',
            'comment' => "通常盤B",
            'events' => [
                { 'date' => '2014-02-19', 'country' => $japan }
            ],
            'makeVotable' => '1',
            'artistCredit' => [
                { 'artist' => { 'name' => "Berryz工房" } }
            ],
            'labels' => [
                { 'catalogNumber' => '' },
                { 'catalogNumber' => '' },
                { 'catalogNumber' => '' },
                { 'catalogNumber' => '' },
                { 'catalogNumber' => 'PKCP-5256' }
            ]
        }
    });
};

test 'seeding a string where an array is expected' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        "mediums.0.track.0.artist_credit" => "ケラケラ ",
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'mediums.0.track.0.artist_credit must be a hash.',
    ]);
};

test 'seeding a an array where a string is expected' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        "mediums.0.track.0.artist_credit.names.0.name" => [ "foo", "bar" ],
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'mediums.0.track.0.artist_credit.names.0.name must be a scalar, not a hash or array.',
    ]);
};


test 'seeding a lowercase country' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');

    my $params = expand_hash({
        "country" => "jp",
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        'errors' => [],
        'seed' => {
            'events' => [{ 'country' => $japan }],
        },
    });
};


test 'seeding a toc' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');

    my $params = expand_hash({
        "mediums.0.toc" => '1 7 171327 150 22179 49905 69318 96240 121186 143398',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        errors => [],
        seed => {
            mediums => [
                {
                    tracks => [
                        { length => 293720, number => 1, position => 1 },
                        { length => 369680, number => 2, position => 2 },
                        { length => 258839, number => 3, position => 3 },
                        { length => 358960, number => 4, position => 4 },
                        { length => 332613, number => 5, position => 5 },
                        { length => 296160, number => 6, position => 6 },
                        { length => 372386, number => 7, position => 7 },
                    ],
                    position => 1,
                    toc => '1 7 171327 150 22179 49905 69318 96240 121186 143398',
                    cdtocs => 1
                },
            ]
        },
    });
};


test 'seeding url relationships' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url');

    my $params = expand_hash({
        "urls.0.url" => 'http://foo.bar.baz/',
        "urls.1.url" => 'http://foo.bar.baz/foo/',
        "urls.1.link_type" => '76',
        "urls.2.link_type" => '77',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        errors => [],
        seed => {
            relationships => [
                {
                    target => {
                        name => 'http://foo.bar.baz/',
                        entityType => 'url',
                    },
                },
                {
                    linkTypeID => 76,
                    target => {
                        name => 'http://foo.bar.baz/foo/',
                        entityType => 'url',
                    },
                },
                {
                    linkTypeID => 77,
                    target => {
                        name => '',
                        entityType => 'url',
                    },
                },
            ]
        },
    });
};


test 'MBS-7250: seeding empty date parts gives an ISE' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        "events.0.date.year" => "2000",
        "events.0.date.month" => "",
        "events.0.date.day" => "",
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        errors => [],
        seed => {
            events => [
                { date => "2000" },
            ]
        },
    });
};


test 'MBS-7439: seeding badly formatted dates gives an ISE' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        "events.0.date.year" => "15.0",
        "events.0.date.month" => ".2",
        "events.0.date.day" => "14",
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'Invalid events.0.date.year: “15.0”.',
        'Invalid events.0.date.month: “.2”.',
    ]);
};


test 'MBS-7447: seeding an invalid track length gives an ISE' => sub {
    my $test = shift;
    my $c = $test->c;

    my $params = expand_hash({
        'mediums.0.track.0.length' => '4:195:0',
        'mediums.0.track.1.length' => ':10',
        'mediums.0.track.2.length' => '4:60',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_bag($result->{errors}, [
        'Invalid mediums.0.track.0.length: “4:195:0”.',
        'Invalid mediums.0.track.1.length: “:10”.',
        'Invalid mediums.0.track.2.length: “4:60”.',
    ]);
};


test 'seeding a pregap track' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url');

    my $params = expand_hash({
        "mediums.0.track.0.name" => 'foo',
        "mediums.0.track.0.pregap" => '1',
    });

    my $result = MusicBrainz::Server::Controller::ReleaseEditor->_process_seeded_data($c, $params);

    cmp_deeply($result, {
        errors => [],
        seed => {
            mediums => [
                {
                    position => 1,
                    tracks => [
                        {
                            name => 'foo',
                            position => 0,
                            number => 0,
                        }
                    ]
                }
            ]
        },
    });
};

1;
