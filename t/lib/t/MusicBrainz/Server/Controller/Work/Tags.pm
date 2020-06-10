package t::MusicBrainz::Server::Controller::Work::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test 'Can tag' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('musical');
    ok($mech->find_link(url_regex => qr{/tag/musical}), 'content links to the "musical" tag');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    # Test tagging
    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=boring, classical');
    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('boring');
    $mech->content_contains('classical');

    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/withdraw?tags=boring, classical');
    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_lacks('boring');
    $mech->content_lacks('classical');

    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=boring, classical');
    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('boring');
    $mech->content_contains('classical');
};

test 'Cannot tag without a confirmed email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $c->model('Editor')->insert({
        name => 'iwannatag',
        password => 'password'
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'iwannatag', password => 'password' } );

    # Test tagging
    $mech->get('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=boring, classical');
    is ($mech->status, 401, 'Tag adding rejected without confirmed address');

    $mech->get('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=boring, classical');
    is ($mech->status, 401, 'Tag downvoting rejected without confirmed address');
};

1;
