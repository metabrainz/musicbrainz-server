package MusicBrainz::Server::Controller::WS::js::Work;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::AliasAutocompletion';

my $ws_defs = Data::OptList::mkopt([
    "work" => {
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

sub type { 'work' }

sub search : Path('/ws/js/work') {
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

1;

