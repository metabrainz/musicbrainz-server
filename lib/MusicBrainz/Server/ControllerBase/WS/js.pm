package MusicBrainz::Server::ControllerBase::WS::js;
use Moose;
use MusicBrainz::Server::WebService::Format;
use MusicBrainz::Server::WebService::JSONSerializer;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::WebService::Format';

sub serializers {
    [
        'MusicBrainz::Server::WebService::JSONSerializer',
    ]
}

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $self->output_error($c);
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->res->status(404);
    $self->output_error($c);
}

sub output_error : Private
{
    my ($self, $c) = @_;
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub begin : Private {
    my ($self, $c) = @_;

    $c->stash->{current_view} = 'WS';
    $c->stash->{serializer} = MusicBrainz::Server::WebService::JSONSerializer->new;
}

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c) or $c->detach('bad_req');
}

# Don't render with TT
sub end : Private { }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
