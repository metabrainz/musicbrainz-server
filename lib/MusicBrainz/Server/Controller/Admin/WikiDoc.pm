package MusicBrainz::Server::Controller::Admin::WikiDoc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Constants qw( $EDIT_WIKIDOC_CHANGE );

sub index : Path Args(0)
{
    my ($self, $c) = @_;

    my $index = $c->model('WikiDocIndex')->get_index;

    my @pages;
    foreach my $page (sort { lc $a cmp lc $b } keys %$index) {
        my $info = { id => $page, version => $index->{$page} };
        push @pages, $info;
    }

    my @wiki_pages = $c->model('WikiDocIndex')->get_wiki_versions($index);
    my $updates_required = 0;

    # Merge the data retreived from the wiki with the transclusion table
    for (my $i = 0; $i < @pages; $i++) {
        if (defined $wiki_pages[$i] && $pages[$i]->{id} eq $wiki_pages[$i]->{id}) {
            $pages[$i]->{wiki_version} = $wiki_pages[$i]->{wiki_version};

            # We want to know if updates are required so that we can update the template accordingly.
            $updates_required = 1 if $pages[$i]->{version} != $pages[$i]->{wiki_version};
        } else {
            if ($wiki_pages[$i]->{id}) {
                # API returned data, but in a different order than expected
                $c->log->error("'$pages[$i]->{id}' from the transclusion table doesn't match '$wiki_pages[$i]->{id}' from the wiki");
            } else {
                # Problem accessing the api data
                $c->stash->{wiki_unreachable} = 1;
            }
        }
    }

    $c->stash(
        pages            => \@pages,
        updates_required => $updates_required
    );
}

sub create : Local Args(0) RequireAuth(wiki_transcluder) Edit
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Admin::WikiDoc::Add' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = $form->values;
        my $page = $values->{page};
        $page =~ s/ /_/g;
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type    => $EDIT_WIKIDOC_CHANGE,
                editor_id    => $c->user->id,

                page        => $page,
                old_version => undef,
                new_version => $values->{version},
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }
}

sub edit : Local Args(0) RequireAuth(wiki_transcluder) Edit
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $new_version = $c->req->params->{new_version};
    my $current_version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form( form => 'Admin::WikiDoc::Edit',
                         init_object => { version => $new_version } );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = $form->values;
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type    => $EDIT_WIKIDOC_CHANGE,
                editor_id    => $c->user->id,

                page        => $page,
                old_version => $current_version,
                new_version => $values->{version},
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    $c->stash( page => $page, current_version => $current_version, new_version => $new_version );
}

sub delete : Local Args(0) RequireAuth(wiki_transcluder) Edit
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form( form => 'Confirm' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type    => $EDIT_WIKIDOC_CHANGE,
                editor_id    => $c->user->id,

                page        => $page,
                old_version => $version,
                new_version => undef,
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    $c->stash( page => $page, version => $version );
}

sub history : Local Args(0) RequireAuth {
    my ($self, $c) = @_;

    $c->res->redirect(
        $c->uri_for_action('/edit/search', {
            'conditions.0.field'    => 'type',
            'conditions.0.operator' => '=',
            'conditions.0.args'     => $EDIT_WIKIDOC_CHANGE
        }));
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Pavan Chander
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
