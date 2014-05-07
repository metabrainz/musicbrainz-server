package t::MusicBrainz::Server::Controller::Series::Delete;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/delete');
    html_ok($mech->content);

    $mech->submit_form(
        with_fields => {
            'confirm.edit_note' => 'This field\'s required!',
        }
    );

    ok($mech->success);
    ok($mech->uri =~ qr{/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d}, 'should redirect to series page via gid');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Delete');

    is_deeply($edit->data, {
        name => 'Test Recording Series',
        entity_id => 1
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->content_contains('Test Recording Series', '..contains old series name');
};

1;
