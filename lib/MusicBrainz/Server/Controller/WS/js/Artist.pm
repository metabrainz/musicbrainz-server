package MusicBrainz::Server::Controller::WS::js::Artist;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::AliasAutocompletion';

my $ws_defs = Data::OptList::mkopt([
    "artist" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "artist" => {
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
    model => 'Artist'
};

sub type { 'artist' }

sub base : Chained('root') PathPart('artist') CaptureArgs(0) { }

sub search : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

1;

