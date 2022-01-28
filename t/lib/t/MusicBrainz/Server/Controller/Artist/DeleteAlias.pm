package t::MusicBrainz::Server::Controller::Artist::DeleteAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that artist alias deletion works.

=cut

test 'Test alias deletion' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist',
    );

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/alias/1/delete');
    $mech->submit_form_ok({
            with_fields => {
                'confirm.edit_note' => q(Some edit note since it's required)
            }
        },
        'The form returned a 2xx response code',
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::DeleteAlias');
    is_deeply(
        $edit->data,
        {
            entity    => {
                id => 3,
                name => 'Test Artist'
            },
            alias_id  => 1,
            name      => 'Test Alias',
            sort_name => 'Test Alias',
            primary_for_locale => 0,
            locale => undef,
            begin_date => {
                year => 2000,
                month => 1,
                day => 1
            },
            end_date => {
                year => 2005,
                month => 5,
                day => 6
            },
            ended => 1,
            type_id => undef
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Test Artist',
        'The edit page contains the artist name',
    );
    $mech->content_contains(
        'Test Alias',
        'The edit page contains the alias name',
    );
};

1;
