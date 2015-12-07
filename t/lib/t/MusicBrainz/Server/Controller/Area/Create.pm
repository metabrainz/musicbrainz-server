package t::MusicBrainz::Server::Controller::Area::Create;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test 'MBS-8661: Adding non-ended areas' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8661');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'area_editor', password => 'pass' });
    $mech->get_ok('/area/create');
    $mech->submit_form(with_fields => { 'edit-area.name' => 'New Area' });
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Create');

    is_deeply($edit->data, {
        begin_date => { year => undef, month => undef, day => undef },
        comment => '',
        end_date => { day => undef, month => undef, year => undef },
        ended => 0,
        iso_3166_1 => [],
        iso_3166_2 => [],
        iso_3166_3 => [],
        name => 'New Area',
        type_id => undef,
    });
};

1;
