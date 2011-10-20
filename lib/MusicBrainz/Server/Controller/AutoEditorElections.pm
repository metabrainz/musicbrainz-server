package MusicBrainz::Server::Controller::AutoEditorElections;
BEGIN { use Moose; extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config( namespace => 'elections' );

sub index : Path('')
{
    my ($self, $c) = @_;

    my @elections = $c->model('AutoEditorElection')->get_all();
    $c->model('AutoEditorElection')->load_editors(@elections);

    $c->stash( elections => \@elections );
}

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
            my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
            $c->res->redirect($url);
            $c->detach;
        }
    }

    $c->stash( candidate => $candidate, form => $form );
}

sub election : Chained('/') PartPart('election') CaptureArgs(1)
{
    my ($self, $c, $id) = @_;

    my $election = $c->model('AutoEditorElection')->get_by_id($id);
    $c->detach('/error_404') unless defined $election;

    $c->stash( election => $election );
}

sub show : Chained('election') PathPart('') Args(0)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};
    $c->model('AutoEditorElection')->load_editors($election);
}

sub second : Chained('election') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('AutoEditorElection')->second($election, $c->user);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

sub cancel : Chained('election') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};
    $c->detach('/error_403')
        unless $election->proposer_id == $c->user->id;

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('AutoEditorElection')->cancel($election);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

sub vote : Chained('election') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};

    my $form = $c->form( form => 'AutoEditorElection::Vote' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('AutoEditorElection')->vote($election, $c->user,
                                              $form->field('vote')->value);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

1;

