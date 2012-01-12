package t::MusicBrainz::Server::Edit::Artist::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

# Test creating the edit
my $artist = $c->model('Artist')->get_by_id(1);
my $edit = _create_full_edit($c, $artist);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => $artist->id }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

$artist = $c->model('Artist')->get_by_id(1);
is_unchanged($artist);
is($artist->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);

$artist = $c->model('Artist')->get_by_id(1);
is_unchanged($artist);
is($artist->edits_pending, 0);

# Test accepting the edit
$artist = $c->model('Artist')->get_by_id(1);
$edit = _create_full_edit($c, $artist);

accept_edit($c, $edit);

$artist = $c->model('Artist')->get_by_id(1);
is($artist->name, 'New Name');
is($artist->sort_name, 'New Sort');
is($artist->comment, 'New comment');
is($artist->type_id, 1);
is($artist->country_id, 1);
is($artist->gender_id, 1);
is($artist->begin_date->year, 1990);
is($artist->begin_date->month, 5);
is($artist->begin_date->day, 10);
is($artist->end_date->year, 2000);
is($artist->end_date->month, 3);
is($artist->end_date->day, 20);

# load the edit and test if it provides a populated ->display_data
$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);

is($edit->display_data->{name}->{old}, 'Artist Name');
is($edit->display_data->{name}->{new}, 'New Name');
is($edit->display_data->{sort_name}->{old}, 'Artist Name');
is($edit->display_data->{sort_name}->{new}, 'New Sort');
is($edit->display_data->{type}->{old}, undef);
is($edit->display_data->{type}->{new}->name, 'Group');
is($edit->display_data->{gender}->{old}, undef);
is($edit->display_data->{gender}->{new}->{name}, 'Male');
is($edit->display_data->{country}->{old}, undef);
is($edit->display_data->{country}->{new}->{name}, 'United Kingdom');
is($edit->display_data->{comment}->{old}, undef);
is($edit->display_data->{comment}->{new}, 'New comment');
is($edit->display_data->{begin_date}->{old}->format, '');
is($edit->display_data->{begin_date}->{new}->format, '1990-05-10');
is($edit->display_data->{end_date}->{old}->format, '');
is($edit->display_data->{end_date}->{new}->format, '2000-03-20');


# Make sure we can use NULL values where possible
$edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_EDIT,
    editor_id => 1,
    to_edit => $artist,

    comment => undef,
    type_id => undef,
    gender_id => undef,
    country_id => undef,
    begin_date => { year => undef, month => undef, day => undef },
    end_date => { year => undef, month => undef, day => undef },
);

accept_edit($c, $edit);
$artist = $c->model('Artist')->get_by_id(1);
is($artist->country_id, undef);
is($artist->gender_id, undef);
is($artist->type_id, undef);
ok($artist->begin_date->is_empty);
ok($artist->end_date->is_empty);

# Test loading entities for the edit
$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);

};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(1),
        name => 'Renamed artist',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(1),
        comment   => 'Comment change'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $artist = $c->model('Artist')->get_by_id(1);
    is ($artist->name, 'Renamed artist', 'artist renamed');
    is ($artist->comment, 'Comment change', 'comment changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(1),
        name      => 'Renamed artist',
        sort_name => 'Sort FOO'
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(1),
        comment   => 'Comment change',
        sort_name => 'Sort BAR'
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $artist = $c->model('Artist')->get_by_id(1);
    is ($artist->name, 'Renamed artist', 'artist renamed');
    is ($artist->sort_name, 'Sort FOO', 'comment changed');
    is ($artist->comment, undef);
};

sub _create_full_edit {
    my ($c, $artist) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $artist,

        name => 'New Name',
        sort_name => 'New Sort',
        comment => 'New comment',
        begin_date => { year => 1990, month => 5, day => 10 },
        end_date => { year => 2000, month => 3, day => 20 },
        type_id => 1,
        gender_id => 1,
        country_id => 1,
    );
}

sub is_unchanged {
    my $artist = shift;
    is($artist->name, 'Artist Name');
    is($artist->sort_name, 'Artist Name');
    is($artist->$_, undef) for qw( type_id country_id gender_id comment );
    ok($artist->begin_date->is_empty);
    ok($artist->end_date->is_empty);
}

1;
