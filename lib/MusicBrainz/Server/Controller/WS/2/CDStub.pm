package MusicBrainz::Server::Controller::WS::2::CDStub;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     cdstub => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

Readonly my %serializers => (
    xml => 'MusicBrainz::Server::WebService::XMLSerializer',
);

sub cdstub_search : Chained('root') PathPart('cdstub') Args(0)
{
    my ($self, $c) = @_;

    $self->_search ($c, 'cdstub');
}
__PACKAGE__->meta->make_immutable;
1;
