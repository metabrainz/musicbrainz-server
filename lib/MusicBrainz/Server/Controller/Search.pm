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

    my $form = MusicBrainz::Server::Form::Search::Search->new;
    $c->stash( form => $form );

    if ($form->process( params => $c->req->query_params ))
    {
        $c->forward($form->field('direct')->value ? 'direct' : 'external');
    }
    else
    {
        $c->stash( template => 'search/index.tt' );
    }
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

    if ($type =~ /(recording|work|release_group)/)
    {
        $c->model('ArtistCredit')->load(map { $_->entity } @$results);
    }

    $c->stash(
        template => sprintf ('search/results-%s.tt', $type),
        results  => $results,
        type     => $type,
    );
}

sub external : Private
{
    my ($self, $c) = @_;

    
    my $form = $c->stash->{form};
    $c->stash->{template} = 'search/search.tt';

    return unless keys %{ $c->req->query_params } && $form->validate($c->req->query_params);

    my $type   = $form->field('type')->value;
    my $query  = $form->field('query')->value;

    $c->stash->{query} = $query;

    $c->detach('/search/editor') if $type eq 'editor';
    
    my $limit  = $form->value('limit') || 25;
    my $page   = $c->request->query_params->{page} || 1;
    my $offset = ($page - 1) * $limit;

    if ($query eq '!!!' and $type eq 'artist')
    {
        $query = 'chkchkchk';
    }

    unless ($form->value('enable_advanced'))
    {
        use MusicBrainz::Server::LuceneSearch;
        
        $query = MusicBrainz::Server::LuceneSearch::EscapeQuery($query);

        if ($type eq 'artist')
        {
            $query = "artist:($query)(sortname:($query) alias:($query) !artist:($query))";
        }
    }

    $query = uri_escape($query);
    
    my $search_url = sprintf("http://%s/ws/1/%s/?query=%s&offset=%s&max=%s",
                                 DBDefs::LUCENE_SERVER,
                                 $type,
                                 $query,
                                 $offset,
                                 $limit,);
    warn "Search $search_url";

    my $ua = LWP::UserAgent->new;
    $ua->timeout (2);
    $ua->env_proxy;

    # Dispatch the search request.
    my $response = $ua->get($search_url);
    unless ($response->is_success)
    {
        # Something went wrong with the search
        my $template = 'search/error/';

        # Switch on the response code to decide which template to provide
        use Switch;
        switch ($response->code)
        {
            case 404 { $template .= 'no-results.tt'; }
            case 403 { $template .= 'no-info.tt'; };
            case 500 { $template .= 'internal-error.tt'; }
            case 400 { $template .= 'invalid.tt'; }

            else { $template .= 'general.tt'; }
        }

        $c->stash->{content}  = $response->content;
        $c->stash->{query}    = $query;
        $c->stash->{type}     = $type;
        $c->stash->{template} = $template;

        $c->detach;
    }
    else
    {
        my $results = $response->content;

        # Because this branch has a different url scheme, we need to
        # update the URLs.
        # TODO Update when this branch is live in Xapian's code base.
        $results =~ s/\.html//g;

        # Parse information about total results
        my ($redirect, $total_hits);
        if ($results =~ /<!--\s+(.*?)\s+-->/s)
        {
            my $comments = $1;
            
            use Switch;
            foreach my $comment (split(/\n/, $comments))
            {
                my ($key, $value) = split(/=/, $comment, 2);

                switch ($key)
                {
                    case ('hits')     { $total_hits = $value; }
                    case ('redirect') { $redirect   = $value; }
                }
            }
        }

        # If the user searches for annotations, they will get the results in wikiformat - we need to
        # convert this to HTML.
        while ($results =~ /%WIKIBEGIN%(.*?)%WIKIEND%/s) 
        {
            use Text::WikiFormat;
            use DBDefs;

            my $temp = Text::WikiFormat::format($1, {}, { prefix => "http://".DBDefs::WIKITRANS_SERVER, extended => 1, absolute_links => 1, implicit_links => 0 });
            $results =~ s/%WIKIBEGIN%(.*?)%WIKIEND%/$temp/s;
        } 

        if ($redirect && $total_hits == 1 &&
            ($type eq 'artist' || $type eq 'release' || $type eq 'label'))
        {
            my $type_controller = $c->controller(
                "MusicBrainz::Server::Controller::" . ucfirst($type)
            );
            my $action = $type_controller->action_for('show');

            $c->res->redirect($c->uri_for($action, [ $redirect ]));
            $c->detach;
        }
        
        my $pager = Data::Page->new;
        $pager->current_page($page);
        $pager->entries_per_page($limit);
        $pager->total_entries($total_hits);

        $c->stash->{pager}   = $pager;
        $c->stash->{offset}  = $offset;
        $c->stash->{results} = $results;

        $c->stash->{template} = 'search/external.tt';
    }
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
