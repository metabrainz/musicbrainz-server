package MusicBrainz::Server::Controller::WS::2::Instrument;
use Moose;
use MusicBrainz::Server::Validation qw( is_guid );

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

my $ws_defs = Data::OptList::mkopt([
    instrument => {
        method   => 'GET',
        required => [ qw(query) ],
        optional => [ qw(fmt limit offset) ],
    },
    instrument => {
        method   => 'GET',
        linked   => [ qw(collection) ],
        inc      => [ qw(aliases annotation _relations
                         tags user-tags
                         genres user-genres
                         moods user-moods) ],
        optional => [ qw(fmt limit offset) ],
     },
    instrument => {
        method   => 'GET',
        inc      => [ qw(aliases annotation _relations
                         tags user-tags
                         genres user-genres
                         moods user-moods) ],
        optional => [ qw(fmt limit offset) ],
    },
    instrument => {
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
    model => 'Instrument',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

sub base : Chained('root') PathPart('instrument') CaptureArgs(0) { }

sub instrument_toplevel {
    my ($self, $c, $stash, $instruments) = @_;

    $self->linked_instruments($c, $stash, $instruments);

    $c->model('InstrumentType')->load(@$instruments);

    $c->model('Instrument')->annotation->load_latest(@$instruments)
        if $c->stash->{inc}->annotation;

    $self->load_relationships($c, $stash, @$instruments);
}

sub instrument_browse : Private {
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id)) {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $instruments;

    if ($resource eq 'collection') {
        $instruments = $self->browse_by_collection($c, 'instrument', $id, $limit, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->instrument_toplevel($c, $stash, $instruments->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('instrument-list', $instruments, $c->stash->{inc}, $stash));
}

sub instrument_search : Chained('root') PathPart('instrument') Args(0) {
    my ($self, $c) = @_;

    $c->detach('instrument_browse') if $c->stash->{linked};
    $self->_search($c, 'instrument');
}

__PACKAGE__->meta->make_immutable;
1;

