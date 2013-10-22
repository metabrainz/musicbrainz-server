package MusicBrainz::Server::Controller::WS::js::Place;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    "place" => {
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

sub serialization_routine { '_place' }

sub search : Chained('root') PathPart('place')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

sub _format_output {
    my ($self, $c, @entities) = @_;
    $c->model('PlaceType')->load(@entities);
    $c->model('Area')->load(@entities);
    my $aliases = $c->model('Place')->alias->find_by_entity_ids(
        map { $_->id } @entities);

    return map +{
        place => $_,
        aliases => $aliases->{$_->id},
        current_language => $c->stash->{current_language} // 'en'
    }, @entities;
}

1;
