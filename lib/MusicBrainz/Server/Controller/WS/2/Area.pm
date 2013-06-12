package MusicBrainz::Server::Controller::WS::2::Area;
use Moose;
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
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     area => {
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
    model => 'Area'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('area') CaptureArgs(0) { }

sub area_toplevel
{
    my ($self, $c, $stash, $area) = @_;

    my $opts = $stash->store ($area);

    $self->linked_areas ($c, $stash, [ $area ]);


    $c->model('Area')->load_codes($area);
    $c->model('AreaType')->load($area);

    $c->model('Area')->annotation->load_latest($area)
        if $c->stash->{inc}->annotation;

    if ($c->stash->{inc}->aliases)
    {
        my $aliases = $c->model('Area')->alias->find_by_entity_id($area->id);
        $opts->{aliases} = $aliases;
    }

    $self->load_relationships($c, $stash, $area);
}

sub area : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $area = $c->stash->{entity};

    return unless defined $area;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($area);

    $self->area_toplevel ($c, $stash, $area);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('area', $area, $c->stash->{inc}, $stash));
}

sub area_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset ($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $areas;
    my $total;

    my $stash = WebServiceStash->new;

    for (@{ $areas->{items} })
    {
        $self->label_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('area-list', $areas, $c->stash->{inc}, $stash));
}

sub area_search : Chained('root') PathPart('area') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('area_browse') if ($c->stash->{linked});
    $self->_search ($c, 'area');
}

__PACKAGE__->meta->make_immutable;
1;

