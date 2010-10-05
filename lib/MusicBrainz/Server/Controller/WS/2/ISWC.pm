package MusicBrainz::Server::Controller::WS::2::ISWC;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     iswc => {
                         method   => 'GET',
                         inc      => [ qw(artists aliases artist-credits
                                          _relations tags user-tags ratings user-ratings) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub iswc : Chained('root') PathPart('iswc') Args(1)
{
    my ($self, $c, $iswc) = @_;

    if (!is_valid_iswc($iswc))
    {
        $c->stash->{error} = "Invalid iswc.";
        $c->detach('bad_req');
    }

    my @works = $c->model('Work')->find_by_iswc($iswc);
    unless (@works) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($iswc);
    $opts->{works} = $self->make_list (\@works);

    for (@works)
    {
        $c->controller('Work')->work_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('isrc', \@works, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
