package MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::WithArtistCredits;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('ArtistCredit')->load(@entities);
};

1;
