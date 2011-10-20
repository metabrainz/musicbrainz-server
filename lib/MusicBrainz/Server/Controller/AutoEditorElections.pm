package MusicBrainz::Server::Controller::AutoEditorElections;
BEGIN { use Moose; extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config( namespace => 'elections' );

sub index : Path('') RequireAuth { }

sub nominate : Path('nominate') Args(1) RequireAuth(auto_editor)
{
    my ($self, $c, $editor) = @_;

    my $candidate = $c->model('Editor')->get_by_name($editor);
    $c->detach('/error_404') unless defined $candidate or $candidate->is_auto_editor;

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {
        if ($form->field('cancel')->input) {
            my $url = $c->uri_for_action('/user/profile', [ $nominee->name ]);
            $c->res->redirect($url);
            $c->detach;
        }
        else {
            my $election = $c->model('AutoEditorElection')->nominate($candidate, $c->user);
            my $url = $c->uri_for_action('/elections/show', $election->id);
            $c->res->redirect($url);
            $c->detach;
        }
    }

    $c->stash( candidate => $candidate, form => $form );
}

sub show : Path('') Args(1) RequireAuth
{
    my ($self, $c, $id) = @_;

    my $election = $c->model('AutoEditorElection')->get_by_id($id);
    $c->detach('/error_404') unless defined $election;

    $c->model('AutoEditorElection')->load_editors($election);

    $c->stash( election => $election );
}

1;

