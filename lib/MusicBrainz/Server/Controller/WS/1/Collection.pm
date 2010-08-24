package MusicBrainz::Server::Controller::WS::1::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';
use MusicBrainz::Server::Validation;

with 'MusicBrainz::Server::Controller::WS::1::Role::Serializer';
with 'MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration';

sub collection : Path('/ws/1/collection')
{
    my ($self, $c) = @_;

    $c->authenticate({}, 'webservice');

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

    my $list_id = $c->model('List')->get_first_list($c->user->id);
    my ($releases) = $c->model('Release')->find_by_list($list_id, $limit, $offset);

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

    my $list_id = $c->model('List')->get_first_list($c->user->id);

    my @can_add    = $self->_clean_mbid_list(split ',', $c->req->params->{add} || '');
    my @can_remove = $self->_clean_mbid_list(split ',', $c->req->params->{remove} || '');

    if (@can_add && @can_remove) {
        $self->bad_req('You cannot add and releases from a collection in the same call');
    }

    if (@can_add) {
        my @add = map { $_->id } values %{ $c->model('Release')->get_by_gids(@can_add) };
        $c->model('List')->add_releases_to_list($list_id, @add)
    }

    if (@can_remove) {
        my @remove = map { $_->id } values %{ $c->model('Release')->get_by_gids(@can_remove) };
        $c->model('List')->remove_releases_from_list($list_id, @remove);
    }

    $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
    $c->res->body($self->serializer->xml(''));
}

sub _clean_mbid_list
{
    my ($self, @mbids) = @_;

    my @ok;
    for my $mbid (@mbids) {
        MusicBrainz::Server::Validation::TrimInPlace($mbid);
        $self->bad_req('You must supply a list of valid MBIDs')
            if (!MusicBrainz::Server::Validation::IsGUID($mbid));

        push @ok, $mbid;
    }

    return @ok;
}


__PACKAGE__->meta->make_immutable;
1;
