package t::MusicBrainz::Server::Controller::Artist::EditRelationships;
use utf8;
use strict;
use warnings;

use t::MusicBrainz::Server::Controller::RelationshipEditor qw(
    $additional_attribute
    $string_instruments_attribute
    $guitar_attribute
    $crazy_guitar
);
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::Fatal;
use Test::More;
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

=head2 Test description

This test checks whether non-URL relationships are correctly added, removed
and modified when editing artists, including several edge cases.

=cut

test 'Adding a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit', {
            'edit-artist.name' => 'Test Artist',
            'edit-artist.sort_name' => 'Artist, Test',
            'edit-artist.type_id' => '1',
            'edit-artist.gender_id' => '1',
            'edit-artist.period.ended' => '1',
            'edit-artist.rel.0.link_type_id' => '148',
            'edit-artist.rel.0.attributes.0.type.gid' => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
            'edit-artist.rel.0.attributes.1.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
            'edit-artist.rel.0.attributes.2.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
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

    is(@edits, 2, 'Two edits were entered');

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
    }, 'The first edit contains the right data');

    cmp_deeply($edits[1]->data,  {
        %edit_data,
        attributes => [$additional_attribute, $string_instruments_attribute]
    }, 'The second edit contains the right data');
};


test 'Editing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    subtest 'Change target, add end date and attribute' => sub {
        my @edits = capture_edits {
            $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '148',
                'edit-artist.rel.0.attributes.0.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
                'edit-artist.rel.0.attributes.0.credited_as' => 'crazy guitar',
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

        is(@edits, 1, 'One edit was entered');
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
                entity1 => { id => 3, gid => '659f405b-b4ee-4033-868a-0daa27784b89', name => 'π' },
                entity0 => { id => 8, gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', name => 'Test Alias' },
                begin_date  => { month => undef, day => undef, year => undef },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 0,
                attributes  => [$additional_attribute, $string_instruments_attribute],
            },
            relationship_id => 3,
            new => {
                entity1     => { id => 2, gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', name => 'King of the Mountain' },
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => 9, day => 9, year => 2009 },
                ended       => 1,
                attributes  => [$additional_attribute, $crazy_guitar, $string_instruments_attribute],
            },
            old => {
                entity1     => { id => 3, gid => '659f405b-b4ee-4033-868a-0daa27784b89', name => 'π' },
                begin_date  => { month => undef, day => undef, year => undef },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 0,
                attributes  => [$additional_attribute, $string_instruments_attribute],
            },
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
        }, 'The edit contains the right data');

        ok !exception { $edit->accept }, 'The edit could be accepted';
    };

    subtest 'Remove attribute and end date' => sub {
        my @edits = capture_edits {
            $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '148',
                'edit-artist.rel.0.attributes.0.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
                'edit-artist.rel.0.attributes.0.removed' => '1',
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

        is(@edits, 1, 'One edit was entered');
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
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => 9, day => 9, year => 2009 },
                ended       => 1,
                attributes  => [$additional_attribute, $crazy_guitar, $string_instruments_attribute],
            },
            relationship_id => 3,
            new => {
                end_date    => { month => undef, day => undef, year => undef },
                attributes  => [$additional_attribute, $crazy_guitar]
            },
            old => {
                end_date    => { month => 9, day => 9, year => 2009 },
                attributes  => [$additional_attribute, $crazy_guitar, $string_instruments_attribute]
            },
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
        }, 'The edit contains the right data');

        is($edit->status, $STATUS_APPLIED, 'The edit was applied');
    };

    subtest 'Remove begin date' => sub {
        my @edits = capture_edits {
            $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '148',
                'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'edit-artist.rel.0.period.begin_date.year' => '',
                'edit-artist.rel.0.period.begin_date.month' => '',
                'edit-artist.rel.0.period.begin_date.day' => '',
                'edit-artist.make_votable' => '1',
            });
        } $c;

        is(@edits, 1, 'One edit was entered');
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
                begin_date  => { month => 1, day => 1, year => 1999 },
                end_date    => { month => undef, day => undef, year => undef },
                ended       => 1,
                attributes  => [$additional_attribute, $crazy_guitar],
            },
            relationship_id => 3,
            new => {
                begin_date  => { month => undef, day => undef, year => undef },
            },
            old => {
                begin_date  => { month => 1, day => 1, year => 1999 },
            },
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
        }, 'The edit contains the right data');

        ok !exception { $edit->accept }, 'The edit could be accepted';
    };

    subtest 'Remove ended flag' => sub {
        my @edits = capture_edits {
            $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
                'edit-artist.name' => 'Test Alias',
                'edit-artist.sort_name' => 'Kate Bush',
                'edit-artist.rel.0.relationship_id' => '3',
                'edit-artist.rel.0.link_type_id' => '148',
                'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'edit-artist.rel.0.period.ended' => '0',
                'edit-artist.make_votable' => '1',
            });
        } $c;

        is(@edits, 1, 'One edit was entered');
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
                ended       => 1,
                attributes  => [$additional_attribute, $crazy_guitar],
            },
            relationship_id => 3,
            new => { ended => 0 },
            old => { ended => 1 },
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
        }, 'The edit contains the right data');

        ok !exception { $edit->accept }, 'The edit could be accepted';
    };
};


test 'Removing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.relationship_id' => '1',
            'edit-artist.rel.0.removed' => '1',
            'edit-artist.rel.0.link_type_id' => '148',
        });
    } $c;

    is(@edits, 1, 'One edit was entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Delete');
};


test 'Ensure grouping-only types cannot be used for relationships' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.link_type_id' => '122',
            'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
        });
    } $c;

    is(@edits, 0, 'No edits were entered');

    like(
        $mech->uri,
        qr{/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit$},
        q(The page hasn't changed)
    );

    $mech->content_contains(
        'is only used for grouping',
        'The "grouping only" error is shown',
    );
};


test 'Ensure duplicate relationships are ignored' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    # Duplicates a relationship in admin/sql/InsertTestData.sql
    my @edits = capture_edits {
        $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.link_type_id' => '148',
            'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            'edit-artist.rel.0.attributes.0.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
        });
    } $c;

    is(@edits, 0, 'No edits were entered');
};


test 'Ensure duplicate link attribute types are ignored' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit', {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',

            # Adds a new relationship with a dupe guitar.
            'edit-artist.rel.0.link_type_id' => '148',
            'edit-artist.rel.0.attributes.0.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
            'edit-artist.rel.0.attributes.1.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
            'edit-artist.rel.0.target' => 'b1d58a57-a0f3-4db8-aa94-868cdc7bc3bb',

            # Edits an existing relationship to add a dupe guitar. Should be entirely ignored.
            'edit-artist.rel.1.relationship_id' => '1',
            'edit-artist.rel.1.link_type_id' => '148',
            'edit-artist.rel.1.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            'edit-artist.rel.1.attributes.0.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
            'edit-artist.rel.1.attributes.1.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
        });
    } $c;

    is(@edits, 1, 'One edit was entered');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Create');
    cmp_deeply(
        $edits[0]->data->{attributes},
        [$guitar_attribute],
        'The edit stores the right attributes data',
    );
};

1;
