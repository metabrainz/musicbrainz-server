package MusicBrainz::Server::Controller::Account;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use namespace::autoclean;
use Digest::SHA qw(sha1_base64);
use JSON;
use List::AllUtils qw( uniq );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Form::Utils qw(
    build_grouped_options
    language_options
);
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities is_positive_integer );
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

sub verify_email : Path('/verify-email') ForbiddenOnMirrors DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $user_id = $c->request->params->{userid};
    my $email   = $c->request->params->{email};
    my $time    = $c->request->params->{time};
    my $key     = $c->request->params->{chk};

    unless (is_positive_integer($user_id) && $user_id) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('The user ID is missing or is in an invalid format.'),
            }
        );
    }

    unless ($email) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('The email address is missing.'),
            }
        );
    }

    unless (is_positive_integer($time) && $time) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('The time is missing or is in an invalid format.'),
            }
        );
        $c->detach;
    }

    unless ($key) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('The verification key is missing.'),
            }
        );
        $c->detach;
    }

    unless ($self->_checksum($email, $user_id, $time) eq $key) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('The checksum is invalid, please double check your email.'),
            }
        );
        $c->detach;
    }

    if (($time + DBDefs->EMAIL_VERIFICATION_TIMEOUT) < time()) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l('Sorry, this email verification link has expired.'),
            }
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($user_id);
    unless (defined $editor) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EmailVerificationStatus',
            component_props => {
                message => l(q(The user with ID '{user_id}' could not be found.),
                                                { user_id => $user_id }),
            }
        );
        $c->detach;
    }

    if ($editor->deleted) {
        $c->detach('/user/not_found');
    }

    $c->model('Editor')->update_email($editor, $email);

    if ($c->user_exists) {
        $c->user->email($editor->email);
        $c->user->email_confirmation_date($editor->email_confirmation_date);
        $c->persist_user();
    }

    $c->forward('/discourse/sync_sso', [$editor]);
    $c->stash(
        current_view => 'Node',
        component_path => 'account/EmailVerificationStatus',
    );
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
            'We were unable to send login information to your email address.  Please try again, ' .
            'however if you continue to experience difficulty contact us at support@musicbrainz.org.'
        );
    };
}

sub lost_password : Path('/lost-password') ForbiddenOnMirrors SecureForm
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/LostPasswordSent',
        );
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostPassword' );
    if ($c->form_posted_and_valid($form)) {
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
                $form->field('email')->add_error(l(q(We can't send a password reset email, because we have no email on record for this user.)));
            }
            else {
                $self->_send_password_reset_email($c, $editor);
                $c->response->redirect($c->uri_for_action('/account/lost_password',
                                                          { sent => 1}));
                $c->detach;
            }
        }
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'account/LostPassword',
        component_props => {
            form => $form->TO_JSON,
        },
    );
    $c->detach;
}

sub reset_password : Path('/reset-password') ForbiddenOnMirrors DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/ResetPasswordStatus',
            component_props => {
                message => l('Your password has been reset.'),
            }
        );
        $c->detach;
    }

    my $editor_id = $c->request->params->{id};
    my $time = $c->request->params->{time};
    my $key = $c->request->params->{key};

    if (!$editor_id || !$time || !$key) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/ResetPasswordStatus',
            component_props => {
                message => l('Missing one or more required parameters.'),
            }
        );
        $c->detach;
    }

    if ($time + DBDefs->EMAIL_VERIFICATION_TIMEOUT < time()) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/ResetPasswordStatus',
            component_props => {
                message => l('Sorry, this password reset link has expired.'),
            }
        );
        $c->detach;
    }

    if ($self->_reset_password_checksum($editor_id, $time) ne $key) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/ResetPasswordStatus',
            component_props => {
                message => l('The checksum is invalid, please double check your email.'),
            }
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($editor_id);
    if (!defined $editor) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/ResetPasswordStatus',
            component_props => {
                message => l(q(The user with ID '{user_id}' could not be found.),
                                                { user_id => $editor_id }),
            }
        );
        $c->detach;
    }

    my $form = $c->form( form => 'User::ResetPassword' );

    $c->stash(
        current_view => 'Node',
        component_path => 'account/ResetPassword.js',
        component_props => {
            form => $form->TO_JSON,
        },
    );

    if ($c->form_posted_and_valid($form)) {
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

sub lost_username : Path('/lost-username') ForbiddenOnMirrors SecureForm
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{sent}) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/LostUsernameSent',
        );
        $c->detach;
    }

    my $form = $c->form( form => 'User::LostUsername' );

    if ($c->form_posted_and_valid($form)) {
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

    $c->stash(
        current_view => 'Node',
        component_path => 'account/LostUsername',
        component_props => {
            form => $form->TO_JSON,
        },
    );
    $c->detach;
}

=head2 edit

Display a form to allow users to edit their profile, or (if a POST
request is received), update the profile data in the database.

=cut

sub edit : Local RequireAuth DenyWhenReadonly SecureForm {
    my ($self, $c) = @_;

    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    $c->model('Area')->load($editor);
    $c->model('EditorLanguage')->load_for_editor($editor);

    my $form = $c->form(
        form => 'User::EditProfile',
        item => {
            username          => $editor->name,
            email             => $editor->email,
            skip_verification => 0,
            website           => $editor->website,
            biography         => $editor->biography,
            gender_id         => $editor->gender_id,
            area_id           => $editor->area_id,
            area              => $editor->area,
            birth_date        => $editor->birth_date,
            languages         => $editor->languages,
        },
    );

    if ($c->form_posted_and_valid($form)) {
        my $old_username = $editor->name;
        my $new_username = $form->field('username')->value;

        if (defined $new_username && $new_username ne $old_username) {
            $c->detach('/error_403');
        }

        $c->model('Editor')->update_profile(
            $editor,
            $form->value
        );

        my $old_email = $editor->email || '';
        my $new_email = $form->field('email')->value || '';
        my $verification_sent;

        if ($old_email ne $new_email) {
            if ($new_email) {
                $self->_send_confirmation_email($c, $editor, $new_email);
                $verification_sent = 1;
            } else {
                $c->model('Editor')->update_email($editor, undef);
            }
        }

        $c->model('EditorLanguage')->set_languages(
            $c->user->id,
            $form->field('languages')->value
        );

        my $flash = l('Your profile has been updated.');

        if ($verification_sent) {
            $flash .= ' ';
            $flash .= l('We have sent you a verification email to <code>{email}</code>. ' .
                        'Please check your mailbox and click on the link in the email ' .
                        'to verify the new email address.',
                        { email => encode_entities($new_email) });
        }

        $c->flash->{message} = $flash;
        $c->response->redirect($c->uri_for_action('/user/profile', [$editor->name]));
        $c->detach;
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/EditProfile',
            component_props => {
                form => $form->TO_JSON,
                language_options => {
                    grouped => JSON::true,
                    options => build_grouped_options($c, language_options($c, 'editor')),
                },

            },
        );
        $c->detach;
    }
}

=head2 change_password

Allow users to change their password. This displays a form prompting
for their old password and a new password (with confirmation), which
when use to update the database data when we receive a valid POST request.

=cut

sub change_password : Path('/account/change-password') RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->flash->{message} = l('Your password has been changed.');
        $c->response->redirect($c->uri_for_action('/user/login'));

        $c->detach;
    }

    my $mandatory = $c->req->query_params->{mandatory};

    my $form = $c->form(
        form => 'User::ChangePassword',
        init_object => {
            username => $c->user_exists
                ? $c->user->name
                : ($c->req->query_parameters->{username} // '')
        }
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'account/ChangePassword.js',
        component_props => {
            form => $form->TO_JSON,
            isMandatory => boolean_to_json($mandatory),
        },
    );

    if ($c->form_posted_and_valid($form)) {
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

sub preferences : Path('/account/preferences') RequireAuth DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    if (exists $c->request->params->{ok}) {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/PreferencesSaved',
        );
        $c->detach;
    }

    my $editor = $c->model('Editor')->get_by_id($c->user->id);
    $c->model('Editor')->load_preferences($editor);

    my $form = $c->form( form => 'User::Preferences', item => $editor->preferences );

    if ($c->form_posted_and_valid($form)) {
        $c->model('Editor')->save_preferences($editor, $form->values);

        $c->user->preferences($editor->preferences);
        $c->persist_user();

        $c->response->redirect($c->uri_for_action('/account/preferences', { ok => 1 }));
        $c->detach;
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/Preferences',
            component_props => {
                form => $form->TO_JSON,
                timezone_options => {
                    grouped => JSON::false,
                    options => [ map { {
                        value => $_,
                        label => $_
                      } } uniq values @{ $form->options_timezone } ],
                },
            },
        );
        $c->detach;
    }
}

=head2 register

Display a form allowing new users to register on the site. When a POST
request is received, we validate the data and attempt to create the
new user.

=cut

sub register : Path('/register') ForbiddenOnMirrors RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile',
                                                 [ $c->user->name ]));
        $c->detach;
    }

    my $form = $c->form(register_form => 'User::Register');

    my $captcha = Captcha::reCAPTCHA->new;
    my $use_captcha = ($c->req->address &&
                       defined DBDefs->RECAPTCHA_PUBLIC_KEY &&
                       defined DBDefs->RECAPTCHA_PRIVATE_KEY);

    if ($c->form_posted_and_valid($form)) {
        my $valid = 0;
        if ($use_captcha)
        {
            my $response = $c->req->params->{'g-recaptcha-response'} // '';

            $valid = $captcha->check_answer_v2(
                DBDefs->RECAPTCHA_PRIVATE_KEY,
                $response, $c->req->address
                )->{is_valid}
            unless $response eq '';
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

            my $redirect = $c->req->query_params->{returnto} // '';
            if ($redirect =~ /^\/discourse\/sso/) {
                $c->stash(
                    current_view => 'Node',
                    component_path => 'account/sso/DiscourseRegistered',
                    component_props => {
                        emailAddress => $email,
                    }
                );
                $c->detach;
            }

            $c->redirect_back(
                fallback => $c->uri_for_action('/user/profile', [ $user->name ]),
            );
            $c->detach;
        }
        else
        {
            $c->stash(invalid_captcha_response => 1);
        }
    }

    my $captcha_html = '';
    $captcha_html = $captcha->get_html_v2(DBDefs->RECAPTCHA_PUBLIC_KEY)
        if $use_captcha;

    $c->stash(
        use_captcha   => $use_captcha,
        captcha       => $captcha_html,
        register_form => $form,
        template      => 'account/register.tt',
    );
}

=head2 resend_verification

Send out an email allowing users to verify their email address, from the web

=cut

sub resend_verification : Path('/account/resend-verification') ForbiddenOnMirrors RequireAuth
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

Send out an email allowing users to verify their email address

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

    my $email_in_use = $c->model('Editor')->is_email_used_elsewhere($email, $editor->id);

    try {
        if ($email_in_use) {
            $c->model('Email')->send_email_in_use(
                email             => $email,
                ip                => $c->req->address,
                editor            => $editor
            );
        } else {
            $c->model('Email')->send_email_verification(
                email             => $email,
                verification_link => $verification_link,
                ip                => $c->req->address,
                editor            => $editor
            );
        }
    }
    catch {
        $c->flash->{message} = l(
            '<strong>We were unable to send a verification email to you.</strong><br/>Please confirm that you have entered a valid ' .
            'address by editing your {settings|account settings}. If the problem still persists, please contact us at ' .
            '{mail|support@musicbrainz.org}.',
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

sub donation : Local RequireAuth HiddenOnMirrors
{
    my ($self, $c) = @_;

    my $result = $c->model('Editor')->donation_check($c->user);
    my $check_failed = 0;
    my $nag = 0;

    if (defined $result) {
        # If nag is 0, don't nag - if 1 or -1 then nag
        $nag = $result->{nag} != 0;
    } else {
        $check_failed = 1;
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'account/Donation',
        component_props => {
            checkFailed => boolean_to_json($check_failed),
            days => sprintf('%.0f', $result->{days}),
            nag => boolean_to_json($nag),
            user => $c->controller('User')->serialize_user($c->user),
        }
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

    $c->stash(
        current_view => 'Node',
        component_path => 'account/applications/ApplicationList',
        component_props => {
            applications => to_json_array($applications),
            appsPager => serialize_pager($c->stash->{apps_pager}),
            tokens => to_json_array($tokens),
            tokensPager => serialize_pager($c->stash->{tokens_pager}),
        },
    );
}

sub revoke_application_access : Path('/account/applications/revoke-access') Args(2) RequireAuth DenyWhenReadonly SecureForm
{
    my ($self, $c, $application_id, $scope) = @_;

    my $form = $c->form( form => 'Confirm' );

    my $token_exists = $c->model('EditorOAuthToken')->check_granted_token(
        $c->user->id,
        $application_id,
        $scope,
    );
    $c->detach(
        '/error_404',
        [ l('There is no OAuth token with these parameters.') ]
    ) unless $token_exists;

    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            $c->response->redirect($c->uri_for_action('/account/applications'));
            $c->detach;
        } else {
            $c->model('MB')->with_transaction(sub {
                $c->model('EditorOAuthToken')->revoke_access($c->user->id, $application_id, $scope);
            });
            $c->response->redirect($c->uri_for_action('/account/applications'));
            $c->detach;
        }
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/applications/RevokeApplicationAccess',
            component_props => {
                form => $form->TO_JSON,
            },
        );
        $c->detach;
    }
}

sub register_application : Path('/account/applications/register') RequireAuth RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Application' );
    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Application')->insert({
                owner_id => $c->user->id,
                name => $form->field('name')->value,
                oauth_redirect_uri => $form->field('oauth_redirect_uri')->value,
            });
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/applications/RegisterApplication',
            component_props => {
                form => $form->TO_JSON,
            },
        );
        $c->detach;
    }
}

sub edit_application : Path('/account/applications/edit') Args(1) RequireAuth RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c, $id) = @_;

    my $application = $c->model('Application')->get_by_id($id);
    $c->detach('/error_404')
        unless defined $application && $application->owner_id == $c->user->id;

    $c->stash( application => $application );

    my $form = $c->form( form => 'Application', init_object => $application );
    if ($c->form_posted_and_valid($form) && $form->field('oauth_type')->value eq $application->oauth_type) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Application')->update($application->id, {
                name => $form->field('name')->value,
                oauth_redirect_uri => $form->field('oauth_redirect_uri')->value,
            });
        });
        $c->response->redirect($c->uri_for_action('/account/applications'));
        $c->detach;
    } else {
        $form->field('oauth_type')->value($application->oauth_type),
        $c->stash(
            current_view => 'Node',
            component_path => 'account/applications/EditApplication',
            component_props => {
                form => $form->TO_JSON,
            },
        );
        $c->detach;
    }
}

sub remove_application : Path('/account/applications/remove') Args(1) RequireAuth RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c, $id) = @_;

    my $application = $c->model('Application')->get_by_id($id);
    $c->detach('/error_404')
        unless defined $application && $application->owner_id == $c->user->id;

    my $form = $c->form( form => 'Confirm' );
    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            $c->response->redirect($c->uri_for_action('/account/applications'));
            $c->detach;
        } else {
            $c->model('MB')->with_transaction(sub {
                $c->model('Application')->delete($application->id);
            });
            $c->response->redirect($c->uri_for_action('/account/applications'));
            $c->detach;
        }
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'account/applications/RemoveApplication',
            component_props => {
                form => $form->TO_JSON,
            },
        );
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
