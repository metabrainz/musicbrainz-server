package t::MusicBrainz::Server::Controller::Recording::EditAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($c, '+recording');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'password' } );

    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/alias/1/edit');

    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'brand new alias',
            # HTML::Form doesn't understand selected=""
            # so we need to specifically set this
            'edit-alias.type_id' => '2'
        });

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::EditAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'King of the Mountain',
        },
        alias_id  => 1,
        new => {
            name => 'brand new alias',
            sort_name => 'brand new alias',
        },
        old => {
            name => 'Test Recording Alias',
            sort_name => 'Test Recording Alias',
        }
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->text_contains('King of the Mountain', '..has recording name');
    $mech->text_contains('Test Recording Alias', '..has old alias name');
    $mech->text_contains('brand new alias', '..has new alias name');

    # A sortname isn't required (MBS-6896)
    ($edit) = capture_edits {
        $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/alias/1/edit');
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edit #2',
                'edit-alias.sort_name' => '',
            });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::EditAlias');
    is($edit->data->{new}{sort_name}, 'Edit #2', 'sort_name defaults to name');
};

1;
