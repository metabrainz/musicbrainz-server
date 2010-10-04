package MusicBrainz::Server::Controller::WS::2::List;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;

my $ws_defs = Data::OptList::mkopt([
     list => {
                         method   => 'GET',
                         inc      => [ qw(releases tags) ],
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

Readonly our $MAX_ITEMS => 25;

sub list_toplevel
{
    my ($self, $c, $stash, $list) = @_;

    my $opts = $stash->store ($list);

    $self->linked_lists ($c, $stash, [ $list ]);

    $c->model('Editor')->load($list);

    if ($c->stash->{inc}->releases)
    {
        my @results = $c->model('Release')->find_by_list($list->id, $MAX_ITEMS);

        $opts->{releases} = $self->make_list(@results);

        $self->linked_releases($c, $stash, $opts->{releases}->{items});
    }
}

sub list: Chained('root') PathPart('list') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid)) {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $list = $c->model('List')->get_by_gid($gid);
    unless ($list) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;

    $self->list_toplevel ($c, $stash, $list);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('list', $list, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
