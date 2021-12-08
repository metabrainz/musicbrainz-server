package t::MusicBrainz::Server::Controller::Recording::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use utf8;

with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($c, '+recording');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'password' } );
    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/add-alias');

    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'Now that’s what I call a recording',
            'edit-alias.sort_name' => 'recording, Now that’s what I call a'
        });

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'King of the Mountain',
        },
        name => 'Now that’s what I call a recording',
        sort_name => 'recording, Now that’s what I call a',
        locale => undef,
        primary_for_locale => 0,
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
        type_id => undef,
        ended => 0
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');

    $mech->content_contains('King of the Mountain', '..contains recording name');
    $mech->content_contains('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', '..contains recording link');
    $mech->content_contains('Now that’s what I call a recording', '..contains alias name');
    $mech->content_contains('recording, Now that’s what I call a', '..contains alias sort name');

    # A sortname isn't required (MBS-6896)
    ($edit) = capture_edits {
        $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/add-alias');
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call another recording',
            });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddAlias');
    is($edit->data->{sort_name}, 'Now that’s what I call another recording', 'sort_name defaults to name');
};

1;
