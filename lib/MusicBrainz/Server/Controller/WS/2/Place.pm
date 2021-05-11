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
                         linked   => [ qw(area collection) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     place => {
                         action   => '/ws/2/place/lookup',
                         method   => 'GET',
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Place',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('place') CaptureArgs(0) { }

sub place_toplevel
{
    my ($self, $c, $stash, $places) = @_;

    my $inc = $c->stash->{inc};
    my @places = @{$places};

    $self->linked_places($c, $stash, $places);

    $c->model('PlaceType')->load(@places);
    $c->model('Area')->load(@places);

    $c->model('Place')->annotation->load_latest(@places)
        if $inc->annotation;

    $self->load_relationships($c, $stash, @places);
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

    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless ($area);

        my @tmp = $c->model('Place')->find_by_area($area->id, $limit, $offset);
        $places = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'collection') {
        $places = $self->browse_by_collection($c, 'place', $id, $limit, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->place_toplevel($c, $stash, $places->{items});

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

