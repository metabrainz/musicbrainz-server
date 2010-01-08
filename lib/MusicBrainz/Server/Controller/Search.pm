package MusicBrainz::Server::Controller::Search;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use LWP::UserAgent;
use MusicBrainz::Server::Form::Search::Query;
use MusicBrainz::Server::Form::Search::Search;
use URI::Escape qw( uri_escape );

sub search : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->stash->{sidebar_search};
    $c->stash( form => $form );

    if ($form->process( params => $c->req->query_params ))
    {
        if ($form->field('type')->value eq 'editor') {
            $c->forward('editor');
        }
        else {
            $c->forward($form->field('direct')->value ? 'direct' : 'external');
        }
    }
    else
    {
        $c->stash( template => 'search/index.tt' );
    }
}

sub editor : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    my $query = $form->field('query')->value;
    my $editor = $c->model('Editor')->get_by_name($query);
    if (defined $editor) {
        $c->res->redirect($c->uri_for_action('/user/profile', $editor->name));
        $c->detach;
    }

    $c->stash( template => 'search/editor-not-found.tt' );
}

sub direct : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    my $type   = $form->field('type')->value;
    my $query  = $form->field('query')->value;

    my $results = $self->_load_paged($c, sub {
       $c->model('DirectSearch')->search($type, $query, shift, shift);
    });

    if ($type =~ /(recording|work|release|release_group)/)
    {
        $c->model('ArtistCredit')->load(map { $_->entity } @$results);
    }

    $c->stash(
        template => sprintf ('search/results-%s.tt', $type),
        results  => $results,
        type     => $type,
    );
}

sub filter : Private
{
    my ($self, $c, $type, $model, $default) = @_;

    my $query = $c->form( query_form => 'Search::Query', name => 'filter' );
    my $results = $c->form( results_form => 'Search::Results' );

    if ($c->form_posted)
    {
        if ($results->submitted_and_valid($c->req->params))
        {
            return $c->model($model)->get_by_id($results->field('selected_id')->value);
        }
        elsif ($query->submitted_and_valid($c->req->params))
        {
            my $q = $query->field('query')->value;
            $c->stash(
                search_results => $self->_load_paged($c, sub {
                        $c->model('DirectSearch')->search($type, $q, shift, shift)
                    })
            );
        }
    }

    $c->detach;
}

sub plugins : Local { }

sub links : Local { }

1;

=head1 NAME

MusicBrainz::Server::Controller::Search - Handles searching the database

=head1 DESCRIPTION

This control handles searching the database for various data, such as
artists and releases, but also MusicBrainz specific data, such as editors
and tags.

=head1 METHODS

=head2 editor

Serach for a MusicBrainz database.

This search is performed right in this action, and is not dispatched to
one of the MusicBrainz search servers. It searches for a moderator with
the exact name given, and if found, redirects to their profile page. If
no moderator could be found, the user is informed.

=head2 external

Search using an external search engine (currently Lucene, but moving
towards Xapian).

=head2 filter_artist

Provide a form for users to search for an artist. This is a 3 stage form.

=over 4

=item First, the user is presented with the form and enters a query

=item Then the user is presented with a list of search results

=item Finally, the user selects a result and may continue.

=back

To retrieve the item that the user has selected, you should use the
C<state> method of the current context. For example:

    $c->forward('/search/fitler_artist');
    if (defined $c->state)
    {
        # Do stuff with the artist
    }
    else
    {
        # No search result yet, probably want to wait
        # until we have an artist
    }

=head1 LICENSE

Copyright (C) 2009 Oliver Charles

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut
