package MusicBrainz::Server::Controller::Admin;
use Moose;
use Try::Tiny;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Constants qw( :privileges );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

sub edit_user : Path('/admin/user/edit') Args(1) RequireAuth HiddenOnMirrors SecureForm
{
    my ($self, $c, $user_name) = @_;

    $c->detach('/error_403')
        unless $c->user->is_account_admin or DBDefs->DB_STAGING_TESTING_FEATURES;

    my $user = $c->model('Editor')->get_by_name($user_name);

    if (not defined $user) {
        $c->detach('/user/not_found')
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
            biography               => $user->biography
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

        $c->flash->{message} = l('User successfully edited.');
        $c->response->redirect($c->uri_for_action('/user/profile', [$form->field('username')->value]));
        $c->detach;
    }

    $c->stash(
        user => $user,
        form => $form,
        show_flags => 1,
    );
}

sub delete_user : Path('/admin/user/delete') Args(1) RequireAuth HiddenOnMirrors SecureForm {
    my ($self, $c, $name) = @_;

    my $editor = $c->model('Editor')->get_by_name($name);
    $c->detach('/user/not_found') if !$editor || $editor->deleted;

    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $editor->id;

    my $id = $editor->id;
    if ($id != $c->user->id && !$c->user->is_account_admin) {
        $c->detach('/error_403');
    }

    $c->stash( user => $editor );

    my $form = $c->form(form => 'Admin::DeleteUser');
    if ($c->form_posted_and_valid($form)) {
        my $allow_reuse = 0;
        if ($id != $c->user->id && $c->user->is_account_admin) {
            $allow_reuse = 1 if $form->field('allow_reuse')->value;
        }

        $c->model('Editor')->delete($id, $allow_reuse);
        if ($id == $c->user->id) { # don't log out an admin deleting a different user
            MusicBrainz::Server::Controller::User->_clear_login_cookie($c);
            $c->logout;
            $c->delete_session;
        }

        $editor->name('Deleted Editor #' . $id);
        $editor->email('editor-' . $id . '@musicbrainz.invalid');
        $c->forward('/discourse/sync_sso', [$editor]);
        $c->forward('/discourse/log_out', [$editor]);

        $editor = $c->model('Editor')->get_by_id($id);
        $c->response->redirect(
            $editor ? $c->uri_for_action('/user/profile', [ $editor->name ]) : $c->uri_for('/'));
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

        $c->flash->{message} = l('Banner updated. Remember that each server has its own, independent banner.');
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
    my @results;
    my $searched = 0;

    if ($c->form_posted_and_valid($form, $c->req->body_params)) {
        try {
            @results = $c->model('Editor')->search_by_email(
                $form->field('email')->value // '',
            );
            $searched = 1;
        } catch {
            my $error = $_;
            if ("$error" =~ m/invalid regular expression/) {
                $form->field('email')->add_error(l('Invalid regular expression.'));
                $c->response->status(400);
            } else {
                die $error;
            }
        };
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/EmailSearch',
        component_props => {
            form => $form->TO_JSON,
            $searched ? (
                results => [map { $c->unsanitized_editor_json($_) } @results],
            ) : (),
        },
    );
}

sub ip_lookup : Path('/admin/ip-lookup') Args(1) RequireAuth(account_admin) HiddenOnMirrors {
    my ($self, $c, $ip_hash) = @_;

    my @users = $c->model('Editor')->find_by_ip($ip_hash // '');

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/IpLookup',
        component_props => {
            ipHash => $ip_hash,
            users => [map { $c->unsanitized_editor_json($_) } @users],
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
                $form->field('username')->add_error(l('Invalid regular expression.'));
                $c->response->status(400);
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
                shift
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
