package t::MusicBrainz::Server::Controller::RelationshipEditor;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'MBS-5348: Displays version count in "see all versions" string' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok("/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships");
    $mech->content_contains('see all versions of this release, 1 available', '...has 1 available');
};

test 'Can add relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok("/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships");

    my ($edit) = capture_edits {
        $mech->post("/relationship-editor", {
                'rel-editor.rels.0.link_type' => '1',
                'rel-editor.rels.0.action' => 'add',
                'rel-editor.rels.0.attrs.additional' => '1',
                'rel-editor.rels.0.attrs.instrument.0' => '3',
                'rel-editor.rels.0.attrs.instrument.1' => '4',
                'rel-editor.rels.0.entity.0.gid' => '745c079d-374e-4436-9448-da92dedef3ce',
                'rel-editor.rels.0.entity.0.type' => 'artist',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.entity.1.type' => 'recording',
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

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edit->data->{entity0}{id}, 3);
    is($edit->data->{entity1}{id}, 2);
    is($edit->data->{type0}, 'artist');
    is($edit->data->{type1}, 'recording');
    is($edit->data->{link_type}{id}, 1);
    is($edit->data->{attributes}->[0], 1);
    is($edit->data->{attributes}->[1], 3);
    is($edit->data->{attributes}->[2], 4);
    is($edit->data->{begin_date}{year}, 1999);
    is($edit->data->{begin_date}{month}, 1);
    is($edit->data->{begin_date}{day}, 1);
    is($edit->data->{end_date}{year}, 1999);
    is($edit->data->{end_date}{month}, 1);
    is($edit->data->{end_date}{day}, 1);
    is($edit->data->{ended}, 1);
};

test 'Can edit relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok("/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships");

    my ($edit) = capture_edits {
        $mech->post("/relationship-editor", {
                'rel-editor.rels.0.id' => '1',
                'rel-editor.rels.0.link_type' => '1',
                'rel-editor.rels.0.action' => 'edit',
                'rel-editor.rels.0.attrs.additional' => '1',
                'rel-editor.rels.0.attrs.instrument.0' => '3',
                'rel-editor.rels.0.attrs.instrument.1' => '4',
                'rel-editor.rels.0.entity.0.gid' => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                'rel-editor.rels.0.entity.0.type' => 'artist',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.entity.1.type' => 'recording',
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
    is($edit->data->{link}{entity0}{id}, 8);
    is($edit->data->{link}{entity1}{id}, 2);
    is($edit->data->{type0}, 'artist');
    is($edit->data->{type1}, 'recording');
    is($edit->data->{link}{link_type}{id}, 1);
    is($edit->data->{new}{attributes}->[0], 1);
    is($edit->data->{new}{attributes}->[1], 3);
    is($edit->data->{new}{attributes}->[2], 4);
    is($edit->data->{new}{begin_date}{year}, 1999);
    is($edit->data->{new}{begin_date}{month}, 1);
    is($edit->data->{new}{begin_date}{day}, 1);
    is($edit->data->{new}{end_date}{year}, 2009);
    is($edit->data->{new}{end_date}{month}, 9);
    is($edit->data->{new}{end_date}{day}, 9);
    is($edit->data->{new}{ended}, 1);
};

test 'Can remove relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok("/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships");

    my ($edit) = capture_edits {
        $mech->post("/relationship-editor", {
                'rel-editor.rels.0.id' => '1',
                'rel-editor.rels.0.link_type' => '1',
                'rel-editor.rels.0.action' => 'remove',
                'rel-editor.rels.0.attrs.additional' => '1',
                'rel-editor.rels.0.attrs.instrument.0' => '3',
                'rel-editor.rels.0.attrs.instrument.1' => '4',
                'rel-editor.rels.0.entity.0.gid' => 'e2a083a9-9942-4d6e-b4d2-8397320b95f7',
                'rel-editor.rels.0.entity.0.type' => 'artist',
                'rel-editor.rels.0.entity.1.gid' => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                'rel-editor.rels.0.entity.1.type' => 'recording'
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');
};

1;
