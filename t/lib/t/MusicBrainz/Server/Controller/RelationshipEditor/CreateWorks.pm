package t::MusicBrainz::Server::Controller::RelationshipEditor::CreateWorks;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Can create works' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my ($edit1, $edit2) = capture_edits {
        $mech->post("/relationship-editor/create-works", {
                'create-works.works.0.type_id' => '1',
                'create-works.works.0.language_id' => '1',
                'create-works.works.0.name' => 'Foo',
                'create-works.works.0.comment' => '123',
                'create-works.works.1.type_id' => '2',
                'create-works.works.1.language_id' => '2',
                'create-works.works.1.name' => 'Bar',
                'create-works.works.1.comment' => '456',
            }
        );
    } $c;

    if ($edit1->id > $edit2->id) {
        ($edit1, $edit2) = ($edit2, $edit1);
    }

    ok(defined $edit1);
    isa_ok($edit1, 'MusicBrainz::Server::Edit::Work::Create');
    is($edit1->data->{name}, 'Foo');
    is($edit1->data->{comment}, '123');
    is($edit1->data->{type_id}, 1);
    is($edit1->data->{language_id}, 1);

    ok(defined $edit2);
    isa_ok($edit2, 'MusicBrainz::Server::Edit::Work::Create');
    is($edit2->data->{name}, 'Bar');
    is($edit2->data->{comment}, '456');
    is($edit2->data->{type_id}, 2);
    is($edit2->data->{language_id}, 2);
};

1;
