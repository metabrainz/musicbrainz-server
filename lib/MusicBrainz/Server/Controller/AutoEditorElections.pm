package MusicBrainz::Server::Controller::AutoEditorElections;
BEGIN { use Moose; extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
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

    $c->stash(
        current_view => 'Node',
        component_path => 'elections/Index.js',
        component_props => {elections => to_json_array(\@elections)},
    );
}

sub nominate : Path('nominate') Args(1) RequireAuth(auto_editor) SecureForm
{
    my ($self, $c, $editor) = @_;

    my $candidate = $c->model('Editor')->get_by_name($editor);
    $c->detach('/error_404')
        unless $c->user->can_nominate($candidate);

    my $form = $c->form( form => 'SecureConfirm' );
    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            my $url = $c->uri_for_action('/user/profile', [ $candidate->name ]);
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

    $c->stash(
        current_view => 'Node',
        component_path => 'elections/Nominate.js',
        component_props => {
            candidate => $candidate->TO_JSON,
            form => $form->TO_JSON,
        },
    );
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
        $c->stash( message  => l(q('{id}' is not a valid election ID), { id => $id }) );
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
        current_view => 'Node',
        component_path => 'elections/Show.js',
        component_props => {election => $election->TO_JSON},

    );
}

sub second : Chained('load') Args(0) RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $election = $c->stash->{election};

    my $form = $c->form( form => 'Confirm' );
    if ($c->form_posted_and_valid($form)) {
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

    my $form = $c->form( form => 'Confirm' );
    if ($c->form_posted_and_valid($form)) {
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
    if ($c->form_posted_and_valid($form)) {
        $c->model('AutoEditorElection')->vote($election, $c->user,
                                              $form->field('vote')->value);
    }

    my $url = $c->uri_for_action('/elections/show', [ $election->id ]);
    $c->res->redirect($url);
    $c->detach;
}

1;

