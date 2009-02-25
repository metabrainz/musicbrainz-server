package MusicBrainz::Server::Controller::Search;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use LWP::UserAgent;
use URI::Escape qw( uri_escape );

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

=cut

sub editor : Private
{
    my ($self, $c) = @_;

    my ($result, $users) = $c->model('User')->search($c->stash->{query});
    $c->stash->{users} = $users;
    $c->stash->{template} = 'search/editor.tt';
}

=head2 external

Search using an external search engine (currently Lucene, but moving
towards Xapian).

=cut

sub search : Path('') Form('Search::External')
{
    my ($self, $c) = @_;

    my $form = $self->form;
    
    $c->stash->{template} = 'search/search.tt';

    return unless keys %{ $c->req->query_params } && $form->validate($c->req->query_params);

    my $type   = $form->value('type');
    my $query  = $form->value('query');

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

=cut

sub filter_artist : Form('Search::Query')
{
    my ($self, $c) = @_;
    my $form = $self->form;

    if ($c->form_posted)
    {
        my $id = $c->req->params->{'search-id'};
        if (defined $id)
        {
            $c->stash->{search_result} = $c->model('Artist')->load($id);
        }
        else
        {
           return unless $c->req->params->{do_search} && $form->validate($c->req->params);
           my $artists = $c->model('Artist')->direct_search($form->value('query'));
           $c->stash->{artists} = $artists;

	   return;
        }
    }
}

sub filter_label : Form('Search::Query')
{
    my ($self, $c) = @_;

    my $form = $self->form;

    if ($c->form_posted)
    {
        my $id = $c->req->params->{'search-id'};
        if (defined $id)
        {
            $c->stash->{search_result} = $c->model('Label')->load($id);
        }
        else
        {
           return unless $c->req->params->{do_search} && $form->validate($c->req->params);
           my $labels = $c->model('Label')->direct_search($form->value('query'));
           $c->stash->{labels} = $labels;

	   return;
        }
    }
}

sub plugins : Local { }

sub links : Local { }

=head1 LICENSE

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

1;
