package MusicBrainz::Server::Controller::AutoEditorElections;
BEGIN { use Moose; extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Translation qw( l );
use Try::Tiny;

__PACKAGE__->config( namespace => 'elections' );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'AutoEditorElection',
    entity_name => 'election',
};

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
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
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

    $c->stash( candidate => $candidate );
}

sub base : Chained('/') PathPart('election') CaptureArgs(0) { }

sub _load {
    my ($self, $c, $id) = @_;

    if ($id =~ /^\d+$/) {
        my $election;

        try {
            $election = $c->model('AutoEditorElection')->get_by_id($id);
        }
        catch {
            if (ref ($_) eq 'MusicBrainz::Server::Exceptions::InvalidInput') {
                $c->stash( message => $_->message );
                $c->detach('/error_500');
            }
        };

        return $election;
    }
    else {
        $c->stash( message  => l("'{id}' is not a valid election ID", { id => $id }) );
        $c->detach('/error_400');
    }
}

sub show : Chained('load') PathPart('') Args(0)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};
    $c->model('AutoEditorElection')->load_votes($election);
    $c->model('AutoEditorElection')->load_editors($election);

    $c->stash(
        can_vote => $c->user_exists && $election->can_vote($c->user),
        can_second => $c->user_exists && $election->can_second($c->user),
        can_cancel => $c->user_exists && $election->can_cancel($c->user),
        can_see_vote_count => $election->can_see_vote_count($c->user),
    );
}

sub second : Chained('load') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};

    my $form = $c->form( form => 'Submit' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('AutoEditorElection')->second($election, $c->user);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

sub cancel : Chained('load') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};
    $c->detach('/error_403')
        unless $election->proposer_id == $c->user->id;

    my $form = $c->form( form => 'Submit' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('AutoEditorElection')->cancel($election, $c->user);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

sub vote : Chained('load') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};

    my $form = $c->form( form => 'AutoEditorElection::Vote' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('AutoEditorElection')->vote($election, $c->user,
                                              $form->field('vote')->value);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

1;

