package MusicBrainz::Server::Controller::WS::2::Place;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     place => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     place => {
                         method   => 'GET',
                         linked   => [ qw(area) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     place => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Place'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('place') CaptureArgs(0) { }

sub place_toplevel
{
    my ($self, $c, $stash, $place) = @_;

    my $opts = $stash->store($place);

    $self->linked_places($c, $stash, [ $place ]);

    $c->model('PlaceType')->load($place);
    $c->model('Area')->load($c->stash->{place});

    $c->model('Place')->annotation->load_latest($place)
        if $c->stash->{inc}->annotation;

    if ($c->stash->{inc}->aliases)
    {
        my $aliases = $c->model('Place')->alias->find_by_entity_id($place->id);
        $opts->{aliases} = $aliases;
    }

    $self->load_relationships($c, $stash, $place);
}

sub place : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $place = $c->stash->{entity};

    return unless defined $place;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store($place);

    $self->place_toplevel($c, $stash, $place);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('place', $place, $c->stash->{inc}, $stash));
}

sub place_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $places;
    my $total;

    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless ($area);

        my @tmp = $c->model('Place')->find_by_area($area->id, $limit, $offset);
        $places = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    for (@{ $places->{items} })
    {
        $self->place_toplevel($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('place-list', $places, $c->stash->{inc}, $stash));
}

sub place_search : Chained('root') PathPart('place') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('place_browse') if ($c->stash->{linked});
    $self->_search($c, 'place');
}

__PACKAGE__->meta->make_immutable;
1;

