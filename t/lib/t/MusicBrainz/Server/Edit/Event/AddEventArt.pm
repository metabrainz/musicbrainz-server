package t::MusicBrainz::Server::Edit::Event::AddEventArt;
use strict;
use warnings;
use utf8;

use Test::Routine;
use Test::More;

use FindBin '$Bin';

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_EVENT_ART );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

with 't::Context';

test 'Accepting Add Event Art edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { account_admin => 1 });

    my $event = $c->model('Event')->get_by_id(59357);
    my $edit = create_edit($c, $event);
    my @artwork = @{ $c->model('EventArt')->find_by_event($event) };

    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            !$artwork[0]->approved,
        'artwork is added, but not approved',
    );

    accept_edit($c, $edit);

    @artwork = @{ $c->model('EventArt')->find_by_event($event) };
    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            $artwork[0]->approved,
        'artwork is approved after edit is accepted',
    );

    my ($edits, undef) = $c->model('Edit')->find({ event => 59357 }, 1, 0);
    ok(
        scalar @$edits && $edits->[0]->id == $edit->id,
        'edit is in the event’s edit history',
    );
};

test 'Rejecting cleans up pending artwork' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { account_admin => 1 });

    my $event = $c->model('Event')->get_by_id(59357);
    my $edit = create_edit($c, $event);
    my @artwork = @{ $c->model('EventArt')->find_by_event($event) };

    ok(
        scalar @artwork == 1 &&
            $artwork[0]->id == 1234 &&
            !$artwork[0]->approved,
        'artwork is added, but not approved',
    );

    reject_edit($c, $edit);

    @artwork = @{ $c->model('EventArt')->find_by_event($event) };
    is(scalar @artwork, 0, 'artwork is removed after edit is rejected');

    my ($edits, undef) = $c->model('Edit')->find({ event => 59357 }, 1, 0);
    ok(
        scalar @$edits && $edits->[0]->id == $edit->id,
        'edit is in the event’s edit history',
    );
};

sub create_edit {
    my ($c, $event) = @_;
    $c->model('Edit')->create(
        edit_type => $EDIT_EVENT_ADD_EVENT_ART,
        editor_id => 1,
        event => $event,
        event_art_id => '1234',
        event_art_types => [1],
        event_art_position => 1,
        event_art_comment => '',
        event_art_mime_type => 'image/jpeg',
    );
}

1;
