package MusicBrainz::Server::Controller::WS::js::Instrument;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::ControllerBase::WS::js';

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Instrument',
};

my $ws_defs = Data::OptList::mkopt([
    'instrument' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(advanced direct limit page timestamp) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
    version => 'js',
    default_serialization_type => 'json',
};

sub type { 'instrument' }

sub search : Chained('root') PathPart('instrument') {
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('InstrumentType')->load(@entities);
};

1;
