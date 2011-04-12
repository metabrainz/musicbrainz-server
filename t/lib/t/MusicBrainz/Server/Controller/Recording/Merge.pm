package t::MusicBrainz::Server::Controller::Recording::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/recording/merge_queue?add-to-merge=1');
    $mech->get_ok('/recording/merge_queue?add-to-merge=2');

    $mech->get_ok('/recording/merge');
    html_ok($mech->content);
    my $response = $mech->submit_form(
        with_fields => {
            'merge.target' => '2',
        }
    );
    ok($mech->uri =~ qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8});

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Merge');
    is_deeply($edit->data, {
        old_entities => [ { name => 'Dancing Queen', id => '1' } ],
        new_entity => { name => 'King of the Mountain', id => '2' },
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');

    $mech->content_contains('Dancing Queen', '..contains old name');
    $mech->content_contains('King of the Mountain', '..contains new name');

};

1;
