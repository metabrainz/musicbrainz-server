package MusicBrainz::Server::Controller::WS::2::ISRC;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_isrc );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     isrc => {
                         method   => 'GET',
                         inc      => [ qw(artists releases puids isrcs artist-credits aliases
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw( fmt ) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub isrc : Chained('root') PathPart('isrc') Args(1)
{
    my ($self, $c, $isrc) = @_;

    if (!is_valid_isrc($isrc))
    {
        $c->stash->{error} = "Invalid isrc.";
        $c->detach('bad_req');
    }

    my @isrcs = $c->model('ISRC')->find_by_isrc($isrc);
    unless (@isrcs) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;

    my @recordings = $c->model('Recording')->load(@isrcs);
    my $recordings = $self->make_list (\@recordings);

    for (@recordings)
    {
        $c->controller('WS::2::Recording')->recording_toplevel ($c, $stash, $_);
    }

    for (@isrcs)
    {
        $stash->store ($_)->{recordings} = $recordings;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('isrc', \@isrcs, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
