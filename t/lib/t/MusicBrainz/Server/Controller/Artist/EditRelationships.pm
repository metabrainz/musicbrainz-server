package t::MusicBrainz::Server::Controller::Artist::EditRelationships;
use t::MusicBrainz::Server::Controller::RelationshipEditor qw(
    $additional_attribute
    $string_instruments_attribute
    $guitar_attribute
    $crazy_guitar
);
use utf8;
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::Fatal;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'adding a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post("/artist/745c079d-374e-4436-9448-da92dedef3ce/edit", {
            'edit-artist.name' => 'Test Artist',
            'edit-artist.sort_name' => 'Artist, Test',
            'edit-artist.type_id' => '1',
            'edit-artist.gender_id' => '1',
            'edit-artist.period.ended' => '1',
            'edit-artist.rel.0.link_type_id' => '1',
            'edit-artist.rel.0.attributes.0.type.gid' => '36990974-4f29-4ea1-b562-3838fa9b8832',
            'edit-artist.rel.0.attributes.1.type.gid' => '4f7bb10f-396c-466a-8221-8e93f5e454f9',
            'edit-artist.rel.0.attributes.2.type.gid' => 'c3273296-91ba-453d-94e4-2fb6e958568e',
            'edit-artist.rel.0.attributes.2.credited_as' => 'crazy guitar',
            'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            'edit-artist.rel.0.period.begin_date.year' => '1999',
            'edit-artist.rel.0.period.begin_date.month' => '1',
            'edit-artist.rel.0.period.begin_date.day' => '1',
            'edit-artist.rel.0.period.end_date.year' => '1999',
            'edit-artist.rel.0.period.end_date.month' => '2',
            'edit-artist.rel.0.period.end_date.day' => undef,
        });
    } $c;

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


test 'editing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    subtest 'change target, add end date and attribute' => sub {
        my @edits = capture_edits {
            $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '1',
                'edit-artist.rel.0.attributes.0.type.gid' => '36990974-4f29-4ea1-b562-3838fa9b8832',
                'edit-artist.rel.0.attributes.1.type.gid' => '4f7bb10f-396c-466a-8221-8e93f5e454f9',
                'edit-artist.rel.0.attributes.2.type.gid' => 'c3273296-91ba-453d-94e4-2fb6e958568e',
                'edit-artist.rel.0.attributes.2.credited_as' => 'crazy guitar',
                'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'edit-artist.rel.0.period.begin_date.year' => '1999',
                'edit-artist.rel.0.period.begin_date.month' => '1',
                'edit-artist.rel.0.period.begin_date.day' => '1',
                'edit-artist.rel.0.period.end_date.year' => '2009',
                'edit-artist.rel.0.period.end_date.month' => '9',
                'edit-artist.rel.0.period.end_date.day' => '9',
                'edit-artist.rel.0.period.ended' => '1',
            });
        } $c;

        is(scalar @edits, 1);
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
                entity1 => { id => 3, name => 'π' },
                entity0 => { id => 8, name => 'Test Alias' },
                begin_date  => { month => undef, day => undef, year => undef },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 0,
                attributes  => [$additional_attribute, $string_instruments_attribute],
            },
            relationship_id => 3,
            new => {
                entity1     => { id => 2, name => 'King of the Mountain' },
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => 9, day => 9, year => 2009 },
                ended       => 1,
                attributes  => [$additional_attribute, $string_instruments_attribute, $crazy_guitar],
            },
            old => {
                entity1     => { id => 3, name => 'π' },
                begin_date  => { month => undef, day => undef, year => undef },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 0,
                attributes  => [$additional_attribute, $string_instruments_attribute],
            },
            edit_version => 2,
        });

        ok !exception { $edit->accept };
    };

    subtest 'remove attribute and end date' => sub {
        my @edits = capture_edits {
            $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '1',
                'edit-artist.rel.0.attributes.0.type.gid' => '36990974-4f29-4ea1-b562-3838fa9b8832',
                'edit-artist.rel.0.attributes.1.type.gid' => 'c3273296-91ba-453d-94e4-2fb6e958568e',
                'edit-artist.rel.0.attributes.1.credited_as' => 'crazy guitar',
                'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'edit-artist.rel.0.period.begin_date.year' => '1999',
                'edit-artist.rel.0.period.begin_date.month' => '1',
                'edit-artist.rel.0.period.begin_date.day' => '1',
                'edit-artist.rel.0.period.end_date.year' => '',
                'edit-artist.rel.0.period.end_date.month' => '',
                'edit-artist.rel.0.period.end_date.day' => '',
                'edit-artist.rel.0.period.ended' => '1',
            });
        } $c;

        is(scalar @edits, 1);
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
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => 9, day => 9, year => 2009 },
                ended       => 1,
                attributes  => [$additional_attribute, $string_instruments_attribute, $crazy_guitar],
            },
            relationship_id => 3,
            new => {
                end_date    => { month => undef, day => undef, year => undef },
                attributes  => [$additional_attribute, $crazy_guitar]
            },
            old => {
                end_date    => { month => 9, day => 9, year => 2009 },
                attributes  => [$additional_attribute, $string_instruments_attribute, $crazy_guitar]
            },
            edit_version => 2,
        });

        ok !exception { $edit->accept };
    };

    subtest 'remove begin date and ended flag' => sub {
        my @edits = capture_edits {
            $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '1',
                'edit-artist.rel.0.attributes.0.type.gid' => '36990974-4f29-4ea1-b562-3838fa9b8832',
                'edit-artist.rel.0.attributes.1.type.gid' => 'c3273296-91ba-453d-94e4-2fb6e958568e',
                'edit-artist.rel.0.attributes.1.credited_as' => 'crazy guitar',
                'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            });
        } $c;

        is(scalar @edits, 1);
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
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 1,
                attributes  => [$additional_attribute, $crazy_guitar],
            },
            relationship_id => 3,
            new => {
                begin_date  => { month => undef, day => undef, year => undef },
                ended       => 0,
            },
            old => {
                begin_date  => { month => 1, day => 1, year => 1999 },
                ended       => 1,
            },
            edit_version => 2,
        });

        ok !exception { $edit->accept };
    };
};


test 'removing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.relationship_id' => '1',
            'edit-artist.rel.0.removed' => '1',
            'edit-artist.rel.0.link_type_id' => '1',
        });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');
};


test 'Cannot create a relationship under a grouping relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.link_type_id' => '2',
            'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
        });
    } $c;

    ok(!defined $edit, "no edits were made");
    like($mech->uri, qr{/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit$}, "page hasn't changed");
};

1;
