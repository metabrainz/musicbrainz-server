package t::MusicBrainz::Server::Controller::Area::Edit;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test 'MBS-8661: Editing non-ended areas' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8661');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'area_editor', password => 'pass' });
    $mech->get_ok('/area/29a709d8-0320-493e-8d0c-f2c386662b7f/edit');
    $mech->submit_form(with_fields => { 'edit-area.name' => 'wild onion' });
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Edit');

    is_deeply($edit->data, {
        entity => { gid => '29a709d8-0320-493e-8d0c-f2c386662b7f', id => 5099, name => 'Chicago' },
        new => { name => 'wild onion' },
        old => { name => 'Chicago' },
    });
};

1;
