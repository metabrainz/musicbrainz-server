package MusicBrainz::Server::Controller::WS::2::PUID;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     puid => {
         method   => 'GET',
         inc      => [ qw(artists releases puids isrcs artist-credits aliases
                          _relations tags user-tags ratings user-ratings
                          release-groups ) ],
         optional => [ qw(fmt) ]
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub puid : Chained('root') PathPart('puid') Args(1)
{
    my ($self, $c, $id) = @_;

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid puid.";
        $c->detach('bad_req');
    }

    $c->detach('not_found');
}

__PACKAGE__->meta->make_immutable;
1;

