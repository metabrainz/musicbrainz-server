package t::MusicBrainz::Server::Edit::Role::AllowAmending;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT $EDIT_RELEASE_CREATE );

use MusicBrainz::Server::Edit::Medium::Edit;

test 'Allow amending entity within one day' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+amend_entity');

    my $edit;
    my $medium = $c->model('Medium')->get_by_id(1);

    subtest 'Auto-edit amending entity created by the same editor within one day' => sub {
        $edit = create_edit($c, $medium, 1411452, 30171);
        is($edit->can_amend(1), 1, 'amending allowed');
    };

    subtest 'Non-auto-edit amending entity created by another editor within one day' => sub {
        $edit = create_edit($c, $medium, 1411453, 30172);
        is($edit->can_amend(1), '', 'amending disallowed');
    };

    subtest 'Non-auto-edit amending entity created by the same editor after one day' => sub {
        $test->c->sql->do("UPDATE edit SET open_time = NOW() - INTERVAL '1 day' WHERE type = $EDIT_RELEASE_CREATE;");
        $edit = create_edit($c, $medium, 1411454, 30171);
        is($edit->can_amend(1), '', 'amending disallowed');
    };

    subtest 'Non-auto-edit amending entity without create edit in entity editing history' => sub {
        $test->c->sql->do('DELETE FROM edit_release WHERE edit = 1;');
        $test->c->sql->do('DELETE FROM edit WHERE id = 1;');
        $edit = create_edit($c, $medium, 1411455, 30171);
        is($edit->can_amend(1), '', 'amending disallowed');
    };
};

sub create_edit {
    my ($c, $medium, $format, $editor_id) = @_;

    return $c->model('Edit')->create(
        editor_id => $editor_id,
        edit_type => $EDIT_MEDIUM_EDIT,
        to_edit => $medium,
        format_id => $format,
        name => 'Medium Name',
    );
};

1;
