package MusicBrainz::Server::Controller::WS::2::TOC;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' };

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use aliased 'MusicBrainz::Server::Entity::CDTOC';

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     toc => {
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups artist-credits
                                          aliases puids isrcs _relations cdstubs ) ]
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub toc : Chained('root') PathPart('toc') Args(1)
{
    my ($self, $c, $toc) = @_;

    my $results = $c->model('DurationLookup')->lookup($toc, 10000);
    my $inc = $c->stash->{inc};

    $c->model('Release')->load(map { $_->medium } @$results);
    my @releases = map { $_->medium->release } @$results;

    my $stash = WebServiceStash->new;
    $c->controller('WS::2::Release')->release_toplevel($c, $stash, $_)
        for @releases;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize(
        'release_list',
        {
            items => \@releases
        },
        $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

