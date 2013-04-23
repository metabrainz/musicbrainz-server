package MusicBrainz::Server::Controller::WS::1::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_COLLECTION );
use MusicBrainz::Server::Validation qw( is_guid trim_in_place );

with 'MusicBrainz::Server::Controller::WS::1::Role::Serializer';
with 'MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration';

my $ws_defs = Data::OptList::mkopt([
    collection => {
        method   => 'GET',
    },
    collection => {
        method   => 'POST',
        optional => [qw( add remove )]
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};


sub collection : Path('/ws/1/collection')
{
    my ($self, $c) = @_;

    $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);

    if ($c->req->method eq 'POST') {
        $c->detach('add_remove');
    }
    else {
        $c->detach('list');
    }
}

sub list : Private
{
    my ($self, $c) = @_;

    my $offset  = $c->req->params->{offset} || 0;
    my $limit   = $c->req->params->{maxitems} || 100;
    $offset     = 0 if $offset < 0;
    $limit      = 100 if $limit > 100 || $limit < 1;

    my $collection_id = $c->model('Collection')->get_first_collection($c->user->id);
    my ($releases) = $c->model('Release')->find_by_collection($collection_id, $limit, $offset);

    $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
    $c->res->body(
        $self->serializer->xml(
            $self->gen->release_list({ count => scalar @$releases },
                map {
                    $self->gen->release({ id => $_->gid })
                } @$releases
            )
        )
    );
}

sub add_remove : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    if(my $collection_id = $c->model('Collection')->get_first_collection($c->user->id)) {
        my $add    = $c->req->params->{add}    || $c->req->params->{addAlbums}    || '';
        my $remove = $c->req->params->{remove} || $c->req->params->{removeAlbums} || '';

        my @can_add    = $self->_clean_mbid_list($c, split /\s*,\s*/, $add);
        my @can_remove = $self->_clean_mbid_list($c, split /\s*,\s*/, $remove);

        if (@can_add && @can_remove) {
            $self->bad_req($c, 'You cannot add and releases from a collection in the same call');
        }

        if (@can_add) {
            my @add = map { $_->id } values %{ $c->model('Release')->get_by_gids(@can_add) };
            $c->model('Collection')->add_releases_to_collection($collection_id, @add)
        }

        if (@can_remove) {
            my @remove = map { $_->id } values %{ $c->model('Release')->get_by_gids(@can_remove) };
            $c->model('Collection')->remove_releases_from_collection($collection_id, @remove);
        }
    }

    $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
    $c->res->body($self->serializer->xml(''));
}

sub _clean_mbid_list
{
    my ($self, $c, @mbids) = @_;

    my @ok;
    for my $mbid (@mbids) {
        trim_in_place($mbid);
        $self->bad_req($c, 'You must supply a list of valid MBIDs')
            if (!is_guid($mbid));

        push @ok, $mbid;
    }

    return @ok;
}


__PACKAGE__->meta->make_immutable;
1;
