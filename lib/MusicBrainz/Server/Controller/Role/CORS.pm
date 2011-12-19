package MusicBrainz::Server::Controller::Role::CORS;
use Moose::Role;
use namespace::autoclean;

before begin => sub {
    my ($self, $c) = @_;
    $c->res->header('Access-Control-Allow-Origin' => '*');
};

1;
