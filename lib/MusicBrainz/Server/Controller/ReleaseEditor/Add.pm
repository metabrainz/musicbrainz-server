package MusicBrainz::Server::Controller::ReleaseEditor::Add;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' };

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Add' => 'Wizard';

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $wizard = Wizard->new(
        c => $c,
        on_submit => sub {
            my $wizard = shift;
            $c->response->redirect(
                $c->uri_for_action('/release/show', [ $wizard->release->gid ])
            );
            $c->detach
        },
        on_cancel => sub {
            $self->cancelled($c)
        }
    );
    $wizard->run;
}

sub cancelled {
    my ($self, $c) = @_;

    my $rg_gid = $c->req->query_params->{'release-group'};
    my $label_gid = $c->req->query_params->{'label'};
    my $artist_gid = $c->req->query_params->{'artist'};

    if ($rg_gid)
    {
        $c->response->redirect($c->uri_for_action('/release_group/show', [ $rg_gid ]));
    }
    elsif ($label_gid)
    {
        $c->response->redirect($c->uri_for_action('/label/show', [ $label_gid ]));
    }
    elsif ($artist_gid)
    {
        $c->response->redirect($c->uri_for_action('/artist/show', [ $artist_gid ]));
    }
    else
    {
        $c->response->redirect($c->uri_for_action('/index'));
    }
}

1;
