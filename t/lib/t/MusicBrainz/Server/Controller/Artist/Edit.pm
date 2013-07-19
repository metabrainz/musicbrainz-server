package t::MusicBrainz::Server::Controller::Artist::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

use List::UtilsBy qw( sort_by );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'edit artist',
        'edit-artist.sort_name' => 'artist, controller',
        'edit-artist.type_id' => '',
        'edit-artist.area_id' => 222,
        'edit-artist.gender_id' => 2,
        'edit-artist.period.begin_date.year' => 1990,
        'edit-artist.period.begin_date.month' => 01,
        'edit-artist.period.begin_date.day' => 02,
        'edit-artist.begin_area_id' => 222,
        'edit-artist.period.end_date.year' => '',
        'edit-artist.period.end_date.month' => '',
        'edit-artist.period.end_date.day' => '',
        'edit-artist.end_area_id' => 222,
        'edit-artist.comment' => 'artist created in controller_artist.t',
        'edit-artist.rename_artist_credit' => undef
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce$}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');
is_deeply($edit->data, {
        entity => {
            id => 3,
            name => 'Test Artist'
        },
        new => {
            name => 'edit artist',
            sort_name => 'artist, controller',
            type_id => undef,
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
                year => undef,
                month => undef,
                day => undef,
            },
            end_area_id => 222,
        },
        old => {
            name => 'Test Artist',
            sort_name => 'Artist, Test',
            type_id => 1,
            gender_id => 1,
            area_id => 221,
            comment => 'Yet Another Test Artist',
            begin_date => {
                year => 2008,
                month => 1,
                day => 2
            },
            begin_area_id => 221,
            end_date => {
                year => 2009,
                month => 3,
                day => 4
            },
            end_area_id => 221,
        }
    });


# Test display of edit data
$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok ($mech->content, '..xml is valid');
$mech->text_contains ('edit artist', '.. contains old artist name');
$mech->text_contains ('Test Artist', '.. contains new artist name');
$mech->text_contains ('artist, controller', '.. contains old sort name');
$mech->text_contains ('Artist, Test', '.. contains new sort name');
$mech->text_contains ('Person', '.. contains new artist type');
$mech->text_contains ('United States', '.. contains old area');
$mech->text_contains ('United Kingdom', '.. contains new area');
$mech->text_contains ('Male', '.. contains old artist gender');
$mech->text_contains ('Female', '.. contains new artist gender');
$mech->text_contains ('2008-01-02', '.. contains old begin date');
$mech->text_contains ('1990-01-02', '.. contains new begin date');
$mech->text_contains ('2009-03-04', '.. contains old end date');
$mech->text_contains ('Yet Another Test Artist',
                      '.. contains old artist comment');
$mech->text_contains ('artist created in controller_artist.t',
                      '.. contains new artist comment');

};

test 'Check duplicates' => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);
$mech->submit_form_ok({
    with_fields => {
        'edit-artist.name' => 'test artist',
        'edit-artist.sort_name' => 'artist, test',
        'edit-artist.rename_artist_credit' => undef
    }
});
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce$}, 'should redirect to artist page via gid');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);
$mech->submit_form_ok({
    with_fields => {
        'edit-artist.name' => 'Empty Artist',
        'edit-artist.sort_name' => 'Empty Artist',
        'edit-artist.rename_artist_credit' => undef
    }
});
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/edit$}, 'still on the edit page');
$mech->content_contains('Possible Duplicate Artists', 'warning about duplicate artists');

};

test 'Looooooong comment' => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test editing artists
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
html_ok($mech->content);
$mech->submit_form_ok({
    with_fields => {
        'edit-artist.name' => 'test artist',
        'edit-artist.comment' => 'comment ' x 100,
        'edit-artist.sort_name' => 'artist, test',
        'edit-artist.rename_artist_credit' => undef
    }
});
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/edit$}, 'still on the edit page');
$mech->content_contains('Field should not exceed 255 characters', 'warning about the long comment');

};

test 'Test updating artist credits' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, email_confirm_date, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
INSERT INTO editor (id, name, password, ha1)
  VALUES ( 4, 'ModBot', '', '' );
INSERT INTO artist_name (id, name) VALUES (1, 'Artist name'), (2, 'Alternative Name');
INSERT INTO artist (id, gid, name, sort_name) VALUES (10, '9f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 1, 1);

INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 2);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
  VALUES (1, 10, 2, 1, '');
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->get_ok('/artist/9f0b3e1a-2431-400f-b6ff-2bcebbf0971a/edit');
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'test artist',
                'edit-artist.rename_artist_credit' => [ 1 ]
            }
        });
    } $c;

    @edits = sort_by { $_->id } @edits;

    is(@edits, 2, 'created 2 edits');
    my ($edit_artist, $edit_ac) = @edits;
    isa_ok($edit_artist, 'MusicBrainz::Server::Edit::Artist::Edit', 'created an artist edit');
    isa_ok($edit_ac, 'MusicBrainz::Server::Edit::Artist::EditArtistCredit', 'edited an artist credit');

    is_deeply($edit_ac->data->{new}{artist_credit}, {
        names => [{
            artist => {
                name => 'Artist name',
                id => 10,
            },
            name => 'test artist',
            join_phrase => ''
        }]
    });

    is_deeply($edit_ac->data->{old}{artist_credit}, {
        names => [{
            artist => {
                name => 'Artist name',
                id => 10,
            },
            name => 'Alternative Name',
            join_phrase => ''
        }]
    });
};

1;
