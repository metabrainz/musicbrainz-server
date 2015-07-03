package t::MusicBrainz::Server::Controller::Label::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags');
    html_ok($mech->content);
    $mech->content_contains('musical');
    ok($mech->find_link(url_regex => qr{/tag/musical}), 'content links to the "musical" tag');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    # Test tagging
    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/upvote?tags=British, Electronic%3F');
    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags');
    html_ok($mech->content);
    $mech->content_contains('british');
    $mech->content_contains('electronic?');

    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/withdraw?tags=British, Electronic%3F');
    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags');
    html_ok($mech->content);
    $mech->content_lacks('british');
    $mech->content_lacks('electronic?');

    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/downvote?tags=British, Electronic%3F');
    $mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags');
    html_ok($mech->content);
    $mech->content_contains('british');
    $mech->content_contains('electronic?');
};

1;
