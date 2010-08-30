package MusicBrainz::Server::Controller::User;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use Digest::SHA1 qw(sha1_base64);
use MusicBrainz::Server::Authentication::User;

__PACKAGE__->config(
    entity_name => 'user',
    paging_limit => 25,
);

=head1 NAME

MusicBrainz::Server::Controller::User - Catalyst Controller to handle
user authentication and profile management

=head1 DESCRIPTION

The user controller handles users logging in and logging out, the
registration or administration of accounts, and the viewing/updating of
profile pages.

=head1 METHODS

=head2 index

If the user is currently logged in redirect them to their profile page,
otherwise redirect the user to the login page.

=cut

sub index : Private
{
    my ($self, $c) = @_;

    # Can't set an attribute on a private action; manually inserting detatch code.
    $c->detach('/error_mirror_404') if ($c->stash->{server_details}->{is_slave_db});

    $c->forward('login');
    $c->detach('/user/profile', [ $c->user->name ]);
}

sub do_login : Private
{
    my ($self, $c) = @_;
    return 1 if $c->user_exists;

    my $form = $c->form(form => 'User::Login');
    my $redirect = defined $c->req->query_params->{uri}
        ? $c->req->query_params->{uri}
        : $c->req->uri;

    if ($c->form_posted && $form->process(params => $c->req->params))
    {
        if( !$c->authenticate({ username => $form->field("username")->value,
                                password => $form->field("password")->value }) )
        {
            # Bad username / password combo
            $c->log->info('Invalid username/password');
            $c->stash( bad_login => 1 );
        }
        else
        {
            # Logged in OK
            $c->response->redirect($redirect);
            $c->detach;
        }
    }

    # Form not even posted
    $c->stash(
        template => 'user/login.tt',
        login_form => $form,
        redirect => $redirect,
    );

    $c->stash->{required_login} = 1
        unless exists $c->stash->{required_login};

    $c->detach;
}

sub login : Path('/login') ForbiddenOnSlaves
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile',
                                                 [ $c->user->name ]));
        $c->detach;
    }

    $c->stash( required_login => 0 );
    $c->forward('/user/do_login');
}

sub logout : Path('/logout')
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->logout;
        $c->delete_session;
    }

    $self->redirect_back($c, '/logout', '/');
}

sub base : Chained PathPart('user') CaptureArgs(0) HiddenOnSlaves { }

sub _load
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name) or return;
    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $user->id;
    $c->stash->{show_flags}          = $c->user_exists && $c->user->is_account_admin;

    return $user;
}

=head2 contact

Allows users to contact other users via email

=cut

sub contact : Chained('base') RequireAuth HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $editor = $c->stash->{user};
    unless ($editor->email) {
        $c->stash(
            title    => $c->gettext('Send Email'),
            message  => $c->gettext(
                'The editor {name} has no email address attached to their account.',
                { name => $editor->name }),
            template => 'user/message.tt',
        );
        $c->detach;
    }

    if (exists $c->req->params->{sent}) {
        $c->stash( template => 'user/email_sent.tt' );
        $c->detach;
    }

    my $form = $c->form( form => 'User::Contact' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {

        my $result = $c->model('Email')->send_message_to_editor(
            from           => $c->user,
            to             => $editor,
            subject        => $form->value->{subject},
            message        => $form->value->{body},
            reveal_address => $form->value->{reveal_address},
            send_to_self   => $form->value->{send_to_self},
        );

        $c->res->redirect($c->uri_for_action('/user/contact', [ $editor->name ], { sent => $result }));
        $c->detach;
    }
}

sub lists : Chained('load') PathPart('lists')
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $show_private = $c->stash->{viewing_own_profile};

    my $lists = $self->_load_paged($c, sub {
        $c->model('List')->find_by_editor($user->id, $show_private, shift, shift);
    });

    $c->stash(
        user => $user,
        lists => $lists,
    );
}

sub profile : Chained('load') PathPart('') HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $subscr_model = $c->model('Editor')->subscription;
    $c->stash->{subscribed}       = $c->user_exists && $subscr_model->check_subscription($c->user->id, $user->id);
    $c->stash->{subscriber_count} = $subscr_model->get_subscribed_editor_count($user->id);
    $c->stash->{votes}            = $c->model('Vote')->editor_statistics($user->id);

    $c->stash(
        user     => $user,
        template => 'user/profile.tt',
    );
}

sub ratings : Chained('load') PathPart('ratings') HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    if (!defined $c->user || $c->user->id != $user->id)
    {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_ratings;
    }

    my $ratings = $c->model('Editor')->get_ratings ($user);

    $c->stash(
        user => $user,
        ratings => $ratings,
        template => 'user/ratings.tt',
    );
}

sub subscribers : Chained('load') PathPart('subscribers') RequireAuth HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $entities = $self->_load_paged($c, sub {
        $c->model('Editor')->find_subscribers ($user->id, shift, shift);
    });

    $c->model('Editor')->load_preferences (@$entities) if (@$entities);

    my $private = 0;
    my @filtered = grep {
        $private += 1 unless $_->preferences->public_subscriptions;
        $_->preferences->public_subscriptions;
    } @$entities;

    $c->stash(
        user => $user,
        private_subscribers => $private,
        $self->{entities} => \@filtered,
        template => 'user/subscribers.tt',
    );
}

sub tags : Chained('load') PathPart('tags')
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    if (!defined $c->user || $c->user->id != $user->id)
    {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_tags;
    }

    my $tags = $c->model('Editor')->get_tags ($user);

    $c->stash(
        user => $user,
        tags => $tags,
        template => 'user/tags.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
