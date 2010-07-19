package MusicBrainz::Server::Controller::User;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use Digest::SHA1 qw(sha1_base64);
use MusicBrainz::Server::Authentication::User;
use MusicBrainz::Server::Validation qw( is_positive_integer );
use UserPreference;

use MusicBrainz::Server::Form::User::Login;

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

    $c->forward('login');
    $c->detach('/user/profile/view', [ $c->user->name ]);
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

sub login : Path('/login')
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile/view',
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

=head2 register

Display a form allowing new users to register on the site. When a POST
request is received, we validate the data and attempt to create the
new user.

=cut

sub register : Path('/register')
{
    my ($self, $c) = @_;

    my $form = $c->form(register_form => 'User::Register');

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {

        my $editor = $c->model('Editor')->insert({
            name => $form->field('username')->value,
            password => $form->field('password')->value,
        });

        my $email = $form->field('email')->value;
        if ($email) {
            $self->_send_confirmation_email($c, $editor, $email);
        }

        my $user = MusicBrainz::Server::Authentication::User->new_from_editor($editor);
        $c->set_authenticated($user);

        $c->response->redirect($c->uri_for_action('/user/profile/view', [ $user->name ]));
        $c->detach;
    }

    $c->stash(
        register_form => $form,
        template      => 'user/register.tt',
    );
}

=head2 _send_confirmation_email

Send out an email allowing users to confirm their email address

=cut

sub _send_confirmation_email
{
    my ($self, $c, $editor, $email) = @_;

    my $time = time();
    my $verification_link = $c->uri_for_action('/user/verify_email', {
        userid => $editor->id,
        email  => $email,
        time   => $time,
        chk    => $self->_checksum($email, $editor->id, $time),
    });

    $c->model('Email')->send_email_verification(
        email             => $email,
        verification_link => $verification_link,
    );
}

sub _checksum
{
    my ($self, $email, $uid, $time) = @_;
    return sha1_base64("$email $uid $time " . DBDefs::SMTP_SECRET_CHECKSUM);
}

=head2 verify

Verify the email address (this is the URL handed out in "verify your email
address" emails)

=cut

sub verify_email : Path('/verify-email')
{
    my ($self, $c) = @_;

    my $user_id = $c->request->params->{userid};
    my $email   = $c->request->params->{email};
    my $time    = $c->request->params->{time};
    my $key     = $c->request->params->{chk};

    unless (is_positive_integer($user_id) && $user_id) {
        $c->stash(
            message => $c->gettext('The user ID is missing or, is in an invalid format.'),
            template => 'user/verify_email_error.tt',
        );
    }

    unless ($email) {
        $c->stash(
            message => $c->gettext('The email address is missing.'),
            template => 'user/verify_email_error.tt',
        );
    }

    unless (is_positive_integer($time) && $time) {
        $c->stash(
            message => $c->gettext('The time is missing, or is in an invalid format.'),
            template => 'user/verify_email_error.tt',
        );
        $c->detach;
    }

    unless ($key) {
        $c->stash(
            message => $c->gettext('The key is missing.'),
            template => 'user/verify_email_error.tt',
        );
        $c->detach;
    }

    unless ($self->_checksum($email, $user_id, $time) eq $key) {
        $c->stash(
            message => $c->gettext('The checksum is invalid, please double check your email.'),
            template => 'user/verify_email_error.tt',
        );
        $c->detach;
    }

    if (($time + &DBDefs::EMAIL_VERIFICATION_TIMEOUT) < time()) {
        $c->stash(
            message => $c->gettext('Sorry, this email verification link has expired.'),
            template => 'user/verify_email_error.tt',
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($user_id);
    unless (defined $editor) {
        $c->stash(
            message => $c->gettext('User with id {user_id} could not be found.',
                                   { user_id => $user_id }),
            template => 'user/verify_email_error.tt',
        );
        $c->detach;
    }

    $c->model('Editor')->update_email($editor, $email);

    if ($c->user_exists) {
        $c->user->email($editor->email);
        $c->user->email_confirmation_date($editor->email_confirmation_date);
        $c->persist_user();
    }

    $c->stash->{template} = 'user/verified.tt';
}

sub _reset_password_checksum
{
    my ($self, $id, $time) = @_;
    return sha1_base64("reset_password $id $time " . DBDefs::SMTP_SECRET_CHECKSUM);
}

sub _send_password_reset_email
{
    my ($self, $c, $editor) = @_;

    my $time = time();
    my $reset_password_link = $c->uri_for_action('/user/reset_password', {
        id => $editor->id,
        time => $time,
        key => $self->_reset_password_checksum($editor->id, $time),
    });

    $c->model('Email')->send_password_reset_request(
        user                => $editor,
        reset_password_link => $reset_password_link,
    );
}

sub lost_password : Path('/lost-password')
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(template => 'user/lost_password_sent.tt');
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostPassword' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $username = $form->field('username')->value;
        my $email = $form->field('email')->value;

        my $editor = $c->model('Editor')->get_by_name($username);
        if (!defined $editor) {
            $form->field('username')->add_error(
                $c->gettext('There is no user with this username'));
        }
        else {
            if ($editor->email && $editor->email ne $email) {
                $form->field('email')->add_error(
                    $c->gettext('There is no user with this username and email'));
            }
            else {
                $self->_send_password_reset_email($c, $editor);
                $c->response->redirect($c->uri_for_action('/user/lost_password',
                                                          { sent => 1}));
                $c->detach;
            }
        }
    }

    $c->stash->{form} = $form;
}

sub reset_password : Path('/reset-password')
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(template => 'user/reset_password_ok.tt');
        $c->detach;
    }

    my $editor_id = $c->request->params->{id};
    my $time = $c->request->params->{time};
    my $key = $c->request->params->{key};

    if (!$editor_id || !$time || !$key) {
        $c->stash(
            message => $c->gettext('Missing required parameter.'),
            template => 'user/reset_password_error.tt',
        );
        $c->detach;
    }

    if ($time + &DBDefs::EMAIL_VERIFICATION_TIMEOUT < time()) {
        $c->stash(
            message => $c->gettext('Sorry, this password reset link has expired.'),
            template => 'user/reset_password_error.tt',
        );
        $c->detach;
    }

    if ($self->_reset_password_checksum($editor_id, $time) ne $key) {
        $c->stash(
            message => $c->gettext('The checksum is invalid, please double check your email.'),
            template => 'user/reset_password_error.tt',
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($editor_id);
    if (!defined $editor) {
        $c->stash(
            message => $c->gettext('User with id {user_id} could not be found',
                                   { user_id => $editor_id }),
            template => 'user/reset_password_error.tt',
        );
        $c->detach;
    }

    my $form = $c->form( form => 'User::ResetPassword' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {

        my $password = $form->field('password')->value;
        $c->model('Editor')->update_password($editor, $password);

        $c->model('Editor')->load_preferences($editor);
        my $user = MusicBrainz::Server::Authentication::User->new_from_editor($editor);
        $c->set_authenticated($user);

        $c->response->redirect($c->uri_for_action('/user/reset_password', { ok => 1 }));
        $c->detach;
    }

    $c->stash->{form} = $form;
}

sub lost_username : Path('/lost-username')
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(template => 'user/lost_username_sent.tt');
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostUsername' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $email = $form->field('email')->value;

        my @editors = $c->model('Editor')->find_by_email($email);
        if (!@editors) {
            $form->field('email')->add_error(
                $c->gettext('There is no user with this email'));
        }
        else {
            foreach my $editor (@editors) {
                $c->model('Email')->send_lost_username( user => $editor );
            }
            $c->response->redirect($c->uri_for_action('/user/lost_username',
                                                      { sent => 1}));
            $c->detach;
        }
    }

    $c->stash->{form} = $form;
}

=head2 edit

Display a form to allow users to edit their profile, or (if a POST
request is received), update the profile data in the database.

=cut

sub edit : Path('/account/edit') RequireAuth
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(
            template => 'user/edit_ok.tt',
            email_sent => $c->request->params->{email} ? 1 : 0,
            email => $c->request->params->{email},
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($c->user->id);

    my $form = $c->form( form => 'User::EditProfile', item => $editor );

    if ($c->form_posted && $form->process( params => $c->req->params )) {

        $c->model('Editor')->update_profile($editor,
                                            $form->field('website')->value,
                                            $form->field('biography')->value);

        my %args = ( ok => 1 );
        my $old_email = $editor->email || '';
        my $new_email = $form->field('email')->value || '';
        if ($old_email ne $new_email) {
            if ($new_email) {
                $self->_send_confirmation_email($c, $editor, $new_email);
                $args{email} = $new_email;
            }
            else {
                $c->model('Editor')->update_email($editor, undef);
            }
        }

        $c->response->redirect($c->uri_for_action('/user/edit', \%args));
        $c->detach;
    }
}

=head2 change_password

Allow users to change their password. This displays a form prompting
for their old password and a new password (with confirmation), which
when use to update the database data when we receive a valid POST request.

=cut

sub change_password : Path('/account/change-password') RequireAuth
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(template => 'user/change_password_ok.tt');
        $c->detach;
    }

    my $form = $c->form( form => 'User::ChangePassword' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {

        my $password = $form->field('password')->value;
        $c->model('Editor')->update_password($c->user, $password);

        $c->response->redirect($c->uri_for_action('/user/change_password', { ok => 1 }));
        $c->detach;
    }
}

sub base : Chained PathPart('user') CaptureArgs(1)
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name);
    $c->detach('/error_404')
        unless defined $user;

    $c->stash( user => $user );

    if ($c->user_exists && $c->user->id == $user->id)
    {
        $c->stash->{viewing_own_profile} = 1;
        $c->stash->{show_collection} = 1;
    }
    else
    {
        $c->model('Editor')->load_preferences($user);
        $c->stash->{show_collection} = $user->preferences->public_collection;
    }

    $c->stash->{show_flags} = 1 if ($c->user_exists && $c->user->is_account_admin);
}


=head2 profile

Display a users profile page.

=cut

sub profile : Local Args(1)
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name);

    $c->detach('/error_404')
        if (!defined $user);

    if ($c->user_exists && $c->user->id == $user->id)
    {
        $c->stash->{viewing_own_profile} = 1;
        $c->stash->{show_collection} = 1;
    }
    else
    {
        $c->model('Editor')->load_preferences($user);
        $c->stash->{show_collection} = $user->preferences->public_collection;
    }

    $c->stash->{show_flags} = 1 if ($c->user_exists && $c->user->is_account_admin);

    my $subscr_model = $c->model('Editor')->subscription;
    $c->stash->{subscribed}       = $c->user_exists && $subscr_model->check_subscription($c->user->id, $user->id);
    $c->stash->{subscriber_count} = $subscr_model->get_subscribed_editor_count($user->id);
    $c->stash->{votes}            = $c->model('Vote')->editor_statistics($user->id);

    $c->stash(
        user     => $user,
        template => 'user/profile.tt',
    );
}

=head2 contact

Allows users to contact other users via email

=cut

sub contact : Chained('base') RequireAuth
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

=head2 preferences

Change the users preferences

=cut

sub preferences : Path('/account/preferences') RequireAuth
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(template => 'user/preferences_ok.tt');
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    $c->model('Editor')->load_preferences($editor);

    my $form = $c->form( form => 'User::Preferences', item => $editor->preferences );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('Editor')->save_preferences($editor, $form->values);

        $c->user->preferences($editor->preferences);
        $c->persist_user();

        $c->response->redirect($c->uri_for_action('/user/preferences', { ok => 1 }));
        $c->detach;
    }
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
