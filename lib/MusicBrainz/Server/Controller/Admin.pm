package MusicBrainz::Server::Controller::Admin;
use Moose;
use Try::Tiny;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Translation qw(l ln );

sub edit_user : Path('/admin/user/edit') Args(1) RequireAuth HiddenOnSlaves CSRFToken
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
        form => 'User::AdjustFlags',
        item => {
            auto_editor         => $user->is_auto_editor,
            bot                 => $user->is_bot,
            untrusted           => $user->is_untrusted,
            link_editor         => $user->is_relationship_editor,
            location_editor     => $user->is_location_editor,
            no_nag              => $user->is_nag_free,
            wiki_transcluder    => $user->is_wiki_transcluder,
            banner_editor       => $user->is_banner_editor,
            mbid_submitter      => $user->is_mbid_submitter,
            account_admin       => $user->is_account_admin,
            editing_disabled    => $user->is_editing_disabled,
        },
    );

    my $form2 = $c->form(
        form => 'User::EditProfile',
        item => {
            username          => $user->name,
            email            => $user->email,
            skip_verification => 0,
            website            => $user->website,
            biography        => $user->biography
        },
    );

    if (
        $c->form_posted_and_valid($form) &&
        $c->form_posted_and_valid($form2)
    ) {
        # When an admin views their own flags page the account admin checkbox will be disabled,
        # thus we need to manually insert a value here to keep the admin's privileges intact.
        $form->values->{account_admin} = 1 if ($c->user->id == $user->id);
        $c->model('Editor')->update_privileges($user, $form->values);

        $c->model('Editor')->update_profile(
            $user,
            $form2->value
        );

        my %args = ( ok => 1 );
        my $old_email = $user->email || '';
        my $new_email = $form2->field('email')->value || '';
        if ($old_email ne $new_email) {
            if ($new_email) {
                if ($form2->field('skip_verification')->value) {
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
        $c->response->redirect($c->uri_for_action('/user/profile', [$form2->field('username')->value]));
        $c->detach;
    }

    $c->stash(
        user => $user,
        form => $form,
        form2 => $form2,
        show_flags => 1,
    );
}

sub delete_user : Path('/admin/user/delete') Args(1) RequireAuth HiddenOnSlaves CSRFToken {
    my ($self, $c, $name) = @_;

    my $editor = $c->model('Editor')->get_by_name($name);
    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $editor->id;

    $c->detach('/error_404') if !$editor || $editor->deleted;

    my $id = $editor->id;
    if ($id != $c->user->id && !$c->user->is_account_admin) {
        $c->detach('/error_403');
    }

    $c->stash( user => $editor );

    if ($c->form_posted && $c->validate_csrf_token) {
        my $allow_reuse = 0;
        if ($id != $c->user->id && $c->user->is_account_admin) {
            $allow_reuse = 1 if ($c->req->params->{allow_reuse} // '') eq '1';
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

sub edit_banner : Path('/admin/banner/edit') Args(0) RequireAuth(banner_editor) CSRFToken {
    my ($self, $c) = @_;

    my $current_message = $c->stash->{server_details}->{alert};
    my $form = $c->form( form => 'Admin::Banner',
                         init_object => { message => $current_message } );

    if ($c->form_posted_and_valid($form)) {
        my $store = $c->model('MB')->context->store;

        $store->set('alert', $form->values->{message});
        $store->set('alert_mtime', time());

        $c->flash->{message} = l('Banner updated. Remember that each server has its own, independent banner.');
        $c->response->redirect($c->uri_for('/'));
        $c->detach;
    } else {
        $c->stash(
            current_view => 'Node',
            component_path => 'admin/EditBanner',
            component_props => {form => $form},
        );
    }
}

sub email_search : Path('/admin/email-search') Args(0) RequireAuth(account_admin) HiddenOnSlaves {
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Admin::EmailSearch');
    my @results;

    if ($c->form_submitted_and_valid($form)) {
        try {
            @results = $c->model('Editor')->search_by_email(
                $form->field('email')->value // '',
            );
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
            form => $form,
            @results ? (results => \@results) : (),
        },
    );
}

sub ip_lookup : Path('/admin/ip-lookup') Args(1) RequireAuth(account_admin) HiddenOnSlaves {
    my ($self, $c, $ip_hash) = @_;

    my @users = $c->model('Editor')->find_by_ip($ip_hash // '');

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/IpLookup',
        component_props => {
            ipHash => $ip_hash,
            users => \@users,
        },
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 Pavan Chander

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
