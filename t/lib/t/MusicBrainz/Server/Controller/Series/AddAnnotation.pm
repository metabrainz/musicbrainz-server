package t::MusicBrainz::Server::Controller::Series::AddAnnotation;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit_annotation');
    $mech->submit_form(
        with_fields => {
            'edit-annotation.text' => "    * Test annotation for a series  \r\n    * This annotation has two bullets  \t\t",
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
        text => "    * Test annotation for a series\n    * This annotation has two bullets",
        changelog => 'And a changelog',
        editor_id => 1
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    $mech->content_contains('And a changelog', '..has changelog entry');
    $mech->content_contains('Test Recording Series', '..has series name');
    $mech->content_like(qr{series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/?"}, '..has a link to the series');
};

1;
