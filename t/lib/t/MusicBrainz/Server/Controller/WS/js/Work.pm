package t::MusicBrainz::Server::Controller::WS::js::Work;
use strict;
use warnings;

use Test::More;
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test      qw( capture_edits post_json );
use MusicBrainz::Server::Constants qw(
  $EDIT_WORK_CREATE
  $WS_EDIT_RESPONSE_OK
);
use Test::Deep qw( cmp_deeply ignore );

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $c = $test->c;
    my $json = JSON->new;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    $c->sql->do(<<~'SQL');
        INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
            VALUES (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en', FALSE),
                   (4223060, 'Hello! Let''s Meet Again (7ninmatsuri version)', 'Hello! Let''s Meet Again (7ninmatsuri version)', 'en_US', TRUE),
                   (4223060, 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'Saluton! Ni Renkontu Denove (7nin-matsuria versio)', 'eo', TRUE);
        SQL

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header('Accept' => 'application/json');

    my $url = q(/ws/js/work?q=Let's Meet Again&direct=true);

    $mech->get_ok($url, 'fetching');

    my $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primaryAlias}, q(Hello! Let's Meet Again (7ninmatsuri version)), 'Got correct primary alias (en_US)');

    $c->sql->do(<<~'SQL');
        INSERT INTO work_alias (work, name, sort_name, locale, primary_for_locale)
            VALUES (4223060, 'Hello! Let''s Meet Again (7nin Matsuri version)', 'Hello! Let''s Meet Again (7nin Matsuri version)', 'en', TRUE);
        SQL

    $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header('Accept' => 'application/json');
    $mech->get_ok($url, 'fetching again');

    $data = $json->decode($mech->content);

    is($data->[0]->{id}, 4223060, 'Got the work expected');
    is($data->[0]->{primaryAlias}, q(Hello! Let's Meet Again (7nin Matsuri version)), 'Got correct primary alias (en)');

};

test 'previewing/creating/editing a work' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    my $response;
    my $html;
    my @edits;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' } );

    my $work_edits = [
        {
            edit_type  => $EDIT_WORK_CREATE,
            name       => 'Follow That Dream',
            type_id    => 17,
            comment    => 'Elvis Presley song',
            languages  => [120],
            attributes => [
                {
                    attribute_type_id  => 1,
                    attribute_value_id => 13,
                    attribute_text     => undef,
                },
                {
                    attribute_type_id  => 6,
                    attribute_value_id => undef,
                    attribute_text     => 'Free Text',
                }
            ]
        }
    ];

    post_json( $mech, '/ws/js/edit/preview',
        encode_json( { edits => $work_edits } ) );
    $response = from_json( $mech->content );

    is( $response->{previews}->[0]->{editName},
        'Add work', 'ws preview has correct editName' );

    $html = $response->{previews}->[0]->{preview};

    like( $html, qr/Follow That Dream/,  'preview has work name' );
    like( $html, qr/Elvis Presley song/, 'preview has work comment' );
    like( $html, qr/Song/,               'preview has work type' );
    like( $html, qr/English/,   'preview has language (120 = English)' );
    like( $html, qr/Free Text/, 'preview has text attribute' );
    like( $html, qr/E major/,   'preview has value attribute' );

    @edits = capture_edits {
        post_json(
            $mech,
            '/ws/js/edit/create',
            encode_json(
                {
                    edits       => $work_edits,
                    makeVotable => 0,
                }
            )
        );
    }
    $c;

    isa_ok( $edits[0], 'MusicBrainz::Server::Edit::Work::Create',
        'work created' );
    ok( $edits[0]->auto_edit, 'new work should be an auto edit' );

    $response = from_json( $mech->content );

    cmp_deeply(
        $response->{edits}->[0],
        {
            edit_type => $EDIT_WORK_CREATE,
            entity    => {
                artists      => [],
                attributes   => [
                    {
                        id       => ignore(),
                        typeID   => 6,
                        typeName => 'ASCAP ID',
                        value    => 'Free Text',
                        value_id => undef,
                    },
                    {
                        id       => ignore(),
                        typeID   => 1,
                        typeName => 'Key',
                        value    => 'E major',
                        value_id => 13,
                    }
                ],
                authors      => [],
                comment      => 'Elvis Presley song',
                editsPending => JSON::false,
                entityType   => 'work',
                gid          => ignore(),
                id           => ignore(),
                iswcs        => [],
                languages    => [
                    {
                        language => {
                            entityType  => 'language',
                            frequency   => 2,
                            id          => 120,
                            iso_code_1  => 'en',
                            iso_code_2b => 'eng',
                            iso_code_2t => 'eng',
                            iso_code_3  => 'eng',
                            name        => 'English',
                        },
                        last_updated  => ignore(),
                    }
                ],
                last_updated  => ignore(),
                name          => 'Follow That Dream',
                other_artists => [],
                typeID        => 17,
                typeName      => 'Song',
            },
            response => $WS_EDIT_RESPONSE_OK,
        },
        'ws response contains serialized work data'
    );

};

1;
