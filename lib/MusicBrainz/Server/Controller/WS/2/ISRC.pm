package MusicBrainz::Server::Controller::WS::2::ISRC;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_isrc );

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
    my ($self, $c, $isrc_code) = @_;

    if (!is_valid_isrc($isrc_code))
    {
        $c->stash->{error} = 'Invalid isrc.';
        $c->detach('bad_req');
    }

    my @isrcs = $c->model('ISRC')->find_by_isrc($isrc_code);
    unless (@isrcs) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;

    my @recordings = $c->model('Recording')->load(@isrcs);
    my $recordings = $self->make_list(\@recordings);

    $c->controller('WS::2::Recording')->recording_toplevel($c, $stash, \@recordings);

    # We only need to pass the first ISRC to the serializer, since the code
    # itself is the same on all of them.
    my $isrc = $isrcs[0];
    $stash->store($isrc)->{recordings} = $recordings;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('isrc', $isrc, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
