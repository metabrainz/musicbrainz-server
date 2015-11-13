package MusicBrainz::Server::Controller::WS::2::Instrument;
use Moose;
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
        inc      => [ qw(aliases annotation _relations tags user-tags) ],
        optional => [ qw(fmt limit offset) ],
    },
    instrument => {
        method   => 'GET',
        inc      => [ qw(releases aliases annotation _relations tags user-tags) ],
        optional => [ qw(fmt) ],
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Instrument'
};

sub base : Chained('root') PathPart('instrument') CaptureArgs(0) { }

sub instrument_toplevel {
    my ($self, $c, $stash, $instrument) = @_;

    my $opts = $stash->store($instrument);

    $self->linked_instruments($c, $stash, [ $instrument ]);

    $c->model('InstrumentType')->load($instrument);

    $c->model('Instrument')->annotation->load_latest($instrument)
        if $c->stash->{inc}->annotation;

    $self->load_relationships($c, $stash, $instrument);
}

sub instrument : Chained('load') PathPart('') {
    my ($self, $c) = @_;
    my $instrument = $c->stash->{entity};

    return unless defined $instrument;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store($instrument);

    $self->instrument_toplevel($c, $stash, $instrument);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('instrument', $instrument, $c->stash->{inc}, $stash));
}

sub instrument_search : Chained('root') PathPart('instrument') Args(0) {
    my ($self, $c) = @_;

    $self->_search($c, 'instrument');
}

__PACKAGE__->meta->make_immutable;
1;

