package t::MusicBrainz::Server::Edit::Artist::EditAlias;
use Test::Routine;
use Test::Fatal;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::EditAlias }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT_ALIAS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Editing an alias sort name should be an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    ok(!create_edit($c, sort_name => 'New sort name')->is_open);
};

test 'Editing an alias type should be an auto edit if no type exists' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    ok(!create_edit($c, type_id => 1)->is_open);
};

test 'Editing an alias type should be an auto edit if a type exists' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
    $c->sql->do('UPDATE artist_alias SET type = 1');

    ok(!create_edit($c, type_id => 2)->is_open);
};

test 'Adding dates to an alias without dates should be an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    ok(!create_edit($c,
                    begin_date => { year => 2000, month => 1 },
                    end_date => { year => 2002, month => 5, day => 10 })
           ->is_open);
};

test 'Adding dates to an alias with dates should be an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
    $c->sql->do(
        'UPDATE artist_alias SET begin_date_year = 1999, end_date_year = 2002, end_date_month = 5');

    ok(!create_edit($c,
                   begin_date => { year => 2000, month => 1 },
                   end_date => { year => 2002, month => 5, day => 10 })
           ->is_open);
};

test 'Adding locales to an alias without locales should be an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
    ok(!create_edit($c, locale => 'en_GB')->is_open);
};

test 'Adding locales to an alias with locales should be an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
    $c->sql->do("UPDATE artist_alias SET locale = 'fr'");
    ok(!create_edit($c, locale => 'en_GB')->is_open);
};

test 'Setting an alias as primary for a locale is an auto edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
    ok(!create_edit($c, primary_for_locale => 1, locale => 'en_GB')->is_open);
};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(3),
        @_,
    );
}

1;
