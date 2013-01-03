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

    my $stash = WebServiceStash->new;
    my $puid = $c->model('PUID')->get_by_puid($id);
    unless ($puid) {
        $c->detach('not_found');
    }

    my $opts = $stash->store ($puid);

    my @recording_puids = $c->model('RecordingPUID')->find_by_puid($puid->id);
    my @recordings = map { $_->recording } @recording_puids;
    $opts->{recordings} = $self->make_list (\@recordings);

    for (@recordings)
    {
        $c->controller('WS::2::Recording')->recording_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('puid', $puid, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

