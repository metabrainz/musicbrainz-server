package t::MusicBrainz::Server::Controller::Release::EditCoverArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Adding cover art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'caa_editor', password => 'password' } );

    my $new_comment = 'Adding a comment';
    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/edit-cover-art/12345');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-cover-art.comment' => $new_comment
            }
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditCoverArt');
    my $data = $edit->data;
    is($data->{id}, 12345, 'Edits the correct artwork');
    is($data->{new}{comment}, $new_comment, 'Adds a comment');
};

1;
