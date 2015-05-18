package t::MusicBrainz::Server::Controller::Recording::DeleteAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

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

    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/alias/1/delete');

    $mech->submit_form(
        with_fields => {
            'confirm.edit_note' => 'remove this now!'
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::DeleteAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'King of the Mountain'
        },
        alias_id  => 1,
        name => 'Test Recording Alias',
        sort_name => 'Test Recording Alias',
        begin_date => {
            year => undef,
            month => undef,
            day => undef
        },
        end_date => {
            year => undef,
            month => undef,
            day => undef
        },
        type_id => 2,
        locale => undef,
        primary_for_locale => 0
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->content_contains('King of the Mountain', '..has recording name');
    $mech->content_contains('Test Recording Alias', '..has alias name');
};

1;
