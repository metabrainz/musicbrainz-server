package MusicBrainz::Server::Controller::WS::2::CDStub;
use Moose;
use namespace::autoclean;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use MusicBrainz::Server::WebService::XML::XPath;

my $ws_defs = Data::OptList::mkopt([
     cdstub => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub cdstub_search : Chained('root') PathPart('cdstub') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('cdstub_submit') if $c->req->method eq 'POST';
    $self->_search($c, 'cdstub');
}

__PACKAGE__->meta->make_immutable;
1;
