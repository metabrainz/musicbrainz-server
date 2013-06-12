package MusicBrainz::Server::Controller::WS::js::Area;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    "area" => {
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

sub type { 'area' }

sub serialization_routine { '_area' }

sub search : Chained('root') PathPart('area')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('AreaType')->load(@entities);
    $c->model('Area')->load_parent_country(@entities);
};

1;
