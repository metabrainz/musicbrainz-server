package MusicBrainz::Server::Controller::WS::2::Area;
use Moose;
use namespace::autoclean;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     area => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     area => {
                         method   => 'GET',
                         linked   => [ qw(collection) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     area => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     area => {
                         action   => '/ws/2/area/lookup',
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
    model => 'Area',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('area') CaptureArgs(0) { }

sub area_toplevel
{
    my ($self, $c, $stash, $areas) = @_;

    my $inc = $c->stash->{inc};
    my @areas = @{$areas};

    $self->linked_areas($c, $stash, $areas);

    $c->model('AreaType')->load(@areas);

    $c->model('Area')->annotation->load_latest(@areas)
        if $inc->annotation;

    $self->load_relationships($c, $stash, @areas);
}

sub area_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $areas;
    if ($resource eq 'collection') {
        $areas = $self->browse_by_collection($c, 'area', $id, $limit, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->area_toplevel($c, $stash, $areas->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('area-list', $areas, $c->stash->{inc}, $stash));
}

sub area_search : Chained('root') PathPart('area') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('area_browse') if ($c->stash->{linked});
    $self->_search($c, 'area');
}

__PACKAGE__->meta->make_immutable;
1;

