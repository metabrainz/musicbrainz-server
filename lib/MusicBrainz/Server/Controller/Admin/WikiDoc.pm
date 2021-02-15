package MusicBrainz::Server::Controller::Admin::WikiDoc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Constants qw( $EDIT_WIKIDOC_CHANGE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

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
    my $wiki_unreachable = 0;

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
                $wiki_unreachable = 1;
            }
        }
    }

    my %props = (
        pages             => \@pages,
        updatesRequired   => boolean_to_json($updates_required),
        wikiIsUnreachable => boolean_to_json($wiki_unreachable),
        wikiServer        => $c->stash->{wiki_server},
    );

    $c->stash(
        component_path => 'admin/wikidoc/WikiDocIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub create : Local Args(0) RequireAuth(wiki_transcluder) Edit SecureForm
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Admin::WikiDoc::Add' );

    if ($c->form_posted_and_valid($form)) {
        my $values = $form->values;
        my $page = $values->{page} =~ tr/ /_/r;
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type   => $EDIT_WIKIDOC_CHANGE,
                editor      => $c->user,

                page        => $page,
                old_version => undef,
                new_version => $values->{version},
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    $c->stash(
        component_path => 'admin/wikidoc/CreateWikiDoc',
        component_props => {form => $form},
        current_view => 'Node',
    );
}

sub edit : Local Args(0) RequireAuth(wiki_transcluder) Edit SecureForm
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $new_version = $c->req->params->{new_version};
    my $current_version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form( form => 'Admin::WikiDoc::Edit',
                         init_object => { version => $new_version } );

    if ($c->form_posted_and_valid($form)) {
        my $values = $form->values;
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type   => $EDIT_WIKIDOC_CHANGE,
                editor      => $c->user,

                page        => $page,
                old_version => $current_version,
                new_version => $values->{version},
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    my %props = (
        currentVersion => $current_version,
        form            => $form,
        page            => $page,
    );

    $c->stash(
        component_path => 'admin/wikidoc/EditWikiDoc',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub delete : Local Args(0) RequireAuth(wiki_transcluder) Edit SecureForm
{
    my ($self, $c) = @_;

    my $page = $c->req->params->{page};
    my $version = $c->model('WikiDocIndex')->get_page_version($page);
    my $form = $c->form(
        form => 'SecureConfirm'
    );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            my $edit = $c->model('Edit')->create(
                edit_type   => $EDIT_WIKIDOC_CHANGE,
                editor      => $c->user,

                page        => $page,
                old_version => $version,
                new_version => undef,
            );
        });

        my $url = $c->uri_for_action('/admin/wikidoc/index');
        $c->response->redirect($url);
        $c->detach;
    }

    my %props = (
        form    => $form,
        page    => $page,
    );

    $c->stash(
        component_path => 'admin/wikidoc/DeleteWikiDoc',
        component_props => \%props,
        current_view => 'Node',
    );
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Pavan Chander
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
