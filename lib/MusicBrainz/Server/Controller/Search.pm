package MusicBrainz::Server::Controller::Search;

use strict;
use warnings;

use base 'Catalyst::Controller';

use UserStuff;

=head1 NAME

MusicBrainz::Server::Controller::Search - Handles searching the database

=head1 DESCRIPTION

This control handles searching the database for various data, such as artists and releases, but
also MusicBrainz specific data, such as editors and tags.

=head1 METHODS

=cut

# simple {{{
=head2 simple

Handle a "simple" search which has a type and a query. This then redirects to whichever
specific search action the search type maps to.

=cut
sub simple : Local {
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::Search::Simple;

    my $form = new MusicBrainz::Server::Form::Search::Simple;

    if ($c->form_posted && $form->validate($c->req->params))
    {
        $c->session->{last_simple_search} = $form->value('type');
        $c->detach($form->value('type'), [ $form->value('query') ]);
    }

    $c->stash->{template} = 'search/simple.tt';
}
# }}}
# editor {{{
sub editor : Local {
    my ($self, $c, $query) = @_;

    my $us = new UserStuff ($c->mb->{DBH});
    my $user = $us->newFromName($query);

    if(defined $user)
    {
        $c->response->redirect($c->uri_for('/user/profile', $user->GetName));
        $c->detach;
    }
    else
    {
        $c->stash->{could_not_find_user} = 1;
        $c->stash->{query} = $query;
        $c->stash->{template} = 'search/editor.tt';
    }
}
# }}}
# artist {{{
sub artist : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# release {{{
sub release : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# track {{{
sub track : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# label {{{
sub label : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
1;
