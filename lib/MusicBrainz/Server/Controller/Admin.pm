package MusicBrainz::Server::Controller::Admin;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub index : Path Args(0) RequireAuth
{
    my ($self, $c) = @_;

    $c->detach('/error_403')
        unless $c->user->is_admin;
}

sub adjust_flags : Path('/admin/user/adjust-flags') Args(1) RequireAuth(account_admin) HiddenOnSlaves
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name);
    my $form = $c->form(
        form => 'User::AdjustFlags',
        item => {
            auto_editor     => $user->is_auto_editor,
            bot             => $user->is_bot,
            untrusted       => $user->is_untrusted,
            link_editor     => $user->is_relationship_editor,
            no_nag          => $user->is_nag_free,
            wiki_transcluder=> $user->is_wiki_transcluder,
            mbid_submitter  => $user->is_mbid_submitter,
            account_admin   => $user->is_account_admin,
        },
    );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        # When an admin views their own flags page the account admin checkbox will be disabled,
        # thus we need to manually insert a value here to keep the admin's privileges intact.
        $form->values->{account_admin} = 1 if ($c->user->id == $user->id);

        $c->model('Editor')->update_privileges($user, $form->values);

        $c->response->redirect($c->uri_for_action('/user/adjustflags/view', [ $user->name ]));
        $c->detach;
    }

    $c->stash(
        user => $user,
        form => $form,
        show_flags => 1,
    );
}

sub delete_user : Path('/admin/user/delete') {
    my ($self, $c) = @_;
    my $editor = $c->model('Editor')->get_by_id($c->req->query_params->{editor_id});
    $c->stash( editor => $editor );
    if ($c->form_posted) {
        $c->model('Editor')->delete($editor->id);

        $editor = $c->model('Editor')->get_by_id($c->req->query_params->{editor_id});
        $c->response->redirect(
            $c->uri_for_action('/user/profile', [ $editor->name ]));
    }
}

1;

=head1 COPYRIGHT

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
