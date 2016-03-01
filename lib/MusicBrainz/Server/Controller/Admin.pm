package MusicBrainz::Server::Controller::Admin;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Translation qw(l ln );

sub edit_user : Path('/admin/user/edit') Args(1) RequireAuth HiddenOnSlaves
{
    my ($self, $c, $user_name) = @_;

    $c->detach('/error_403')
        unless $c->user->is_account_admin or DBDefs->DB_STAGING_TESTING_FEATURES;

    my $user = $c->model('Editor')->get_by_name($user_name);
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
            email            => $user->email,
            website            => $user->website,
            biography        => $user->biography
        },
    );

    if ($c->form_posted) {
        if ($form->submitted_and_valid($c->req->params )) {
            # When an admin views their own flags page the account admin checkbox will be disabled,
            # thus we need to manually insert a value here to keep the admin's privileges intact.
            $form->values->{account_admin} = 1 if ($c->user->id == $user->id);
            $c->model('Editor')->update_privileges($user, $form->values);
        }

        if ($form2->submitted_and_valid($c->req->params )) {
            $c->model('Editor')->update_profile(
                $user,
                $form2->value
            );

            my %args = ( ok => 1 );
            my $old_email = $user->email || '';
            my $new_email = $form2->field('email')->value || '';
            if ($old_email ne $new_email) {
                if ($new_email) {
                    $c->controller('Account')->_send_confirmation_email($c, $user, $new_email);
                    $args{email} = $new_email;
                }
                else {
                    $c->model('Editor')->update_email($user, undef);
                    $user->email('editor-' . $user->id . '@musicbrainz.invalid');
                    $c->forward('/discourse/sync_sso', [$user]);
                }
            }
        }

        $c->flash->{message} = l('User successfully edited.');
        $c->response->redirect($c->uri_for_action('/user/profile', [$user->name]));
        $c->detach;
    }

    $c->stash(
        user => $user,
        form => $form,
        form2 => $form2,
        show_flags => 1,
    );
}

sub delete_user : Path('/admin/user/delete') Args(1) RequireAuth HiddenOnSlaves {
    my ($self, $c, $name) = @_;

    my $editor = $c->model('Editor')->get_by_name($name);
    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $editor->id;

    $c->detach('/error_404') if !$editor || $editor->deleted;

    my $id = $editor->id;
    if ($id != $c->user->id && !$c->user->is_account_admin) {
        $c->detach('/error_403');
    }

    $c->stash( user => $editor );

    if ($c->form_posted) {
        $c->model('Editor')->delete($id);
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

sub edit_banner : Path('/admin/banner/edit') Args(0) RequireAuth(banner_editor) {
    my ($self, $c) = @_;

    my $current_message = $c->stash->{server_details}->{alert};
    my $form = $c->form( form => 'Admin::Banner',
                         init_object => { message => $current_message } );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $redis = $c->model('MB')->context->redis;

        $redis->set('alert', $form->values->{message});
        $redis->set('alert_mtime', time());

        $c->flash->{message} = l('Banner updated. Remember that each server has its own, independent banner.');
        $c->response->redirect($c->uri_for('/'));
        $c->detach;
    }
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
