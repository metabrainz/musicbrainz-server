package MusicBrainz::Server::Controller::WS::js::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::WithArtistCredits';

my $ws_defs = Data::OptList::mkopt([
    "release-group" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "release-group" => {
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
    model => 'ReleaseGroup'
};

sub type { 'release_group' }

sub base : Chained('root') PathPart('release-group') CaptureArgs(0) { }

around 'get' => sub
{
    my ($orig, $self, $c) = @_;
    $c->model('ArtistCredit')->load($c->stash->{entity});
    $self->$orig($c);
};

sub serialization_routine { 'autocomplete_release_group' }

sub entity_routine { '_release_group' }

sub search : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

1;

