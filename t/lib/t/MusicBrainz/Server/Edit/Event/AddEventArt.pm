package t::MusicBrainz::Server::Edit::Event::AddEventArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_EVENT_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting replaces current art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    my $edit = create_edit($c);

    accept_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

test 'Rejecting cleans up pending artwork' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    my $edit = create_edit($c);

    reject_edit($c, $edit);

    ok !exception {
        LWP::UserAgent::Mockable->finished;
    };
};

sub create_edit {
    my $c = shift;
    $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_ADD_EVENT_ART,
        editor_id => 1,
        event => $c->model('Event')->get_by_id(59357),
        event_art_id => '1234',
        event_art_types => [1],
        event_art_position => 1,
        event_art_comment => '',
        event_art_mime_type => 'image/jpeg',
    );
}

1;
