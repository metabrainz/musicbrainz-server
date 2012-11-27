package t::MusicBrainz::Server::Controller::Artist::Merge;
use Test::Routine;
use Test::More;
use Test::XPath;
use HTML::Selector::XPath 'selector_to_xpath';
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

around run_test => sub {
    my $test_body = shift;
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/artist/merge_queue?add-to-merge=4');
    $mech->get_ok('/artist/merge_queue?add-to-merge=3');

    $mech->get_ok('/artist/merge');
    html_ok($mech->content);

    $test->$test_body(@_);
};

with 't::Mechanize', 't::Context';

test 'Do not rename artist credits' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
            'merge.rename' => 0
        }
    );
    ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce});

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

    is_deeply($edit->data, {
        old_entities => [ { name => 'Empty Artist', id => 4, } ],
        new_entity => { name => 'Test Artist', id => 3, },
        rename => 0
    });

    $mech->get_ok('/edit/' . $edit->id);
    my $tx = test_xpath_html ($mech->content);

    $tx->ok(selector_to_xpath('table.merge-artists', prefix => "html"), sub {
        $_->ok(selector_to_xpath('.rename-artist-credits', prefix => "html"), sub {
            $_->like('./html:td', qr/No/, 'correct display of rename data');
        }, 'has information about renaming artist credits');
    }, 'should have edit data');
};

test 'Rename artist credits' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
            'merge.rename' => 1
        }
    );
    ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce});

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

    is_deeply($edit->data, {
        old_entities => [ { name => 'Empty Artist', id => 4, } ],
        new_entity => { name => 'Test Artist', id => 3, },
        rename => 1
    });

    $mech->get_ok('/edit/' . $edit->id);
    my $tx = test_xpath_html ($mech->content);

    $tx->ok(selector_to_xpath('table.merge-artists', prefix => "html"), sub {
        $_->ok(selector_to_xpath('.rename-artist-credits', prefix => "html"), sub {
            $_->like('./html:td', qr/Yes/, 'correct display of rename data');
        }, 'has information about renaming artist credits');
    }, 'should have edit data');
};

1;
