package MusicBrainz::Server::Controller::WS::js::Series;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Series',
};

my $ws_defs = Data::OptList::mkopt([
    'series' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'series' }

sub search : Chained('root') PathPart('series') {
    my ($self, $c) = @_;

    $self->dispatch_search($c);
}

after _load_entities => sub {
    my ($self, $c, @entities) = @_;

    $c->model('SeriesType')->load(@entities);
};

1;
