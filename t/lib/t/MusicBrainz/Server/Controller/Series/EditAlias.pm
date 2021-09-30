package t::MusicBrainz::Server::Controller::Series::EditAlias;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

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

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/edit');

    $mech->submit_form(
        with_fields => {
            'edit-alias.name' => 'brand new alias',
            # HTML::Form doesn't understand selected=""
            # so we need to specifically set this
            'edit-alias.type_id' => '2'
        });

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::EditAlias');

    is_deeply($edit->data, {
        entity => {
            id => 1,
            name => 'Test Recording Series'
        },
        alias_id  => 1,
        new => {
            name => 'brand new alias',
            sort_name => 'brand new alias',
        },
        old => {
            name => 'Test Recording Series Alias',
            sort_name => 'Test Recording Series Alias',
        }
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->text_contains('Test Recording Series', '..has series name');
    $mech->text_contains('Test Recording Series Alias', '..has old alias name');
    $mech->text_contains('brand new alias', '..has new alias name');

    # A sortname isn't required (MBS-6896)
    ($edit) = capture_edits {
        $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/alias/1/edit');
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edit #2',
                'edit-alias.sort_name' => '',
            });
    } $c;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::EditAlias');
    is($edit->data->{new}{sort_name}, 'Edit #2', 'sort_name defaults to name');
};

1;
