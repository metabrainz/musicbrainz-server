package MusicBrainz::Server::Controller::WS::2::FreeDB;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     freedb => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub freedb_search : Chained('root') PathPart('freedb') Args(0)
{
    my ($self, $c) = @_;

    $self->_search ($c, 'freedb');
}

__PACKAGE__->meta->make_immutable;
1;
