package MusicBrainz::Server::Controller::AutoEditorElection;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use Exception::Class;
use MusicBrainz::Server::Form::AutoEditorElection::Propose;

__PACKAGE__->config(namespace => 'elections');

sub elections : Path('') Form('AutoEditorElection::Propose')
{
    my ($self, $c) = @_;

    $c->stash->{elections} = $c->model('AutoEditorElection')->elections(
        with_candidate => 1
    );
}

sub details : Path('') Args(1) Form('AutoEditorElection::Vote')
{
    my ($self, $c, $election) = @_;

    $c->stash->{election} = $election =
        $c->model('AutoEditorElection')->new_from_id($election, with_editors => 1)
            or $c->detach('/error_404');

    $c->stash->{votes} = $election->votes(with_voters => 1);
}

sub cancel : Local Args(1)
{
    my ($self, $c, $election) = @_;
    $c->forward('login');

    if (!$c->form_posted)
    {
        # Require POST as this action is non-idempotent
        $c->response->redirect($c->uri_for('/elections', $election));
        $c->detach;
    }

    eval {
        $election = $c->model('AutoEditorElection')->new_from_id($election)
            or $c->detach('/error_404');
        $election->cancel($c->user);
    };

    if (my $e = Exception::Class->caught('EditorIneligibleException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'You may not cancel elections you did not propose'
        );
    }
    elsif (my $e = Exception::Class->caught('ElectionClosedException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'This election has already been closed'
        );
    }
    else
    {
        $c->response->redirect($c->uri_for('/elections', $election->id));
    }
}

sub propose : Local Form('AutoEditorElection::Propose')
{
    my ($self, $c) = @_;
    $c->forward('login');
    
    return unless $self->submit_and_validate($c);

    my $form = $self->form;
    my $editor = $c->model('User')->load({ username => $form->value('editor') });

    my $election = eval {
        $c->model('AutoEditorElection')->propose($editor, $c->user);
    };

    my $e;
    if ($e = Exception::Class->caught('AlreadyAutoEditorException'))
    {
        $form->field('editor')->add_error('This editor is already an auto-editor.');
    }
    elsif ($e = Exception::Class->caught('EditorIneligibleException'))
    {
        $form->field('editor')->add_error('This editor is ineligible to become an auto-editor.');
    }
    elsif ($e = Exception::Class->caught('ElectionAlreadyExistsException'))
    {
        $c->response->redirect($c->uri_for('/elections', $e->election_id));
    }
    else
    {
        $c->stash->{election_id} = $election->id;
        $c->stash->{candidate} = $editor;
        $c->stash->{template} = 'elections/proposed.tt';
    }
}

sub second : Local Args(1) Form('AutoEditorElection::Vote')
{
    my ($self, $c, $election) = @_;
    $c->forward('login');

    if (!$c->form_posted)
    {
        # Require POST as this action is non-idempotent
        $c->response->redirect($c->uri_for('/elections', $election));
        $c->detach;
    }

    eval {
        $election = $c->model('AutoEditorElection')->new_from_id($election);
        $election->second($c->user);
    };

    my $e;
    if ($e = Exception::Class->caught('EditorIneligibleException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'You are not eligible to second this election'
        );
    }
    elsif ($e = Exception::Class->caught('ElectionOpenException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'This election is aleady open'
        );
    }
    elsif ($e = Exception::Class->caught('ElectionClosedException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'This election has closed'
        );
    }
    else
    {
        # All good, redirect back to the election details page
        $c->response->redirect($c->uri_for('/elections', $election->id));
    }
}

sub vote : Local Args(1) Form('AutoEditorElection::Vote')
{
    my ($self, $c, $election) = @_;
    $c->forward('login');

    if(!$self->submit_and_validate($c))
    {
        $c->response->redirect($c->uri_for('/elections', $election));
        $c->detach;
    }

    eval {
        $election = $c->model('AutoEditorElection')->new_from_id($election);
        $election->vote($c->user, $self->form->value('vote'));
    };

    my $e;
    if ($e = Exception::Class->caught('EditorIneligibleException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'You are not eligible to vote on this election'
        );
    }
    elsif ($e = Exception::Class->caught('ElectionNotReadyException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'This election is not yet open for voting'
        );
    }
    elsif ($e = Exception::Class->caught('ElectionClosedException'))
    {
        $c->stash(
            template => 'elections/problem.tt',
            message  => 'This election has closed'
        );
    }
    else
    {
        # All good, redirect back to the election details page
        $c->response->redirect($c->uri_for('/elections', $election->id));
    }
}

sub login : Private
{
    my ($self, $c) = @_;
    $c->forward('/user/login');

    if (!$c->user->is_auto_editor)
    {
        $c->stash->{template} = 'elections/no_privs.tt';
        $c->detach;
    }
}

1;