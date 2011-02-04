package MusicBrainz::Server::Controller::WS::2::Echoprint;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     echoprint => {
                         method   => 'GET',
                         inc      => [ qw(artists releases echoprints isrcs artist-credits aliases
                                          _relations tags user-tags ratings user-ratings) ]
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub echoprint : Chained('root') PathPart('echoprint') Args(1)
{
    my ($self, $c, $id) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($id))
    {
        $c->stash->{error} = "Invalid echoprint.";
        $c->detach('bad_req');
    }

    my $stash = WebServiceStash->new;
    my $echoprint = $c->model('Echoprint')->get_by_echoprint($id);
    unless ($echoprint) {
        $c->detach('not_found');
    }

    my $opts = $stash->store ($echoprint);

    my @recording_echoprints = $c->model('RecordingEchoprint')->find_by_echoprint($echoprint->id);
    my @recordings = map { $_->recording } @recording_echoprints;
    $opts->{recordings} = $self->make_list (\@recordings);

    for (@recordings)
    {
        $c->controller('WS::2::Recording')->recording_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('echoprint', $echoprint, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

