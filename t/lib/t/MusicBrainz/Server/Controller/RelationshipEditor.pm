package t::MusicBrainz::Server::Controller::RelationshipEditor;
use strict;
use warnings;

require Exporter;
our @ISA = qw( Exporter );

our @EXPORT_OK = qw(
    $additional_attribute
    $string_instruments_attribute
    $guitar_attribute
    $crazy_guitar
);

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply );
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

our $additional_attribute = {
    type => {
        root => {
            id => 1,
            gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
            name => 'additional',
        },
        id => 1,
        gid => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
        name => 'additional',
    }
};

our $string_instruments_attribute = {
    type => {
        root => {
            id => 14,
            gid => '0abd7f04-5e28-425b-956f-94789d9bcbe2',
            name => 'instrument',
        },
        id => 302,
        gid => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
        name => 'plucked string instruments',
    }
};

our $guitar_attribute = {
    type => {
        root => {
            id => 14,
            gid => '0abd7f04-5e28-425b-956f-94789d9bcbe2',
            name => 'instrument',
        },
        id => 229,
        gid => '63021302-86cd-4aee-80df-2270d54f4978',
        name => 'guitar',
    }
};

our $crazy_guitar = {
    %$guitar_attribute,
    credited_as => 'crazy guitar',
};

test 'Can add relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.attributes.0.type.gid' => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                'rel-editor.rels.0.attributes.1.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
                'rel-editor.rels.0.attributes.2.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
                'rel-editor.rels.0.attributes.2.credited_as' => 'crazy guitar',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.period.begin_date.year' => '1999',
                'rel-editor.rels.0.period.begin_date.month' => '1',
                'rel-editor.rels.0.period.begin_date.day' => '1',
                'rel-editor.rels.0.period.end_date.year' => '1999',
                'rel-editor.rels.0.period.end_date.month' => '1',
                'rel-editor.rels.0.period.end_date.day' => '1',
                'rel-editor.rels.0.period.ended' => '1',
            }
        );
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
        end_date        => { year => 1999, month => 1, day => 1 },
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

test 'Can edit relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.id' => '1',
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'edit',
                'rel-editor.rels.0.attributes.0.type.gid' => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                'rel-editor.rels.0.attributes.1.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
                'rel-editor.rels.0.attributes.2.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
                'rel-editor.rels.0.attributes.2.credited_as' => 'crazy guitar',
                'rel-editor.rels.0.entity.0.gid' => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.period.begin_date.year' => '1999',
                'rel-editor.rels.0.period.begin_date.month' => '1',
                'rel-editor.rels.0.period.begin_date.day' => '1',
                'rel-editor.rels.0.period.end_date.year' => '2009',
                'rel-editor.rels.0.period.end_date.month' => '9',
                'rel-editor.rels.0.period.end_date.day' => '9',
                'rel-editor.rels.0.period.ended' => '1',
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply($edit->data, {
        edit_version => 2,
        link => {
            attributes => [$guitar_attribute],
            begin_date => { year => undef, day => undef, month => undef },
            end_date => { month => undef, day => undef, year => undef },
            ended => 0,
            entity0 => {
                gid => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                id => 8,
                name => 'Test Alias'
            },
            entity1 => {
                gid => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                id => 2,
                name => 'King of the Mountain'
            },
            link_type => {
                id => 148,
                link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
                long_link_phrase => 'performed {additional} {guest} {solo} {instrument:%|instruments} on',
                name => 'instrument',
                reverse_link_phrase => '{additional} {guest} {solo} {instrument:%|instruments}',
            },
        },
        new => {
            attributes => [$additional_attribute, $crazy_guitar, $string_instruments_attribute],
            begin_date => { month => 1, day => 1, year => 1999 },
            end_date => { month => 9, day => 9, year => 2009 },
            ended => 1,
        },
        old => {
            ended => '0',
            begin_date => { day => undef, year => undef, month => undef },
            attributes => [$guitar_attribute],
            end_date => { month => undef, day => undef, year => undef },
        },
        relationship_id => 1,
        type0 => 'artist',
        type1 => 'recording',
        entity0_credit => '',
        entity1_credit => '',
    });
};

test 'Can remove relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships');

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.id' => '1',
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'remove',
                'rel-editor.rels.0.attributes.0.type.gid' => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                'rel-editor.rels.0.attributes.1.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
                'rel-editor.rels.0.attributes.2.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
                'rel-editor.rels.0.entity.0.gid' => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');
};


test 'MBS-7058: Can submit a relationship without "ended" fields' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edit->data->{entity0}{id}, 3);
    is($edit->data->{entity1}{id}, 2);
    is($edit->data->{type0}, 'artist');
    is($edit->data->{type1}, 'recording');
    is($edit->data->{link_type}{id}, 148);
    is($edit->data->{ended}, 0);
};


test 'Can submit a relationship with empty-string date values' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.period.begin_date.year' => '',
                'rel-editor.rels.0.period.begin_date.month' => '',
                'rel-editor.rels.0.period.begin_date.day' => '',
            }
        );
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
};


test 'mismatched link types are rejected' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                # artist-release concertmaster
                'rel-editor.rels.0.link_type' => '759',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            }
        );
    } $c;

    ok(!defined $edit);
};


test 'Can submit URL relationships using actual URLs, not gids' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.link_type' => '183',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.1.url' => 'http://musicbrainz.org/',
                'rel-editor.rels.1.link_type' => '183',
                'rel-editor.rels.1.action' => 'add',
                'rel-editor.rels.1.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.1.entity.1.url' => 'http://link.example/',
            }
        );
    } $c;

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edits[0]->data->{entity0}{id}, 3);
    is($edits[0]->data->{entity1}{id}, 1);
    is($edits[0]->data->{type0}, 'artist');
    is($edits[0]->data->{type1}, 'url');
    is($edits[0]->data->{link_type}{id}, 183);

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edits[1]->data->{entity0}{id}, 3);
    is($edits[1]->data->{entity1}{id}, 2);
    is($edits[1]->data->{type0}, 'artist');
    is($edits[1]->data->{type1}, 'url');
    is($edits[1]->data->{link_type}{id}, 183);
};

test 'Can clear all attributes from a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post('/relationship-editor', {
                'rel-editor.rels.0.id' => '1',
                'rel-editor.rels.0.link_type' => '148',
                'rel-editor.rels.0.action' => 'edit',
                'rel-editor.rels.0.attributes.0.type.gid' => '0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f',
                'rel-editor.rels.0.attributes.0.removed' => '1',
                'rel-editor.rels.0.attributes.1.type.gid' => 'b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea',
                'rel-editor.rels.0.attributes.1.removed' => '1',
                'rel-editor.rels.0.attributes.2.type.gid' => '63021302-86cd-4aee-80df-2270d54f4978',
                'rel-editor.rels.0.attributes.2.removed' => '1',
                'rel-editor.rels.0.entity.0.gid' => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                'rel-editor.rels.0.entity.0.type' => 'artist',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.entity.1.type' => 'recording',
            }
        );
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');
    cmp_deeply($edit->data->{new}{attributes}, []);
};

1;
