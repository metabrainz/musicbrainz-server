package t::MusicBrainz::Server::Edit::URL::Delete;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::URL::Delete }

use MusicBrainz::Server::Constants qw( $EDIT_URL_DELETE $EDITOR_MODBOT );
use MusicBrainz::Server::Types ':edit_status';
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Can delete URLs with relationships' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url_delete');

    my $url = $c->model('URL')->get_by_id(2);

    my $edit = _create_edit($c, $url);
    isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ url => $url->id }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $url = $c->model('URL')->get_by_id($url->id);
    is($url->edits_pending, 1);

    # Test accepting the edit
    # This should fail as the url has a relationship
    accept_edit($c, $edit);
    $url = $c->model('URL')->get_by_id($url->id);
    is($edit->status, $STATUS_APPLIED);
    ok(!defined $url);
};

test 'Can delete unused URLs' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url_delete');

    my $url = $c->model('URL')->get_by_id(1);

    my $edit = _create_edit($c, $url);
    isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ url => $url->id }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $url = $c->model('URL')->get_by_id($url->id);
    is($url->edits_pending, 1);

    # Test accepting the edit
    accept_edit($c, $edit);
    $url = $c->model('URL')->get_by_id($url->id);
    is($edit->status, $STATUS_APPLIED);
    ok(!defined $url);
};

test 'Can be entered as an auto-edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url_delete');

    my $url = $c->model('URL')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_URL_DELETE,
        to_delete => $url,
        editor_id => $EDITOR_MODBOT,
        privileges => 1
    );
    isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Delete');

    $url = $c->model('URL')->get_by_id($url->id);
    ok(!defined $url);
};

sub _create_edit {
    my ($c, $url) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_URL_DELETE,
        to_delete => $url,
        editor_id => 1
    );
}

1;
