package t::MusicBrainz::Server::Controller::Series::DeleteAlias;
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

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/delete');

    $mech->submit_form(
        with_fields => {
            'confirm.edit_note' => 'remove this now!'
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::DeleteAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'Test Recording Series'
        },
        alias_id  => 1,
        name => 'Test Recording Series Alias',
        sort_name => 'Test Recording Series Alias',
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
    $mech->content_contains('Test Recording Series', '..has series name');
    $mech->content_contains('Test Recording Series Alias', '..has alias name');
};

1;
