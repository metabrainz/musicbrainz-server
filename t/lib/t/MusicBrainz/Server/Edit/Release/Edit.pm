package t::MusicBrainz::Server::Edit::Release::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Edit };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Editing releases should not remove release events' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');
    $c->sql->do(<<~'SQL');
        INSERT INTO release_unknown_country (release, date_year)
            VALUES (1, 2000);
        SQL

    my $load_release = sub { $c->model('Release')->get_by_id(1) };

    my $new_name = 'Renamed release';
    $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $load_release->(),
        name => $new_name,
    )->accept;

    my $release = $load_release->();
    $c->model('Release')->load_release_events($release);

    is($release->name, $new_name, 'Edit was applied');
    is($release->event_count, 1, 'Release still has release events');
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

# Starting point for releases
my $release = $c->model('Release')->get_by_id(1);
$c->model('ArtistCredit')->load($release);
$c->model('Release')->load_release_events($release);

is_unchanged($release);
is($release->edits_pending, 0, 'release has no pending edits');

# Test editing all possible fields
my $edit = create_edit($c, $release);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit');

my ($edits) = $c->model('Edit')->find({ release => $release->id }, 10, 0);
is($edits->[0]->id, $edit->id, 'found new edit among release edits');

$release = $c->model('Release')->get_by_id(1);
$c->model('Release')->load_release_events($release);
is($release->edits_pending, 1, 'release now has a pending edit');
is_unchanged($release);

reject_edit($c, $edit);
$release = $c->model('Release')->get_by_id(1);
$c->model('Release')->load_release_events($release);
is_unchanged($release);
is($release->edits_pending, 0, 'release has no pending edits after rejecting the edit');

# Accept the edit
$edit = create_edit($c, $release);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ArtistCredit')->load($release);
$c->model('Release')->load_release_events($release);

is($release->name, 'Edited name', 'release name is Edited name');
is($release->packaging_id, 1, 'packaging id is 1');
is($release->script_id, 3, 'script id is 3');
is($release->release_group_id, 2, 'release_group id is 2');
is($release->barcode->format, 'BARCODE', 'barcode is BARCODE');
is($release->events->[0]->country_id, 221, 'country id is 1');
is($release->events->[0]->date->year, 1985, 'year is 1985');
is($release->events->[0]->date->month, 4, 'month is 4');
is($release->events->[0]->date->day, 13, 'day is 13');
is($release->language_id, 145, 'language is 145');
is($release->comment, 'Edited comment', 'disambiguation comment is Edited comment');
is($release->artist_credit->name, 'New Artist', 'artist credit is New Artist');

};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Release')->get_by_id(1),
        name => 'Renamed release',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Release')->get_by_id(1),
        events => [{
            date => { year => '1990', month => '4', day => '29' }
        }]
    );

    is exception { $edit_1->accept }, undef, 'accepted edit 1';
    is exception { $edit_2->accept }, undef, 'accepted edit 2';

    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Release')->load_release_events($release);

    is($release->name, 'Renamed release', 'release renamed');
    is($release->events->[0]->date->format, '1990-04-29', 'date changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Release')->get_by_id(1),
        comment   => 'comment FOO',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Release')->get_by_id(1),
        comment   => 'Comment BAR',
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $release = $c->model('Release')->get_by_id(1);
    $c->model('Release')->load_release_events($release);
    is($release->comment, 'comment FOO', 'comment changed');
};

test 'A missing comment does not clear an existing one' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Release')->get_by_id(1),
        name      => 'NEW NAME!',
    );

    $edit->accept;

    my $release = $c->model('Release')->get_by_id(1);
    is($release->comment, 'hello', 'comment is left unchanged');
};

test 'MBS-13300: Release group cover art is unset if the release is moved' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO cover_art_archive.release_group_cover_art (release_group, release)
             VALUES (1, 1);

        INSERT INTO release_group (id, gid, name, artist_credit)
             VALUES (2, '550f1150-5e5b-47ee-a285-f5941c7331e9', 'RG2', 1);
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit => $c->model('Release')->get_by_id(1),
        release_group_id => 2,
    );

    $edit->accept;

    my $release_group_cover_art = $c->sql->select_single_value(<<~'SQL');
        SELECT release
          FROM cover_art_archive.release_group_cover_art
         WHERE release_group = 1
        SQL
    ok(!defined $release_group_cover_art, 'the RG cover art was unset');
};

sub is_unchanged {
    my ($release) = @_;
    is($release->packaging_id, undef, 'is_unchanged: packaging is undef');
    is($release->script_id, undef,    'is_unchanged: script is undef');
    is($release->barcode->format, '', 'is_unchanged: barcode is empty');
    is($release->all_events, 0,       'is_unchanged: has no release events');
    is($release->language_id, undef,  'is_unchanged: language is undef');
    is($release->comment, 'hello',    'is_unchanged: disambiguation comment is hello');
    is($release->release_group_id, 1, 'is_unchanged: release_group id is 1');
    is($release->name, 'Release',     'is_unchanged: release name is Release');
    is($release->artist_credit_id, 1, 'is_unchanged: artist credit is 1');
}

sub create_edit {
    my $c = shift;
    my $release = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit => $release,
        name => 'Edited name',
        comment => 'Edited comment',
        status_id => 1,
        packaging_id => 1,
        release_group_id => 2,
        barcode => 'BARCODE',
        events => [{
            date => {
                year => 1985, month => 4, day => 13
            },
            country_id => 221,
        }],
        artist_credit => {
            names => [
                {
                    artist => { id => 2, name => 'New Artist' },
                    name => 'New Artist'
                }
            ],
        },
        language_id => 145,
        script_id => 3,
    );
}

1;
