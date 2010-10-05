package MusicBrainz::Server::Controller::WS::2::DiscID;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' };

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_discid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     discid => {
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups artist-credits
                                          aliases puids isrcs _relations) ]
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub discid : Chained('root') PathPart('discid') Args(1)
{
    my ($self, $c, $id) = @_;

    if (!is_valid_discid($id))
    {
        $c->stash->{error} = "Invalid discid.";
        $c->detach('bad_req');
    }

    my $cdtoc = $c->model('CDTOC')->get_by_discid($id);
    unless ($cdtoc) {
        $c->detach('not_found');
    }

    my @mediumcdtocs = $c->model('MediumCDTOC')->find_by_cdtoc($cdtoc->id);
    $c->model('Medium')->load(@mediumcdtocs);

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($cdtoc);

    my @releases = $c->model('Release')->find_by_medium(
        [ map { $_->medium_id } @mediumcdtocs ], $c->stash->{status}, $c->stash->{type});
    $opts->{releases} = $self->make_list (\@releases);

    for (@releases)
    {
        $c->controller('WS::2::Release')->release_toplevel($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('discid', $cdtoc, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

