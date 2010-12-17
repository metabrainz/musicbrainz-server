package MusicBrainz::Server::Controller::ReleaseEditor::Edit;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' }

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Edit' => 'Wizard';

sub edit : Chained('/release/load') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    my $wizard = Wizard->new(
        release => $release,
        c => $c,
        on_cancel => sub { $self->cancelled($c) },
        on_submit => sub { $self->submitted($c, $release) }
    );
    $wizard->run;
}

sub cancelled
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]))
}

sub submitted {
    my ($self, $c, $release) = @_;
    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
    $c->detach;
}

1;
