package MusicBrainz::Server::Controller::Account;
use Moose;
use MooseX::MethodAttributes;

extends 'MusicBrainz::Server::Controller';

use namespace::autoclean;
use Digest::SHA qw(sha1_base64);
use HTTP::Request;
use JSON qw( decode_json );
use List::AllUtils qw( uniq );
use DBDefs;
use MusicBrainz::Server::Constants qw( $BEGINNER_FLAG $CONTACT_URL );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    is_blank
    non_empty
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Form::Utils qw(
    build_grouped_options
    language_options
);
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities is_positive_integer );
use Try::Tiny;
use URI;

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
            website           => $editor->website,
            biography         => $editor->biography,
            gender_id         => $editor->gender_id,
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
            $form->value,
        );

        my $old_email = $editor->email || '';
        my $new_email = $form->field('email')->value || '';
        my $verification_sent;

        if ($old_email ne $new_email) {
            $c->model('Editor')->update_email($editor, undef);
        }

        $c->model('EditorLanguage')->set_languages(
            $c->user->id,
            $form->field('languages')->value,
        );

        $c->flash->{message} = l('Your profile has been updated.');
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
                        label => $_,
                      } } uniq values @{ $form->options_timezone } ],
                },
                email_language_options => {
                    grouped => JSON::false,
                    options => $form->options_email_language,
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

    $c->res->header('Referrer-Policy' => 'strict-origin-when-cross-origin');

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile',
                                                 [ $c->user->name ]));
        $c->detach;
    }

    my $form = $c->form(register_form => 'User::Register');

    if ($c->form_posted_and_valid($form)) {
        my $email = $form->field('email')->value;

        my $editor = $c->model('Editor')->insert({
            name => $form->field('username')->value,
            password => $form->field('password')->value,
            privs => $BEGINNER_FLAG,
        });

        my $user = MusicBrainz::Server::Authentication::User->new_from_editor($editor);
        $c->set_authenticated($user);

        $c->redirect_back(
            fallback => $c->uri_for_action('/user/profile', [ $user->name ]),
        );
        $c->detach;
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'account/Register',
        component_props => {
            form => $form->TO_JSON,
        },
    );
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
        },
    );
}

sub applications : Path('/account/applications') RequireAuth RequireSSL SecureForm
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

    my $digest_auth_form = $c->form( form => 'Account::DigestAuthentication' );
    my $is_digest_auth_enabled = !is_blank($c->user->ha1);

    $c->stash(
        current_view => 'Node',
        component_path => 'account/applications/ApplicationList',
        component_props => {
            applications => to_json_array($applications),
            appsPager => serialize_pager($c->stash->{apps_pager}),
            digestAuthForm => $digest_auth_form->TO_JSON,
            isDigestAuthEnabled => boolean_to_json($is_digest_auth_enabled),
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
        [ l('There is no OAuth token with these parameters.') ],
    ) unless $token_exists;

    my $application = $c->model('Application')->get_by_id($application_id);
    my $permissions =
        MusicBrainz::Server::Entity::EditorOAuthToken->permissions($scope);

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
                application => $application->TO_JSON,
                form => $form->TO_JSON,
                permissions => $permissions,
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

=head2 digest_authentication

This form allows users to reset the token used for digest auth in the
web service, or disable digest auth entirely.

=cut

sub digest_authentication : Path('/account/digest-authentication') RequireAuth RequireSSL DenyWhenReadonly SecureForm
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Account::DigestAuthentication' );
    my %component_props;

    if ($c->form_posted_and_valid($form)) {
        my $action = $form->field('action')->value;

        if ($action eq 'disable') {
            $c->model('MB')->with_transaction(sub {
                $c->model('Editor')->disable_digest_auth_token($c->user->id);
            });
        } elsif ($action eq 'reset_token') {
            $c->model('MB')->with_transaction(sub {
                my $new_token = $c->model('Editor')->reset_digest_auth_token($c->user->id);
                $component_props{token} = $new_token;
            });
        }
    }

    $component_props{form} = $form->TO_JSON;

    $c->stash(
        current_view => 'Node',
        component_path => 'account/DigestAuthentication.js',
        component_props => \%component_props,
    );
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
