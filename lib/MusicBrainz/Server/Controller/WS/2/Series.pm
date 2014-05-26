package MusicBrainz::Server::Controller::WS::2::Series;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     series => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     series => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Series'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('series') CaptureArgs(0) { }

sub series_toplevel {
    my ($self, $c, $stash, $series) = @_;

    my $opts = $stash->store($series);

    $self->linked_series($c, $stash, [$series]);

    $c->model('SeriesType')->load($series);
    $c->model('SeriesOrderingType')->load($series);

    $c->model('Series')->annotation->load_latest($series)
        if $c->stash->{inc}->annotation;

    if ($c->stash->{inc}->aliases) {
        my $aliases = $c->model('Series')->alias->find_by_entity_id($series->id);
        $opts->{aliases} = $aliases;
    }

    $self->load_relationships($c, $stash, $series);
}

sub series : Chained('load') PathPart('') {
    my ($self, $c) = @_;
    my $series = $c->stash->{entity};

    return unless defined $series;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store($series);

    $self->series_toplevel($c, $stash, $series);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('series', $series, $c->stash->{inc}, $stash));
}

sub series_search : Chained('root') PathPart('series') Args(0) {
    my ($self, $c) = @_;

    $self->_search($c, 'series');
}

__PACKAGE__->meta->make_immutable;
1;

