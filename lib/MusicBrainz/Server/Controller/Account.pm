package MusicBrainz::Server::Controller::Account;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use namespace::autoclean;
use Digest::SHA qw(sha1_base64);
use MusicBrainz::Server::Translation qw(l ln );
use MusicBrainz::Server::Validation qw( is_positive_integer );
use Try::Tiny;
use Captcha::reCAPTCHA;

sub index : Path('/account') RequireAuth
{
    my ($self, $c) = @_;
    $c->response->redirect($c->uri_for_action('/user/profile', [ $c->user->name ]));
    $c->detach;
}

sub begin : Private
{
    my ($self, $c) = @_;
    $c->forward('/begin');
    $c->stash->{viewing_own_profile} = 1;
    $c->stash->{user}                = $c->user;
}

=head2 verify

Verify the email address (this is the URL handed out in "verify your email
address" emails)

=cut

sub verify_email : Path('/verify-email') ForbiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $user_id = $c->request->params->{userid};
    my $email   = $c->request->params->{email};
    my $time    = $c->request->params->{time};
    my $key     = $c->request->params->{chk};

    unless (is_positive_integer($user_id) && $user_id) {
        $c->stash(
            message => l('The user ID is missing or is in an invalid format.'),
            template => 'account/verify_email_error.tt',
        );
    }

    unless ($email) {
        $c->stash(
            message => l('The email address is missing.'),
            template => 'account/verify_email_error.tt',
        );
    }

    unless (is_positive_integer($time) && $time) {
        $c->stash(
            message => l('The time is missing or is in an invalid format.'),
            template => 'account/verify_email_error.tt',
        );
        $c->detach;
    }

    unless ($key) {
        $c->stash(
            message => l('The verification key is missing.'),
            template => 'account/verify_email_error.tt',
        );
        $c->detach;
    }

    unless ($self->_checksum($email, $user_id, $time) eq $key) {
        $c->stash(
            message => l('The checksum is invalid, please double check your email.'),
            template => 'account/verify_email_error.tt',
        );
        $c->detach;
    }

    if (($time + DBDefs->EMAIL_VERIFICATION_TIMEOUT) < time()) {
        $c->stash(
            message => l('Sorry, this email verification link has expired.'),
            template => 'account/verify_email_error.tt',
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($user_id);
    unless (defined $editor) {
        $c->stash(
            message => l('The user with ID \'{user_id}\' could not be found.',
                                   { user_id => $user_id }),
            template => 'account/verify_email_error.tt',
        );
        $c->detach;
    }

    $c->model('Editor')->update_email($editor, $email);

    if ($c->user_exists) {
        $c->user->email($editor->email);
        $c->user->email_confirmation_date($editor->email_confirmation_date);
        $c->persist_user();
    }

    $c->stash->{template} = 'account/verified.tt';
}

sub _reset_password_checksum
{
    my ($self, $id, $time) = @_;
    return sha1_base64("reset_password $id $time " . DBDefs->SMTP_SECRET_CHECKSUM);
}

sub _send_password_reset_email
{
    my ($self, $c, $editor) = @_;

    my $time = time();
    my $reset_password_link = $c->uri_for_action('/account/reset_password', {
        id => $editor->id,
        time => $time,
        key => $self->_reset_password_checksum($editor->id, $time),
    });

    try {
        $c->model('Email')->send_password_reset_request(
            user                => $editor,
            reset_password_link => $reset_password_link,
        );
    }
    catch {
        $c->flash->{message} = l(
            'We were unable to send login information to your email address.  Please try again,
             however if you continue to experience difficulty contact us at support@musicbrainz.org.'
        );
    };
}

sub lost_password : Path('/lost-password') ForbiddenOnSlaves
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(template => 'account/lost_password_sent.tt');
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostPassword' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $username = $form->field('username')->value;
        my $email = $form->field('email')->value;

        my $editor = $c->model('Editor')->get_by_name($username);

        if (!defined $editor) {
            $form->field('username')->add_error(l('There is no user with this username'));
        }
        else {
            # HTML::FormHandler::Field::Email lowercases the email, so we should compare the lowercase version (MBS-6158)
            if ($editor->email && lc($editor->email) ne lc($email)) {
                $form->field('email')->add_error(l('There is no user with this username and email'));
            }
            elsif (!$editor->email) {
                $form->field('email')->add_error(l('We can\'t send a password reset email, because we have no email on record for this user.'));
            }
            else {
                $self->_send_password_reset_email($c, $editor);
                $c->response->redirect($c->uri_for_action('/account/lost_password',
                                                          { sent => 1}));
                $c->detach;
            }
        }
    }

    $c->stash->{form} = $form;
}

sub reset_password : Path('/reset-password') ForbiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(template => 'account/reset_password_ok.tt');
        $c->detach;
    }

    my $editor_id = $c->request->params->{id};
    my $time = $c->request->params->{time};
    my $key = $c->request->params->{key};

    if (!$editor_id || !$time || !$key) {
        $c->stash(
            message => l('Missing one or more required parameters.'),
            template => 'account/reset_password_error.tt',
        );
        $c->detach;
    }

    if ($time + DBDefs->EMAIL_VERIFICATION_TIMEOUT < time()) {
        $c->stash(
            message => l('Sorry, this password reset link has expired.'),
            template => 'account/reset_password_error.tt',
        );
        $c->detach;
    }

    if ($self->_reset_password_checksum($editor_id, $time) ne $key) {
        $c->stash(
            message => l('The checksum is invalid, please double check your email.'),
            template => 'account/reset_password_error.tt',
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($editor_id);
    if (!defined $editor) {
        $c->stash(
            message => l('The user with ID \'{user_id}\' could not be found.',
                                   { user_id => $editor_id }),
            template => 'account/reset_password_error.tt',
        );
        $c->detach;
    }

    my $form = $c->form( form => 'User::ResetPassword' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {

        my $password = $form->field('password')->value;
        $c->model('Editor')->update_password($editor->name, $password);

        $c->model('Editor')->load_preferences($editor);
        my $user = MusicBrainz::Server::Authentication::User->new_from_editor($editor);
        $c->set_authenticated($user);

        $c->response->redirect($c->uri_for_action('/account/reset_password', { ok => 1 }));
        $c->detach;
    }

    $c->stash->{form} = $form;
}

sub lost_username : Path('/lost-username') ForbiddenOnSlaves
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(template => 'account/lost_username_sent.tt');
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostUsername' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $email = $form->field('email')->value;

        my @editors = $c->model('Editor')->find_by_email($email);
        if (!@editors) {
            $form->field('email')->add_error(l('There is no user with this email'));
        }
        else {
            foreach my $editor (@editors) {
                try { $c->model('Email')->send_lost_username( user => $editor ) }
            }
            $c->response->redirect($c->uri_for_action('/account/lost_username',
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

sub edit : Local RequireAuth DenyWhenReadonly
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(
            template => 'account/edit_ok.tt',
            email_sent => $c->request->params->{email} ? 1 : 0,
            email => $c->request->params->{email},
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    $c->model('Area')->load($editor);
    $c->model('EditorLanguage')->load_for_editor($editor);

    my $form = $c->form( form => 'User::EditProfile', init_object => $editor );

    if ($c->form_posted && $form->process( params => $c->req->params )) {

        $c->model('Editor')->update_profile(
            $editor,
            $form->value
        );

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

        $c->model('EditorLanguage')->set_languages(
            $c->user->id,
            $form->field('languages')->value
        );

        $c->response->redirect($c->uri_for_action('/account/edit', \%args));
        $c->detach;
    }
}

=head2 change_password

Allow users to change their password. This displays a form prompting
for their old password and a new password (with confirmation), which
when use to update the database data when we receive a valid POST request.

=cut

sub change_password : Path('/account/change-password') RequireSSL DenyWhenReadonly
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->flash->{message} = l('Your password has been changed.');
        $c->response->redirect($c->uri_for_action('/user/login'));

        $c->detach;
    }

    $c->stash( mandatory => $c->req->query_params->{mandatory} );

    my $form = $c->form(
        form => 'User::ChangePassword',
        init_object => {
            username => $c->user_exists
                ? $c->user->name
                : ($c->req->query_parameters->{username} // '')
        }
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $password = $form->field('password')->value;
        $c->model('Editor')->update_password(
            $form->field('username')->value, $password);

        $c->response->redirect($c->uri_for_action('/account/change_password', { ok => 1 }));
        $c->detach;
    }
}

=head2 preferences

Change the users preferences

=cut

sub preferences : Path('/account/preferences') RequireAuth DenyWhenReadonly
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(template => 'account/preferences_ok.tt');
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    $c->model('Editor')->load_preferences($editor);

    my $form = $c->form( form => 'User::Preferences', item => $editor->preferences );

    if ($c->form_posted &&
        $form->process( params => $c->req->params )) {
        $c->model('Editor')->save_preferences($editor, $form->values);

        $c->user->preferences($editor->preferences);
        $c->persist_user();

        $c->response->redirect($c->uri_for_action('/account/preferences', { ok => 1 }));
        $c->detach;
    }
}

=head2 register

Display a form allowing new users to register on the site. When a POST
request is received, we validate the data and attempt to create the
new user.

=cut

sub register : Path('/register') ForbiddenOnSlaves RequireSSL DenyWhenReadonly
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile',
                                                 [ $c->user->name ]));
        $c->detach;
    }

    my $form = $c->form(register_form => 'User::Register');

    my $captcha = Captcha::reCAPTCHA->new;
    my $captcha_result;
    my $use_captcha = ($c->req->address &&
                       defined DBDefs->RECAPTCHA_PUBLIC_KEY &&
                       defined DBDefs->RECAPTCHA_PRIVATE_KEY);

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {

        my $valid = 0;
        if ($use_captcha)
        {
            my $challenge = $c->req->params->{recaptcha_challenge_field};
            my $response = $c->req->params->{recaptcha_response_field};

            $captcha_result = $captcha->check_answer(
                DBDefs->RECAPTCHA_PRIVATE_KEY,
                $c->req->address, $challenge, $response);

            $valid = $captcha_result->{is_valid};
        }
        else
        {
            $valid = 1;
        }

        if ($valid)
        {
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

            my $redirect = defined $c->req->query_params->{uri}
              ? $c->req->query_params->{uri}
              : $c->uri_for_action('/user/profile', [ $user->name ]);

            $c->response->redirect($redirect);
            $c->detach;
        }
        else
        {
            $c->stash(invalid_captcha_response => 1);
        }
    }

    my $captcha_html = "";
    $captcha_html = $captcha->get_html(
        DBDefs->RECAPTCHA_PUBLIC_KEY, $captcha_result, $c->req->secure) if $use_captcha;

    $c->stash(
        use_captcha   => $use_captcha,
        captcha       => $captcha_html,
        register_form => $form,
        template      => 'account/register.tt',
    );
}

=head2 resend_verification

Send out an email allowing users to confirm their email address, from the web

=cut

sub resend_verification : Path('/account/resend-verification') ForbiddenOnSlaves RequireAuth
{
    my ($self, $c) = @_;
    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    if ($editor->has_email_address) {
        $self->_send_confirmation_email($c, $editor, $editor->email);
    }
    $c->response->redirect($c->uri_for_action('/user/profile', [ $editor->name ]));
    $c->detach;
}

=head2 _send_confirmation_email

Send out an email allowing users to confirm their email address

=cut

sub _send_confirmation_email
{
    my ($self, $c, $editor, $email) = @_;

    my $time = time();
    my $verification_link = $c->uri_for_action('/account/verify_email', {
        userid => $editor->id,
        email  => $email,
        time   => $time,
        chk    => $self->_checksum($email, $editor->id, $time),
    });

    try {
        $c->model('Email')->send_email_verification(
            email             => $email,
            verification_link => $verification_link,
            ip                => $c->req->address,
            user_id           => $c->request->params->{userid}
        );
    }
    catch {
        $c->flash->{message} = l(
            '<strong>We were unable to send a confirmation email to you.</strong><br/>Please confirm that you have entered a valid
             address by editing your {settings|account settings}. If the problem still persists, please contact us at
             {mail|support@musicbrainz.org}.',
            {
                settings => $c->uri_for_action('/account/edit'),
                mail => 'mailto:support@musicbrainz.org'
            }
        );
    };
}

sub _checksum
{
    my ($self, $email, $uid, $time) = @_;
    return sha1_base64("$email $uid $time " . DBDefs->SMTP_SECRET_CHECKSUM);
}

sub donation : Local RequireAuth HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $result = $c->model('Editor')->donation_check($c->user);
    $c->detach('/error_500') unless $result;

    $c->stash(
        nag => $result->{nag},
        days => sprintf("%.0f", $result->{days}),
    );
}

sub applications : Path('/account/applications') RequireAuth RequireSSL
{
    my ($self, $c) = @_;

    my $tokens = $self->_load_paged($c, sub {
        my ($tokens, $hits) = $c->model('EditorOAuthToken')->find_granted_by_editor($c->user->id, shift, shift);
        return ($tokens, $hits);
    }, prefix => 'tokens_');
    $c->model('Application')->load(@$tokens);

    my $applications = $self->_load_paged($c, sub {
        my ($applications, $hits) = $c->model('Application')->find_by_owner($c->user->id, shift, shift);
        return ($applications, $hits);
    }, prefix => 'apps_');

    $c->stash( tokens => $tokens, applications => $applications );
}

sub revoke_application_access : Path('/account/applications/revoke-access') Args(2) RequireAuth DenyWhenReadonly
{
    my ($self, $c, $application_id, $scope) = @_;

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('EditorOAuthToken')->revoke_access($c->user->id, $application_id, $scope);
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    }
}

sub register_application : Path('/account/applications/register') RequireAuth RequireSSL DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Application' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Application')->insert({
                owner_id => $c->user->id,
                name => $form->field('name')->value,
                oauth_redirect_uri => $form->field('oauth_redirect_uri')->value,
            });
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    }
}

sub edit_application : Path('/account/applications/edit') Args(1) RequireAuth RequireSSL DenyWhenReadonly
{
    my ($self, $c, $id) = @_;

    my $application = $c->model('Application')->get_by_id($id);
    $c->detach('/error_404')
        unless defined $application && $application->owner_id == $c->user->id;

    $c->stash( application => $application );

    my $form = $c->form( form => 'Application', init_object => $application );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params) && $form->field('oauth_type')->value eq $application->oauth_type) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Application')->update($application->id, {
                name => $form->field('name')->value,
                oauth_redirect_uri => $form->field('oauth_redirect_uri')->value,
            });
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    }
}

sub remove_application : Path('/account/applications/remove') Args(1) RequireAuth RequireSSL DenyWhenReadonly
{
    my ($self, $c, $id) = @_;

    my $application = $c->model('Application')->get_by_id($id);
    $c->detach('/error_404')
        unless defined $application && $application->owner_id == $c->user->id;

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Application')->delete($application->id);
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
