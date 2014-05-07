package t::MusicBrainz::Server::Controller::Series::AddAnnotation;
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

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit_annotation');
    $mech->submit_form(
        with_fields => {
            'edit-annotation.text' => 'Very short annotation',
            'edit-annotation.changelog' => 'And a changelog',
        });

    ok($mech->uri =~ qr{/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/?},
       'should redirect to series page via gid');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAnnotation');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'Test Recording Series'
        },
        text => 'Very short annotation',
        changelog => 'And a changelog',
        editor_id => 1
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    $mech->content_contains('And a changelog', '..has changelog entry');
    $mech->content_contains('Test Recording Series', '..has series name');
    $mech->content_like(qr{series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/?"}, '..has a link to the series');
    $mech->content_contains('series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/annotation/' . $edit->annotation_id,
                            '..has a link to the annotation');
};

1;
