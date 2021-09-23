package MusicBrainz::Server::Controller::WS::js::Place;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Place',
};

my $ws_defs = Data::OptList::mkopt([
    'place' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'place' }

sub search : Chained('root') PathPart('place')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub{
    my ($self, $c, @entities) = @_;
    $c->model('PlaceType')->load(@entities);
    my @areas = $c->model('Area')->load(@entities);
    $c->model('Area')->load_containment(@areas);
};

1;
