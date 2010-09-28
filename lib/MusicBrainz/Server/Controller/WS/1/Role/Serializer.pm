package MusicBrainz::Server::Controller::WS::1::Role::Serializer;
use Moose::Role;
use namespace::autoclean;

use aliased 'MusicBrainz::Server::WebService::XMLSerializerV1';

has 'serializer' => (
    is => 'ro',
    default => sub { XMLSerializerV1->new }
);

sub bad_req
{
    my ($self, $c, $error) = @_;
    $c->res->status(400);
    $c->res->content_type("text/plain; charset=utf-8");
    $c->res->body($self->serializer->output_error($error));
    $c->detach;
}

1;
