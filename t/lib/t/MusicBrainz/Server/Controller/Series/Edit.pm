package t::MusicBrainz::Server::Controller::Series::Edit;
use Test::Routine;
use Test::More;
use Test::Deep;
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
    $mech->submit_form(with_fields => { username => 'editor', password => 'pass' });

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit');
    html_ok($mech->content);

    $mech->submit_form(
        with_fields => {
            'edit-series.name' => 'New Name!',
            'edit-series.comment' => 'new comment!',
            'edit-series.ordering_type_id' => 2,
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Edit');

    cmp_deeply($edit->data, {
        entity => {
            id => 1,
            gid => re("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"),
            name => 'Test Recording Series'
        },
        new => {
            name => 'New Name!',
            comment => 'new comment!',
            ordering_type_id => 2,

        },
        old => {
            name => 'Test Recording Series',
            comment => 'test comment 1',
            ordering_type_id => 1,
        }
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
    html_ok($mech->content, '..valid xml');
    $mech->text_contains('New Name!', '..has new name');
    $mech->text_contains('Test Recording Series', '..has old name');
    $mech->text_contains('Automatic', '..has new ordering type');
    $mech->text_contains('Manual', '..has old ordering type');
};

1;
