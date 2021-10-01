package t::MusicBrainz::Server::Edit::Artist::EditAlias;
use Test::Routine;
use Test::More;

use Hash::Merge qw( merge );

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::EditAlias }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT_ALIAS );

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
    $c->sql->do(q(UPDATE artist_alias SET locale = 'fr'));
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
    my $opts = merge({ @_ }, {
        edit_type => $EDIT_ARTIST_EDIT_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $c->model('Artist')->alias->get_by_id(3),
        name      => 'Alias 2',
        sort_name => 'Alias 2',
        locale    => undef,
        primary_for_locale => 0,
        begin_date => partial_date_to_hash(PartialDate->new),
        end_date  => partial_date_to_hash(PartialDate->new),
        ended     => 0,
        type_id   => undef,
    });
    return $c->model('Edit')->create(%$opts);
}

1;
