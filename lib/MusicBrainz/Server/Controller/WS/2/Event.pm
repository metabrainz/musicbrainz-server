package MusicBrainz::Server::Controller::WS::2::Event;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );

my $ws_defs = Data::OptList::mkopt([
     event => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     event => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
                         linked   => [ qw( area artist place collection ) ]
     },
     event => {
                         action   => '/ws/2/event/lookup',
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Event',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

sub base : Chained('root') PathPart('event') CaptureArgs(0) { }

sub event_toplevel {
    my ($self, $c, $stash, $events) = @_;

    my $inc = $c->stash->{inc};
    my @events = @{$events};

    $self->linked_events($c, $stash, $events);

    $c->model('EventType')->load(@events);

    $c->model('Event')->annotation->load_latest(@events)
        if $inc->annotation;

    if ($inc->aliases) {
        my $aliases = $c->model('Event')->alias->find_by_entity_ids(
            map { $_->id } @events
        );
        for (@events) {
            $stash->store($_)->{aliases} = $aliases->{$_->id};
        }
    }

    $self->load_relationships($c, $stash, @events);
}

sub event_browse : Private {
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id)) {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $events;

    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless $area;

        my @tmp = $c->model('Event')->find_by_area($area->id, $limit, $offset);
        $events = $self->make_list(@tmp, $offset);
    }

    if ($resource eq 'artist') {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless $artist;

        my @tmp = $c->model('Event')->find_by_artist($artist->id, $limit, $offset);
        $events = $self->make_list(@tmp, $offset);
    }

    if ($resource eq 'collection') {
        $events = $self->browse_by_collection($c, 'event', $id, $limit, $offset);
    }

    if ($resource eq 'place') {
        my $place = $c->model('Place')->get_by_gid($id);
        $c->detach('not_found') unless $place;

        my @tmp = $c->model('Event')->find_by_place($place->id, $limit, $offset);
        $events = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->event_toplevel($c, $stash, $events->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('event-list', $events, $c->stash->{inc}, $stash));
}

sub event_search : Chained('root') PathPart('event') Args(0) {
    my ($self, $c) = @_;

    $c->detach('event_browse') if ($c->stash->{linked});
    $self->_search($c, 'event');
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
