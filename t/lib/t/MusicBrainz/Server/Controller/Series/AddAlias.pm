package t::MusicBrainz::Server::Controller::Series::AddAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use utf8;

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
    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/add-alias');

    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'Now that’s what I call a series',
            'edit-alias.sort_name' => 'series, Now that’s what I call a'
        });

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'Test Recording Series',
        },
        name => 'Now that’s what I call a series',
        sort_name => 'series, Now that’s what I call a',
        locale => undef,
        primary_for_locale => 0,
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
        type_id => undef,
        ended => 0
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');

    $mech->content_contains('Test Recording Series', '..contains series name');
    $mech->content_contains('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', '..contains series link');
    $mech->content_contains('Now that’s what I call a series', '..contains alias name');
    $mech->content_contains('series, Now that’s what I call a', '..contains alias sort name');

    # A sortname isn't required (MBS-6896)
    ($edit) = capture_edits {
        $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/add-alias');
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Now that’s what I call another series',
            });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::AddAlias');
    is($edit->data->{sort_name}, 'Now that’s what I call another series', 'sort_name defaults to name');
};

1;
