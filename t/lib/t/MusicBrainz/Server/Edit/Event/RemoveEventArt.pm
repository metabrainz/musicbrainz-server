package t::MusicBrainz::Server::Edit::Event::RemoveEventArt;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;
use LWP::UserAgent::Mockable;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_REMOVE_EVENT_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting removes the linked event art' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+eaa');

    my $event = $c->model('Event')->get_by_id(59357);
    my @artwork = get_artwork($c, $event);
    is(scalar @artwork, 1, 'artwork exists');

    ok !exception {
        my $edit = create_remove_edit($c, $event);
        accept_edit($c, $edit);
    };

    @artwork = get_artwork($c, $event);
    is(scalar @artwork, 0, 'artwork was removed');
};

test 'Rejecting does not make any changes' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+eaa');

    my $event = $c->model('Event')->get_by_id(59357);
    my @artwork = get_artwork($c, $event);
    is(scalar @artwork, 1, 'artwork exists');

    ok !exception {
        my $edit = create_remove_edit($c, $event);
        reject_edit($c, $edit);
    };

    @artwork = get_artwork($c, $event);
    is(scalar @artwork, 1, 'artwork exists after rejecting removal');
};

sub get_artwork {
    my ($c, $event) = @_;
    return @{ $c->model('EventArt')->find_by_event($event) };
}

sub create_remove_edit {
    my ($c, $event) = @_;

    my @artwork = get_artwork($c, $event);

    $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_REMOVE_EVENT_ART,
        editor_id => 10,
        event => $event,
        to_delete => $artwork[0],
        event_art_types => ['Poster'],
    );
}

1;
