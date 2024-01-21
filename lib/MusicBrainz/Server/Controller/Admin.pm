package MusicBrainz::Server::Controller::Admin;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use HTTP::Status qw( :constants );
use Try::Tiny;

extends 'MusicBrainz::Server::Controller';

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( :privileges );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json trim );

sub edit_user : Path('/admin/user/edit') Args(1) RequireAuth HiddenOnMirrors SecureForm
{
    my ($self, $c, $user_name) = @_;

    $c->detach('/error_403')
        unless $c->user->is_account_admin or DBDefs->DB_STAGING_TESTING_FEATURES;

    my $user = $c->model('Editor')->get_by_name($user_name);

    if (not defined $user) {
        $c->detach('/user/not_found');
    }
    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $user->id;

    my $form = $c->form(
        form => 'Admin::EditUser',
        item => {
            # user flags
            auto_editor             => $user->is_auto_editor,
            bot                     => $user->is_bot,
            untrusted               => $user->is_untrusted,
            link_editor             => $user->is_relationship_editor,
            location_editor         => $user->is_location_editor,
            no_nag                  => $user->is_nag_free,
            wiki_transcluder        => $user->is_wiki_transcluder,
            banner_editor           => $user->is_banner_editor,
            mbid_submitter          => $user->is_mbid_submitter,
            account_admin           => $user->is_account_admin,
            editing_disabled        => $user->is_editing_disabled,
            adding_notes_disabled   => $user->is_adding_notes_disabled,
            spammer                 => $user->is_spammer,
            # user profile
            username                => $user->name,
            email                   => $user->email,
            skip_verification       => 0,
            website                 => $user->website,
            biography               => $user->biography,
        },
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/EditUser',
        component_props => {
            form => $form->TO_JSON,
            user => $c->controller('User')->serialize_user($user),
        },
    );

    if ($c->form_posted_and_valid($form)) {
        # When an admin views their own flags page the account admin checkbox will be disabled,
        # thus we need to manually insert a value here to keep the admin's privileges intact.
        my $form_values = $form->value;
        $form_values->{account_admin} = 1 if ($c->user->id == $user->id);
        $c->model('Editor')->update_privileges($user, $form_values);
        $c->model('Editor')->update_profile($user, $form_values);

        my %args = ( ok => 1 );
        my $old_email = $user->email || '';
        my $new_email = $form->field('email')->value || '';
        if ($old_email ne $new_email) {
            if ($new_email) {
                if ($form->field('skip_verification')->value) {
                    $c->model('Editor')->update_email($user, $new_email);
                    $user->email($new_email);
                    $c->forward('/discourse/sync_sso', [$user]);
                } else {
                    $c->controller('Account')->_send_confirmation_email($c, $user, $new_email);
                    $args{email} = $new_email;
                }
            }
            else {
                $c->model('Editor')->update_email($user, undef);
                $user->email('editor-' . $user->id . '@musicbrainz.invalid');
                $c->forward('/discourse/sync_sso', [$user]);
            }
        }

        $c->flash->{message} = 'User successfully edited.';
        $c->response->redirect($c->uri_for_action('/user/profile', [$form->field('username')->value]));
        $c->detach;
    } else {
        $c->stash->{component_props}{form} = $form->TO_JSON;
    }
}

sub _delete_user {
    my ($self, $c, $editor, $allow_reuse) = @_;

    $c->model('Editor')->delete($editor->id, $allow_reuse);
    if ($editor->id == $c->user->id) { # don't log out an admin deleting a different user
        MusicBrainz::Server::Controller::User->_clear_login_cookie($c);
        $c->logout;
        $c->delete_session;
    }

    $editor->name('Deleted Editor #' . $editor->id);
    $editor->email('editor-' . $editor->id . '@musicbrainz.invalid');
    $c->forward('/discourse/sync_sso', [$editor]);
    $c->forward('/discourse/log_out', [$editor]);
}

sub delete_user : Path('/admin/user/delete') Args(1) RequireAuth(account_admin) HiddenOnMirrors SecureForm {
    my ($self, $c, $name) = @_;

    my $editor = $c->model('Editor')->get_by_name($name);
    $c->detach('/user/not_found') if !$editor || $editor->deleted;

    my $id = $editor->id;
    $c->detach('/account/delete') if $c->user_exists && $c->user->id == $id;

    $c->stash( user => $editor );

    my $form = $c->form(form => 'Admin::DeleteUser');

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/DeleteUser',
        component_props => {
            form => $form->TO_JSON,
            user => $c->controller('User')->serialize_user($editor),
        },
    );

    if ($c->form_posted_and_valid($form)) {
        my $allow_reuse = 0;
        $allow_reuse = 1 if $form->field('allow_reuse')->value;

        $self->_delete_user($c, $editor, $allow_reuse);

        $editor = $c->model('Editor')->get_by_id($id);
        $c->response->redirect(
            $editor ? $c->uri_for_action('/user/profile', [ $editor->name ]) : $c->uri_for('/'));
    }
}

sub delete_users : Path('/admin/delete-users') RequireAuth(account_admin) HiddenOnSlaves {
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Admin::DeleteUsers');

    if ($c->form_posted_and_valid($form, $c->req->body_params)) {
        my $post_params = $c->req->body_params;
        my $submission_type = %$post_params{'delete-users.submit'};
        # We delete the unneeded parameters - we only want user
        # and the other ones cause issues
        delete(%$post_params{'delete-users.csrf_session_key'});
        delete(%$post_params{'delete-users.csrf_token'});
        delete(%$post_params{'delete-users.submit'});

        my $users_string = $form->field('users')->value;
        my @usernames = uniq grep { $_ } map { lc trim $_ } (split /\n/, $users_string);
        my @users;
        my @incorrect_usernames;
        my %stats;

        for my $username (@usernames) {
            my $user = $c->model('Editor')->get_by_name($username);
            if ($user) {
                push @users, $user;
                $stats{$user->id} = $c->model('Editor')->get_editor_stats(
                    $user,
                    1, # We want admins to always see private counts here
                );
            } else {
                push @incorrect_usernames, $username;
            }
        }

        if ($submission_type eq 'confirmed') {
            for my $user (@users) {
                # Don't allow reuse by default, the admin can always
                # unlock the username in the rare case that is desired
                $self->_delete_user($c, $user, 0);
            }
            $c->response->redirect($c->uri_for('/'));
        } else {
            $c->stash(
                current_view => 'Node',
                component_path => 'admin/DeleteUsersConfirm',
                component_props => {
                    form => $form->TO_JSON,
                    incorrectUsernames => \@incorrect_usernames,
                    postParameters => $post_params,
                    stats => \%stats,
                    users => [map { $c->unsanitized_editor_json($_) } @users],
                },
            );
        }
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'admin/DeleteUsers',
            component_props => { form => $form->TO_JSON },
        );
    }
}

sub edit_banner : Path('/admin/banner/edit') Args(0) RequireAuth(banner_editor) SecureForm {
    my ($self, $c) = @_;

    my $current_message = $c->stash->{server_details}->{alert};
    my $form = $c->form( form => 'Admin::Banner',
                         init_object => { message => $current_message } );

    if ($c->form_posted_and_valid($form)) {
        my $store = $c->model('MB')->context->store;
        my $alert_cache_key = DBDefs->IS_BETA ? 'beta:alert' : 'alert';
        my $alert_mtime_cache_key = DBDefs->IS_BETA ? 'beta:alert_mtime' : 'alert_mtime';

        $store->set($alert_cache_key, $form->values->{message});
        $store->set($alert_mtime_cache_key, time());

        $c->flash->{message} = 'Banner updated. Remember that each server has its own, independent banner.';
        $c->response->redirect($c->uri_for('/'));
        $c->detach;
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'admin/EditBanner',
            component_props => {form => $form->TO_JSON},
        );
    }
}

sub email_search : Path('/admin/email-search') Args(0) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Admin::EmailSearch');
    my $results;
    my $stored_email = $c->session->{admin_searched_email};

    if ($c->form_posted_and_valid($form, $c->req->body_params)) {
        try {
            delete $c->session->{admin_searched_email};
            my $searched_email = $form->field('email')->value;
            $results = $self->_load_paged($c, sub {
                $c->model('Editor')->search_by_email(
                    $searched_email // '',
                    shift,
                    shift,
                );
            });
            if ($searched_email) {
                $c->session->{admin_searched_email} = $searched_email;
            }
        } catch {
            my $error = $_;
            if ("$error" =~ m/invalid regular expression/) {
                $form->field('email')->add_error('Invalid regular expression.');
                $c->response->status(HTTP_BAD_REQUEST);
            } else {
                die $error;
            }
        };
    } elsif ($stored_email) {
        $results = $self->_load_paged($c, sub {
            $c->model('Editor')->search_by_email(
                $stored_email,
                shift,
                shift,
            );
        });
        $form->field('email')->value($stored_email);
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/EmailSearch',
        component_props => {
            form => $form->TO_JSON,
            $c->stash->{pager} ? (
                pager => serialize_pager($c->stash->{pager}),
                results => [map { $c->unsanitized_editor_json($_) } @$results],
            ) : (),
        },
    );
}

sub ip_lookup : Path('/admin/ip-lookup') Args(1) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c, $ip_hash) = @_;

    my $results = $self->_load_paged($c, sub {
        $c->model('Editor')->find_by_ip($ip_hash // '', shift, shift);
    });


    $c->stash(
        current_view => 'Node',
        component_path => 'admin/IpLookup',
        component_props => {
            ipHash => $ip_hash,
            pager => serialize_pager($c->stash->{pager}),
            users => [map { $c->unsanitized_editor_json($_) } @$results],
        },
    );
}

sub locked_username_search : Path('/admin/locked-usernames/search') Args(0) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Admin::LockedUsernameSearch');
    my @results;
    my $show_results = 0;

    if ($c->form_posted_and_valid($form, $c->req->body_params)) {
        try {
            @results = $c->model('Editor')->search_old_editor_names(
                $form->field('username')->value // '',
                $form->field('use_regular_expression')->value,
            );
            $show_results = 1;
        } catch {
            my $error = $_;
            if ("$error" =~ m/invalid regular expression/) {
                $form->field('username')->add_error('Invalid regular expression.');
                $c->response->status(HTTP_BAD_REQUEST);
            } else {
                die $error;
            }
        };
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/LockedUsernameSearch',
        component_props => {
            form => $form->TO_JSON,
            @results ? (results => \@results) : (),
            showResults => boolean_to_json($show_results),
        },
    );
}

sub privilege_search : Path('/admin/privilege-search') Args(0) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Admin::PrivilegeSearch');
    my $results;

    if ($c->form_submitted_and_valid($form)) {
        my $values = $form->value;
        my $privs =   ($values->{auto_editor}           // 0) * $AUTO_EDITOR_FLAG
                    + ($values->{bot}                   // 0) * $BOT_FLAG
                    + ($values->{untrusted}             // 0) * $UNTRUSTED_FLAG
                    + ($values->{link_editor}           // 0) * $RELATIONSHIP_EDITOR_FLAG
                    + ($values->{location_editor}       // 0) * $LOCATION_EDITOR_FLAG
                    + ($values->{no_nag}                // 0) * $DONT_NAG_FLAG
                    + ($values->{wiki_transcluder}      // 0) * $WIKI_TRANSCLUSION_FLAG
                    + ($values->{banner_editor}         // 0) * $BANNER_EDITOR_FLAG
                    + ($values->{mbid_submitter}        // 0) * $MBID_SUBMITTER_FLAG
                    + ($values->{account_admin}         // 0) * $ACCOUNT_ADMIN_FLAG
                    + ($values->{editing_disabled}      // 0) * $EDITING_DISABLED_FLAG
                    + ($values->{adding_notes_disabled} // 0) * $ADDING_NOTES_DISABLED_FLAG
                    + ($values->{spammer}               // 0) * $SPAMMER_FLAG;
        $results = $self->_load_paged($c, sub {
            $c->model('Editor')->find_by_privileges(
                $privs,
                $values->{show_exact},
                shift,
                shift,
            );
        });
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/PrivilegeSearch',
        component_props => {
            form => $form->TO_JSON,
            $c->stash->{pager}
                ?  (pager => serialize_pager($c->stash->{pager}) )
                : (),
            results => [map { $c->unsanitized_editor_json($_) } @$results],
        },
    );
}

sub unlock_username : Path('/admin/locked-usernames/unlock') Args(1) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c, $username) = @_;

    my $form = $c->form(form => 'SecureConfirm');

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Editor')->unlock_old_editor_name($username);
        });
        $c->response->redirect($c->uri_for_action('/admin/locked_username_search'));
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/LockedUsernameUnlock',
        component_props => {
            form => $form->TO_JSON,
            username => $username,
        },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 Pavan Chander

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
