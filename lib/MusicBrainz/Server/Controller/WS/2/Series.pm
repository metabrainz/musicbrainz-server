package MusicBrainz::Server::Controller::WS::2::Series;
use Moose;
use MusicBrainz::Server::Validation qw( is_guid );
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
                         linked   => [ qw(collection) ],
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags
                                          genres user-genres
                                          moods user-moods) ],
                         optional => [ qw(fmt limit offset) ],
     },
     series => {
                         action   => '/ws/2/series/lookup',
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags
                                          genres user-genres
                                          moods user-moods) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Series',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('series') CaptureArgs(0) { }

sub series_toplevel {
    my ($self, $c, $stash, $series) = @_;

    $self->linked_series($c, $stash, $series);

    $c->model('SeriesType')->load(@$series);
    $c->model('SeriesOrderingType')->load(@$series);

    $c->model('Series')->annotation->load_latest(@$series)
        if $c->stash->{inc}->annotation;

    $self->load_relationships($c, $stash, @$series);
}

sub series_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id)) {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $series;
    if ($resource eq 'collection') {
        $series = $self->browse_by_collection($c, 'series', $id, $limit, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->series_toplevel($c, $stash, $series->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('series-list', $series, $c->stash->{inc}, $stash));
}

sub series_search : Chained('root') PathPart('series') Args(0) {
    my ($self, $c) = @_;

    $c->detach('series_browse') if $c->stash->{linked};
    $self->_search($c, 'series');
}

__PACKAGE__->meta->make_immutable;
1;

