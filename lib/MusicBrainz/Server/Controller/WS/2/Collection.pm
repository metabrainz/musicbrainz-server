package MusicBrainz::Server::Controller::WS::2::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use List::MoreUtils qw( uniq all );
use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_COLLECTION );
use MusicBrainz::Server::WebService::XML::XPath;
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     collection => {
                         method   => 'GET',
                         inc      => [ qw(releases tags) ],
                         optional => [ qw(fmt limit offset) ],
     },
     collection => {
         method => 'PUT',
     },
     collection => {
         method => 'DELETE',
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Collection',
    entity_name => 'collection'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('collection') CaptureArgs(0) { }

sub releases_get : Chained('load') PathPart('releases') Args(0)
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{entity};

    if (!$collection->public) {
        $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);
        if ($c->user_exists) {
            $self->_error($c, 'You do not have permission to view this collection')
                unless $c->user->id == $collection->editor_id;
        }
    }

    my $stash = WebServiceStash->new;

    my $opts = $stash->store ($collection);

    $self->linked_lists ($c, $stash, [ $collection ]);

    $c->model('Editor')->load($collection);

    my ($limit, $offset) = $self->_limit_and_offset ($c);
    my @results = $c->model('Release')->find_by_collection($collection->id, $limit, $offset);

    $opts->{releases} = $self->make_list(@results);

    $self->linked_releases($c, $stash, $opts->{releases}->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection', $collection, $c->stash->{inc}, $stash));
}

sub releases : Chained('load') PathPart('releases') Args(1) {
    my ($self, $c, $releases) = @_;
    my $collection = $c->stash->{entity};

    $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);

    $self->_error($c, 'You do not have permission to modify this collection')
        unless ($c->user->id == $collection->editor_id);

    my $client = $c->req->query_params->{client}
        or $self->_error($c, 'You must provide information about your client, by the client query parameter');
    $self->bad_req($c, 'Invalid argument "client"') if ref($client);

    my @gids = split /;/, $releases;

    $self->_error ($c, "All releases must have an MBID present")
        unless all { defined } (@gids);

    for my $gid (@gids) {
        $self->_error($c, "$gid is not a valid MBID")
            unless is_guid($gid);
    }

    my %releases = %{ $c->model('Release')->get_by_gids(@gids) };

    if ($c->req->method eq 'PUT') {
        $self->deny_readonly($c);
        $c->model('Collection')->add_releases_to_collection(
            $collection->id,
            map { $_->id } grep { defined } map { $releases{$_} } @gids
        );

        $c->detach('success');
    }
    elsif ($c->req->method eq 'DELETE') {
        $self->deny_readonly($c);
        $c->model('Collection')->remove_releases_from_collection(
            $collection->id,
            map { $_->id } grep { defined } map { $releases{$_} } @gids
        );

        $c->detach('success');
    }
    else {
        $self->_error($c, 'You can only PUT or DELETE this resource');
    }
}

sub list_list : Chained('base') PathPart('')
{
    my ($self, $c) = @_;

    $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);

    my $stash = WebServiceStash->new;

    my @collections = $c->model('Collection')->find_all_by_editor($c->user->id);
    $c->model('Editor')->load(@collections);
    $c->model('Collection')->load_release_count(@collections);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection_list', \@collections,
                                                     $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
