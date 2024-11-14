package t::MusicBrainz::Server::Edit::Artist::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT $UNTRUSTED_FLAG );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

# Test creating the edit
my $artist = $c->model('Artist')->get_by_id(2);
my $edit = _create_full_edit($c, $artist);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => $artist->id }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

$artist = $c->model('Artist')->get_by_id(2);
is_unchanged($artist);
is($artist->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);

$artist = $c->model('Artist')->get_by_id(2);
is_unchanged($artist);
is($artist->edits_pending, 0);

# Test accepting the edit
$artist = $c->model('Artist')->get_by_id(2);
$edit = _create_full_edit($c, $artist);

accept_edit($c, $edit);

$artist = $c->model('Artist')->get_by_id(2);
is($artist->name, 'New Name');
is($artist->sort_name, 'New Sort');
is($artist->comment, 'New comment');
is($artist->type_id, 1);
is($artist->area_id, 221);
is($artist->gender_id, 1);
is($artist->begin_date->year, 1990);
is($artist->begin_date->month, 5);
is($artist->begin_date->day, 10);
is($artist->end_date->year, 2000);
is($artist->end_date->month, 3);
is($artist->end_date->day, 20);

my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id($artist->id);
is(scalar @$ipi_codes, 2, 'Artist has two ipi codes after accepting edit');
isa_ok($ipi_codes->[0], 'MusicBrainz::Server::Entity::ArtistIPI');
isa_ok($ipi_codes->[1], 'MusicBrainz::Server::Entity::ArtistIPI');

my $isni_codes = $c->model('Artist')->isni->find_by_entity_id($artist->id);
is(scalar @$isni_codes, 2, 'Artist has two isni codes after accepting edit');
isa_ok($isni_codes->[0], 'MusicBrainz::Server::Entity::ArtistISNI');
isa_ok($isni_codes->[1], 'MusicBrainz::Server::Entity::ArtistISNI');

# load the edit and test if it provides a populated ->display_data
$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);

is($edit->display_data->{name}->{old}, 'Artist Name');
is($edit->display_data->{name}->{new}, 'New Name');
is($edit->display_data->{sort_name}->{old}, 'Artist Name');
is($edit->display_data->{sort_name}->{new}, 'New Sort');
is($edit->display_data->{type}->{old}, undef);
is($edit->display_data->{type}->{new}->{name}, 'Person');
is($edit->display_data->{gender}->{old}, undef);
is($edit->display_data->{gender}->{new}->{name}, 'Male');
is($edit->display_data->{area}->{old}, undef);
is($edit->display_data->{area}->{new}->{name}, 'United Kingdom');
is($edit->display_data->{comment}->{old}, 'UK group');
is($edit->display_data->{comment}->{new}, 'New comment');
is($edit->display_data->{begin_date}->{old}->{year}, undef);
is($edit->display_data->{begin_date}->{new}->{year}, 1990);
is($edit->display_data->{end_date}->{old}->{year}, undef);
is($edit->display_data->{end_date}->{new}->{year}, 2000);
cmp_set($edit->display_data->{ipi_codes}->{old}, []);
cmp_set($edit->display_data->{ipi_codes}->{new}, [ '00145958831', '00151894163' ]);
cmp_set($edit->display_data->{isni_codes}->{old}, []);
cmp_set($edit->display_data->{isni_codes}->{new}, [ '0000000106750994', '0000000106750995' ]);

# Make sure we can use NULL values where possible
$edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_EDIT,
    editor_id => 1,
    to_edit => $artist,

    type_id => undef,
    gender_id => undef,
    area_id => undef,
    begin_date => { year => undef, month => undef, day => undef },
    end_date => { year => undef, month => undef, day => undef },
    ipi_codes => [],
    isni_codes => [],
);

accept_edit($c, $edit);
$artist = $c->model('Artist')->get_by_id(2);
is($artist->area_id, undef);
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
        to_edit   => $c->model('Artist')->get_by_id(2),
        name => 'Renamed artist',
        ipi_codes => [],
        isni_codes => [],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        comment   => 'Comment change',
        ipi_codes => [],
        isni_codes => [],
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $artist = $c->model('Artist')->get_by_id(2);
    is($artist->name, 'Renamed artist', 'artist renamed');
    is($artist->comment, 'Comment change', 'comment changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        name      => 'Renamed artist',
        sort_name => 'Sort FOO',
        ipi_codes => [],
        isni_codes => [],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        comment   => 'Comment change',
        sort_name => 'Sort BAR',
        ipi_codes => [],
        isni_codes => [],
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $artist = $c->model('Artist')->get_by_id(2);
    is($artist->name, 'Renamed artist', 'artist renamed');
    is($artist->sort_name, 'Sort FOO', 'sort name changed');
    is($artist->comment, 'UK group', 'comment unchanged');
};

test 'Check IPI changes' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');
    my $ipi_codes;

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        isni_codes => [],
        ipi_codes => [ '11111111111', '22222222222',
                       '33333333333', '44444444444' ],
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id(2);
    cmp_set( [ map { $_->ipi } @$ipi_codes ],
        [ '11111111111', '22222222222', '33333333333', '44444444444' ]);

    # remove two IPI codes, add two others
    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        isni_codes => [],
        ipi_codes => [ '11111111111', '33333333333',
                       '55555555555', '66666666666' ],
    );

    # remove two IPI codes (one of them already being removed in edit 2),
    # add two (again, one of them already being added in edit 2)
    my $edit_3 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        isni_codes => [],
        ipi_codes => [ '11111111111', '22222222222',
                       '55555555555', '77777777777' ],
    );
    # this checks all seven cases (before/edit 2/edit 3):
    # 111, 2-2, 33-, 4--, -55, -6-, --7

    ok !exception { $edit_2->accept }, 'accepted edit 2';
    $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id(2);
    cmp_set( [ map { $_->ipi } @$ipi_codes ],
        [ '11111111111', '33333333333', '55555555555', '66666666666' ]);

    ok !exception { $edit_3->accept }, 'accepted edit 3';
    $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id(2);
    cmp_set( [ map { $_->ipi } @$ipi_codes ],
        [ '11111111111', '55555555555', '66666666666', '77777777777' ]);
};

test 'Editing two artists into a conflict fails gracefully' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(3),
        name => 'Conflicting name',
        comment => 'Conflicting comment',
        ipi_codes => [],
        isni_codes => [],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(4),
        name => 'Conflicting name',
        comment => 'Conflicting comment',
        ipi_codes => [],
        isni_codes => [],
    );

    ok !exception { $edit_1->accept }, 'First edit can be applied';

    my $exception = exception { $edit_2->accept };
    isa_ok $exception, 'MusicBrainz::Server::Edit::Exceptions::GeneralError';
    like $exception->message, qr{//localhost/artist/da34a170-7f7f-11de-8a39-0800200c9a66},
        'Error message contains the URL of the conflict';
};

test 'Edits are idempotent' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my %edit = (
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Artist')->get_by_id(2),
        name      => 'Renamed artist',
        sort_name => 'Sort FOO',
        ipi_codes => [],
        isni_codes => [],
    );

    my $edit_1 = $c->model('Edit')->create(%edit);
    my $edit_2 = $c->model('Edit')->create(%edit);

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $artist = $c->model('Artist')->get_by_id(2);
    is($artist->name, 'Renamed artist', 'artist renamed');
    is($artist->sort_name, 'Sort FOO', 'sort name changed');
    is($artist->comment, 'UK group', 'comment unchanged');
};

test 'An artist with a non-empty comment is not a duplicate of itself' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(2),
        name => 'artist name',
        ipi_codes => [],
        isni_codes => [],
    );

    $edit->accept;

    my $artist = $c->model('Artist')->get_by_id(2);
    is($artist->name, 'artist name', 'artist renamed');
};

test 'Comments are trimmed (MBS-8573)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_edit');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(2),
        comment => '  test  comment  ',
        ipi_codes => [],
        isni_codes => [],
    );

    $edit->accept;

    my $artist = $c->model('Artist')->get_by_id(2);
    is($artist->comment, 'test comment');
};

test 'Fails edits trying to change the gender of a group (MBS-8722)' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, type)
            VALUES (2, 'cdf5588d-cca8-4e0c-bae1-d53bc73b012a', 'group', 'group', 1);
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(2),
        gender_id => 1,
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    ok($edit->is_open);
    $c->sql->do('UPDATE artist SET type = 2 WHERE id = 2');

    my $exception = exception { $edit->accept };
    isa_ok $exception, 'MusicBrainz::Server::Edit::Exceptions::GeneralError';
    is $exception->message, 'A group of artists cannot have a gender.';
};

test 'Fails edits trying to set an artist with a gender as a group' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (2, 'cdf5588d-cca8-4e0c-bae1-d53bc73b012a', 'person', 'person');
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(2),
        type_id => 5,
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    ok($edit->is_open);
    $c->sql->do('UPDATE artist SET gender = 1 WHERE id = 2');

    my $exception = exception { $edit->accept };
    isa_ok $exception, 'MusicBrainz::Server::Edit::Exceptions::GeneralError';
    is $exception->message, 'A group of artists cannot have a gender.';
};

test 'Type can be set to group when gender is removed (MBS-8801)' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, gender)
            VALUES (2, 'cdf5588d-cca8-4e0c-bae1-d53bc73b012a', 'Foo Baz', 'Foo Baz', 2);
        SQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(2),
        gender_id => undef,
        type_id => 2,
        ipi_codes => [],
        isni_codes => [],
    );
    accept_edit($c, $edit);

    is($c->model('Artist')->get_by_id(2)->type_id, 2);
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
        area_id => 221,
        ipi_codes => [ '00151894163', '00145958831' ],
        isni_codes => [ '0000000106750994', '0000000106750995' ],
    );
}

sub is_unchanged {
    my $artist = shift;
    is($artist->name, 'Artist Name');
    is($artist->sort_name, 'Artist Name');
    is($artist->$_, undef) for qw( type_id area_id gender_id );
    is($artist->comment, 'UK group');
    ok($artist->begin_date->is_empty);
    ok($artist->end_date->is_empty);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
