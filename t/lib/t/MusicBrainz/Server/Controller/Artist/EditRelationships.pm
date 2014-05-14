package t::MusicBrainz::Server::Controller::Artist::EditRelationships;
use utf8;
use Test::Deep qw( cmp_deeply bag );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'adding a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post("/artist/745c079d-374e-4436-9448-da92dedef3ce/edit", {
            'edit-artist.name' => 'Test Artist',
            'edit-artist.sort_name' => 'Artist, Test',
            'edit-artist.type_id' => '1',
            'edit-artist.gender_id' => '1',
            'edit-artist.period.ended' => '1',
            'edit-artist.rel.0.link_type_id' => '1',
            'edit-artist.rel.0.attributes.0' => '1',
            'edit-artist.rel.0.attributes.1' => '3',
            'edit-artist.rel.0.attributes.2' => '4',
            'edit-artist.rel.0.target' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
            'edit-artist.rel.0.period.begin_date.year' => '1999',
            'edit-artist.rel.0.period.begin_date.month' => '1',
            'edit-artist.rel.0.period.begin_date.day' => '1',
            'edit-artist.rel.0.period.end_date.year' => '1999',
            'edit-artist.rel.0.period.end_date.month' => '2',
            'edit-artist.rel.0.period.end_date.day' => undef,
        });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply($edit->data,  {
        type1       => 'recording',
        type0       => 'artist',
        link_type   => {
            id                  => 1,
            name                => 'instrument',
            link_phrase         => 'performed {additional} {instrument} on',
            long_link_phrase    => 'performer',
            reverse_link_phrase => 'has {additional} {instrument} performed by',
        },
        entity1     => { id => 2, name => 'King of the Mountain' },
        entity0     => { id => 3, name => 'Test Artist' },
        begin_date  => { year => 1999, month => 1, day => 1 },
        end_date    => { year => 1999, month => 2, day => undef },
        ended       => 0,
        attributes  => bag(1, 3, 4),
    });
};


test 'editing a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit) = capture_edits {
        $mech->post("/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/edit", {
            'edit-artist.name' => 'Test Alias',
            'edit-artist.sort_name' => 'Kate Bush',
            'edit-artist.rel.0.relationship_id' => '3',
            'edit-artist.rel.0.link_type_id' => '1',
            'edit-artist.rel.0.attributes.0' => '1',
            'edit-artist.rel.0.attributes.1' => '3',
            'edit-artist.rel.0.attributes.2' => '4',
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
            attributes  => bag(3, 1),
            attribute_text_values => {},
        },
        relationship_id => 3,
        new => {
            entity1     => { id => 2, name => 'King of the Mountain' },
            begin_date  => { month => 1, day => 1, year => 1999 },
            end_date    => { month => 9, day => 9, year => 2009 },
            ended       => 1,
            attributes  => bag(1, 3, 4),
        },
        old => {
            entity1     => { id => 3, name => 'π' },
            begin_date  => { month => undef, day => undef, year => undef },
            end_date    => { month => undef, day => undef, year => undef },
            ended       => 0,
            attributes  => bag(3, 1),
        },
    });
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
