package MusicBrainz::Server::Controller::Admin::WikiDoc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Constants qw( $EDIT_WIKIDOC_CHANGE );
use MusicBrainz::Server::Edit::WikiDoc::Change;

sub index : Path Args(0) RequireAuth(wiki_transcluder)
{
    my ($self, $c) = @_;

    my $index = $c->model('WikiDocIndex')->get_index;
    my $showcur = $c->req->query_params->{showcur};
    my @pages;
    foreach my $page (sort { lc $a cmp lc $b } keys %$index) {
        my $info = { id => $page, version => $index->{$page} };
        if ($showcur) {
            $info->{current_version} = $c->model('WikiDoc')->get_current_page_version($page);
        }
        push @pages, $info;
    }

    $c->stash( pages => \@pages, show_current_version => $showcur );
}

sub create : Local Args(0) RequireAuth(wiki_transcluder)
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Admin::WikiDoc::Add' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = $form->values;
        my $edit = $c->model('Edit')->create(
            edit_type    => $EDIT_WIKIDOC_CHANGE,
            editor_id    => $c->user->id,

            page        => $values->{page},
            old_version => undef,
            new_version => $values->{version},
        );

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }
}

sub edit : Local Args(0) RequireAuth(wiki_transcluder)
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form( form => 'Admin::WikiDoc::Edit',
                         init_object => { version => $version } );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = $form->values;
        my $edit = $c->model('Edit')->create(
            edit_type    => $EDIT_WIKIDOC_CHANGE,
            editor_id    => $c->user->id,

            page        => $page,
            old_version => $version,
            new_version => $values->{version},
        );

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    $c->stash( page => $page, version => $version );
}

sub delete : Local Args(0) RequireAuth(wiki_transcluder)
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form( form => 'Confirm' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = $form->values;
        my $edit = $c->model('Edit')->create(
            edit_type    => $EDIT_WIKIDOC_CHANGE,
            editor_id    => $c->user->id,

            page        => $page,
            old_version => $version,
            new_version => undef,
        );

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    $c->stash( page => $page, version => $version );
}

no Moose;
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
