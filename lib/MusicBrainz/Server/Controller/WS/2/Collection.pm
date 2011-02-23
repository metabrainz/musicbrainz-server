package MusicBrainz::Server::Controller::WS::2::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use List::MoreUtils qw( uniq all );
use MusicBrainz::Server::WebService::XML::XPath;
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     collection => {
                         method   => 'GET',
                         inc      => [ qw(releases tags) ],
                         optional => [ qw(limit offset) ],
     },
     collection => {
         method => 'POST',
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Collection',
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('collection') CaptureArgs(0) { }

sub list_toplevel
{
    my ($self, $c, $stash, $collection) = @_;

    my $opts = $stash->store ($collection);

    $self->linked_lists ($c, $stash, [ $collection ]);

    $c->model('Editor')->load($collection);

    if ($c->stash->{inc}->releases)
    {
        my @results = $c->model('Release')->find_by_collection($collection->id, $MAX_ITEMS);

        $opts->{releases} = $self->make_list(@results);

        $self->linked_releases($c, $stash, $opts->{releases}->{items});
    }
}

sub list: Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    if ($c->req->method eq 'GET') {
        $self->list_get($c);
    }
    else {
        $self->list_post($c);
    }
}

sub list_list : Chained('base') PathPart('')
{
    my ($self, $c) = @_;
    $c->authenticate({}, 'musicbrainz.org');

    my $stash = WebServiceStash->new;
    my @collections = $c->model('Collection')->find_all_by_editor($c->user->id);
    $c->model('Editor')->load(@collections);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection_list', \@collections,
                                                     $c->stash->{inc}, $stash));
}

sub list_post {
    my ($self, $c) = @_;
    my $collection = $c->stash->{entity};

    $c->authenticate({}, 'musicbrainz.org');

    my $client = $c->req->query_params->{client}
        or _error($c, 'You must provide information about your client, by the client query parameter');

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my @add_gids = uniq map { $xp->find('@mb:id', $_)->string_value }
        $xp->find('/mb:metadata/mb:add/mb:release')->get_nodelist;

    my @remove_gids = uniq map { $xp->find('@mb:id', $_)->string_value }
        $xp->find('/mb:metadata/mb:remove/mb:release')->get_nodelist;

    _error ($c, "All releases must have an MBID present")
        unless all { defined } (@add_gids, @remove_gids);

    for my $gid (@add_gids, @remove_gids) {
        _error($c, "$gid is not a valid MBID")
            unless MusicBrainz::Server::Validation::IsGUID($gid);
    }

    my %releases = map {
        $_->gid => $_
    } values %{ $c->model('Release')->get_by_gids(@add_gids, @remove_gids) };

    $c->model('Collection')->add_releases_to_collection(
        $collection->id,
        map { $_->id } grep { defined } map { $releases{$_} } @add_gids
    ) if @add_gids;

    $c->model('Collection')->remove_releases_from_collection(
        $collection->id,
        map { $_->id } grep { defined } map { $releases{$_} } @remove_gids
    ) if @remove_gids;

    $c->detach('success');
}

sub list_get {
    my ($self, $c) = @_;
    my $collection = $c->stash->{entity};

    my $stash = WebServiceStash->new;

    $self->list_toplevel ($c, $stash, $collection);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection', $collection, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
