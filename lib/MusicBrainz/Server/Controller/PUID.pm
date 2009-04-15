package MusicBrainz::Server::Controller::PUID;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Validation;

__PACKAGE__->config(
    model       => 'PUID',
    entity_name => 'puid',
);

sub base : Chained('/') PathPart('puid') CaptureArgs(0) { }

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $tracks = $self->entity->tracks(load_tracks => 1);
    $c->stash(
        tracks => [ map { +{
            track   => $_,
            release => $c->model('Release')->load($_->release)
        } } @$tracks ]
    );
}

sub remove : Chained('load') PathPart Form('Confirm')
{
    my ($self, $c) = @_;
    $c->forward('/user/login');

    my $track_id = $c->req->params->{track};
    my $join_id  = $c->req->params->{join};

    if (!MusicBrainz::Server::Validation::IsGUID($track_id) ||
        !MusicBrainz::Server::Validation::IsNonNegInteger($join_id))
    {
        $c->response->redirect(
            $c->uri_for($c->action, 'show', [ $self->entity->puid ])
        );
        $c->detach;
    }

    my $track = $c->model('Track')->load($track_id);
    $track->artist->LoadFromId;
    $c->stash( track => $track );

    return unless $self->submit_and_validate($c);

    $c->model('Moderation')->insert($self->form->value('edit_note'),
        type       => ModDefs::MOD_REMOVE_PUID,
        track      => $track,
        puid       => $self->entity,
        puidjoinid => $join_id,
    );

    $c->res->redirect($c->entity_url($track, 'show'));
}

1;