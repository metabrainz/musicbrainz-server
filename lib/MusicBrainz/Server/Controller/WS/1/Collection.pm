package MusicBrainz::Server::Controller::WS::1::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

with 'MusicBrainz::Server::Controller::WS::1::Role::Serializer';

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
    $c->res->body($self->serializer->xml( List->new->serialize($releases) ));
}

__PACKAGE__->meta->make_immutable;
1;
