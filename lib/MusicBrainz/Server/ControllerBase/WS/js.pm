package MusicBrainz::Server::ControllerBase::WS::js;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

sub serializers {
    return {
        json => 'MusicBrainz::Server::WebService::JSONSerializer'
    };
}

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub begin : Private { }

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c, $self->serializers) or $c->detach('bad_req');
}

sub get : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize_entity($self->entity_routine, $entity));
}

# Don't render with TT
sub end : Private { }

sub entity_routine { '_generic' }

1;
