package t::MusicBrainz::Server::Controller::Artist::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/artist/merge_queue?add-to-merge=4');
    $mech->get_ok('/artist/merge_queue?add-to-merge=3');

    $mech->get_ok('/artist/merge');
    html_ok($mech->content);
    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
            'merge.rename' => 0
        }
    );
    ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce});

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

    is_deeply($edit->data, {
        old_entities => [ { name => 'Empty Artist', id => 4, } ],
        new_entity => { name => 'Test Artist', id => 3, },
        rename => 0
    });
};

1;
