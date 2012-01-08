package MusicBrainz::Server::Controller::WS::js::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    "release" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "release" => {
        method   => 'GET'
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Release'
};

sub type { 'release' }

sub base : Chained('root') PathPart('release') CaptureArgs(0) { }

sub search : Chained('root') PathPart('release') Args(0)
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

1;

