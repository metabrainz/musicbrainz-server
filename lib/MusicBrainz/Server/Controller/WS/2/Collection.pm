package MusicBrainz::Server::Controller::WS::2::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     list => {
                         method   => 'GET',
                         inc      => [ qw(releases tags) ],
                         optional => [ qw(limit offset) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Collection',
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('/') PathPart('ws/2/collection') CaptureArgs(0) { }

sub list_toplevel
{
    my ($self, $c, $stash, $collection) = @_;

    my $opts = $stash->store ($collection);

    $self->linked_lists ($c, $stash, [ $collection ]);

    $c->model('Editor')->load($collection);

    if ($c->stash->{inc}->releases)
    {
        my @results = $c->model('Release')->find_by_collection($collection->id, $MAX_ITEMS);

        $opts->{releases} = $self->make_list(@results);

        $self->linked_releases($c, $stash, $opts->{releases}->{items});
    }
}

sub list: Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $collection = $c->stash->{entity};

    my $stash = WebServiceStash->new;

    $self->list_toplevel ($c, $stash, $collection);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection', $collection, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
