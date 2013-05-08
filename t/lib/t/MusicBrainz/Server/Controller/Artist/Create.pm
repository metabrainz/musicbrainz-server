package t::MusicBrainz::Server::Controller::Artist::Create;
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

# Test creating new artists via the create artist form
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

subtest 'Create artists with all fields' => sub {
    $mech->get_ok('/artist/create');
    html_ok($mech->content);
    my $response = $mech->submit_form(
        with_fields => {
            'edit-artist.name' => 'controller artist',
            'edit-artist.sort_name' => 'artist, controller',
            'edit-artist.type_id' => 1,
            'edit-artist.area_id' => 222,
            'edit-artist.gender_id' => 2,
            'edit-artist.period.begin_date.year' => 1990,
            'edit-artist.period.begin_date.month' => 01,
            'edit-artist.period.begin_date.day' => 02,
            'edit-artist.begin_area_id' => 222,
            'edit-artist.period.end_date.year' => 2003,
            'edit-artist.period.end_date.month' => 4,
            'edit-artist.period.end_date.day' => 15,
            'edit-artist.end_area_id' => 222,
            'edit-artist.comment' => 'artist created in controller_artist.t',
        }
    );
    ok($mech->success);
    ok($mech->uri =~ qr{/artist/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})}, 'should redirect to artist page via gid');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
    is_deeply($edit->data, {
        name => 'controller artist',
        sort_name => 'artist, controller',
        type_id => 1,
        area_id => 222,
        gender_id => 2,
        comment => 'artist created in controller_artist.t',
        begin_date => {
            year => 1990,
            month => 01,
            day => 02
        },
        begin_area_id => 222,
        end_date => {
            year => 2003,
            month => 4,
            day => 15
        },
        end_area_id => 222,
        ended => 1,
        ipi_codes => [],
        isni_codes => [],
    });


    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
    html_ok ($mech->content, '..xml is valid');
    $mech->content_contains ('controller artist', '.. contains artist name');
    $mech->content_contains ('artist, controller', '.. contains sort name');
    $mech->content_contains ('Person', '.. contains artist type');
    $mech->content_contains ('United States', '.. contains area');
    $mech->content_contains ('Female', '.. contains artist gender');
    $mech->content_contains ('artist created in controller_artist.t',
                             '.. contains artist comment');
    $mech->content_contains ('1990-01-02', '.. contains begin date');
    $mech->content_contains ('2003-04-15', '.. contains end date');

    # Cleaning up.
    _delete_artist ($c, $edit->entity_id);

    done_testing;
};

subtest 'Creating artists with only the minimal amount of fields' => sub {
    $mech->get_ok('/artist/create');
    html_ok($mech->content);
    my $response = $mech->submit_form(
        with_fields => {
            'edit-artist.name' => 'Alice Artist',
            'edit-artist.sort_name' => 'Artist, Alice',
            'edit-artist.type_id' => '',
            'edit-artist.area_id' => '',
            'edit-artist.gender_id' => '',
            'edit-artist.period.begin_date.year' => '',
            'edit-artist.period.begin_date.month' => '',
            'edit-artist.period.begin_date.day' => '',
            'edit-artist.end_area_id' => '',
            'edit-artist.period.end_date.year' => '',
            'edit-artist.period.end_date.month' => '',
            'edit-artist.period.end_date.day' => '',
            'edit-artist.begin_area_id' => '',
            'edit-artist.comment' => '',
        }
    );
    ok($mech->success);
    ok($mech->uri =~ qr{/artist/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})}, 'should redirect to artist page via gid');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');

    is($edit->data->{name}, 'Alice Artist');
    is($edit->data->{sort_name}, 'Artist, Alice');
    is($edit->data->{type_id}, undef);
    is($edit->data->{area_id}, undef);
    is($edit->data->{begin_area_id}, undef);
    is($edit->data->{end_area_id}, undef);
    is($edit->data->{gender_id}, undef);
    is($edit->data->{comment}, '');

    ok( PartialDate->new($edit->data->{begin_date})->is_empty );
    ok( PartialDate->new($edit->data->{end_date})->is_empty );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
    html_ok ($mech->content, '..xml is valid');
    $mech->content_contains ('Alice Artist', '.. contains artist name');
    $mech->content_contains ('Artist, Alice', '.. contains sort name');

    # Cleaning up.
    _delete_artist ($c, $edit->entity_id);

    done_testing;
};

};

sub _delete_artist
{
    my $c = shift;
    $c->sql->do('DELETE FROM artist WHERE id IN (?)', @_);
}

1;
