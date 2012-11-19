package t::MusicBrainz::Server::Controller::Recording::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
use HTML::Selector::XPath 'selector_to_xpath';

around run_test => sub {
    my ($orig, $test, @a) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $test->$orig(@a);
};

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $mech->get_ok('/recording/merge_queue?add-to-merge=1');
    $mech->get_ok('/recording/merge_queue?add-to-merge=2');

    $mech->get_ok('/recording/merge');
    html_ok($mech->content);
    my $tx = test_xpath_html ($mech->content);
    $tx->not_ok(selector_to_xpath('.warning-isrcs-differ'),
                'Does not have a warning about differing ISRCs');

    my $response = $mech->submit_form(
        with_fields => {
            'merge.target' => '2',
        }
    );
    ok($mech->uri =~ qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8});

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Merge');
    is_deeply($edit->data, {
        old_entities => [ { name => 'Dancing Queen', id => '1' } ],
        new_entity => { name => 'King of the Mountain', id => '2' },
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');

    $mech->content_contains('Dancing Queen', '..contains old name');
    $mech->content_contains('King of the Mountain', '..contains new name');
};

test 'Warn the user when merging recordings with different ISRCs' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $c->sql->do("INSERT INTO isrc (isrc, recording) VALUES ('XXX250800230', 1)");

    $mech->get_ok('/recording/merge_queue?add-to-merge=1');
    $mech->get_ok('/recording/merge_queue?add-to-merge=2');

    $mech->get_ok('/recording/merge');
    html_ok($mech->content);

    my $tx = test_xpath_html ($mech->content);
    $tx->ok(selector_to_xpath('.warning-isrcs-differ'),
            'Has a warning about differing ISRCs');
};

1;
