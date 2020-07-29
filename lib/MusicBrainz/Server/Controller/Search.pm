package MusicBrainz::Server::Controller::Search;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::Util qw( min max );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 model_to_type type_to_model );
use MusicBrainz::Server::Form::Search::Query;
use MusicBrainz::Server::Form::Search::Search;
use Scalar::Util qw( looks_like_number );
use feature 'switch';

no if $] >= 5.018, warnings => "experimental::smartmatch";

sub search : Path('')
{
    my ($self, $c) = @_;

    # Backwards compatibility with existing URLs
    $c->req->query_params->{method} = 'direct'
        if ($c->req->query_params->{direct} // '') eq 'on';

    $c->req->query_params->{type} = 'recording'
        if exists $c->req->query_params->{type} && $c->req->query_params->{type} eq 'track';

    # ?adv=1 or ?advanced=1 means use the 'advanced' search method
    $c->req->query_params->{method} = 'advanced'
        if $c->req->query_params->{adv} || $c->req->query_params->{advanced};

    # The form should really be responsible for this, but I can't see a way
    # to make the field optional, but always have a value
    $c->req->query_params->{method} ||= 'indexed'
        if $c->req->query_params->{query};

    my $form = $c->stash->{sidebar_search};
    $c->stash( form => $form );
    $c->stash->{taglookup} = $c->form( tag_lookup => 'TagLookup' );
    $c->stash->{otherlookup} = $c->form( other_lookup => 'OtherLookup' );

    if ($form->process( params => $c->req->query_params ))
    {
        my $type = $form->field('type')->value;

        if ($type eq 'annotation' ||
            $type eq 'cdstub') {
            $form->field('method')->value('indexed')
                if $form->field('method')->value eq 'direct';
            $c->forward('external');
        }
        elsif ($type eq 'tag')
        {
            $form->field('method')->value('direct');
            $c->forward('direct');
        }
        elsif ($type eq 'doc')
        {
            $c->forward('doc');
        }
        else {
            $c->forward($form->field('method')->value eq 'direct' ? 'direct' : 'external');
        }

        if ($type ne 'doc') {
            my $stash = $c->stash;

            my %props = (
                form => $stash->{form},
                lastUpdated => datetime_to_iso8601($stash->{last_updated}),
                pager => serialize_pager($stash->{pager}),
                query => $stash->{query},
                results => $stash->{results},
            );

            $c->stash(
                component_path => 'search/components/' . type_to_model($type) . 'Results.js',
                component_props => \%props,
                current_view => 'Node',
            );
        }
    }
    else
    {
        $c->stash(
            component_path => 'search/SearchIndex',
            component_props => {
                otherLookupForm => $c->stash->{otherlookup},
                searchForm => $c->stash->{form},
                tagLookupForm => $c->stash->{taglookup},
            },
            current_view => 'Node',
        );
    }
}

sub doc : Private
{
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'search/components/DocResults.js',
        current_view => 'Node',
    );
}


sub direct : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    my $type   = $form->field('type')->value;
    my $query  = $form->field('query')->value;

    my $results = $self->_load_paged($c, sub {
       $c->model('Search')->search($type, $query, shift, shift);
    }, limit => $form->field('limit')->value);

    my @entities = map { $_->entity } @$results;

    given ($type) {
        when ('artist') {
            $c->model('ArtistType')->load(@entities);
            $c->model('Area')->load(@entities);
            $c->model('Gender')->load(@entities);
        }
        when ('editor') {
            $c->model('Editor')->load_preferences(@entities);
        }
        when ('release_group') {
            $c->model('ReleaseGroupType')->load(@entities);
        }
        when ('release') {
            $c->model('Language')->load(@entities);
            $c->model('Release')->load_related_info(@entities);
            $c->model('Script')->load(@entities);
            $c->model('ReleaseStatus')->load(@entities);
            $c->model('ReleaseGroup')->load(@entities);
            $c->model('ReleaseGroupType')->load(map { $_->release_group }
                @entities);
        }
        when ('label') {
            $c->model('LabelType')->load(@entities);
            $c->model('Area')->load(@entities);
        }
        when ('recording') {
            my %recording_releases_map = $c->model('Release')->find_by_recordings(map {
                $_->entity->id
            } @$results);
            my %result_map = map { $_->entity->id => $_ } @$results;

            $result_map{$_}->extra($recording_releases_map{$_}) for keys %recording_releases_map;

            my @releases = map { $_->{release} } map { @{ $_->extra } } @$results;
            $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
            $c->model('Medium')->load_for_releases(@releases);
            $c->model('Track')->load_for_mediums(map { $_->all_mediums } @releases);
            $c->model('Recording')->load(
                map { $_->all_tracks } map { $_->all_mediums } @releases);
            $c->model('ISRC')->load_for_recordings(map { $_->entity } @$results);
        }
        when ('work') {
            $c->model('Work')->load_writers(@entities);
            $c->model('Work')->load_recording_artists(@entities);
            $c->model('ISWC')->load_for_works(@entities);
            $c->model('Language')->load_for_works(@entities);
            $c->model('WorkType')->load(@entities);
        }
        when ('area') {
            $c->model('AreaType')->load(@entities);
            $c->model('Area')->load_containment(@entities);
        }
        when ('place') {
            $c->model('PlaceType')->load(@entities);
            $c->model('Area')->load(@entities);
        }
        when ('instrument') {
            $c->model('InstrumentType')->load(@entities);
        }
        when ('series') {
            $c->model('SeriesType')->load(@entities);
            $c->model('SeriesOrderingType')->load(@entities);
        }
        when ('event') {
            $c->model('Event')->load_related_info(@entities);
            $c->model('Event')->load_areas(@entities);
        }
        when ('tag') {
            #TODO: add support for genre aliases when finishing MBS-10062
            $c->model('Genre')->load(@entities);
        }
    }

    if ($type =~ /(recording|release|release_group)/)
    {
        $c->model('ArtistCredit')->load(@entities);
    }

    $c->stash(
        query    => $query,
        results  => $results,
        type     => $type,
    );
}

sub external : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    return unless keys %{ $c->req->query_params } && $form->validate($c->req->query_params);

    my $type   = $form->field('type')->value;
    my $query  = $form->field('query')->value;

    $c->stash->{query} = $query;

    $self->do_external_search($c,
                              query    => $query,
                              type     => $type,
                              limit    => $form->field('limit')->value,
                              page     => $c->request->query_params->{page},
                              advanced => $form->field('method')->value eq 'advanced');
}

sub do_external_search {
    my ($self, $c, %opts) = @_;

    my $page  = looks_like_number($c->request->query_params->{page})
                    ? $c->request->query_params->{page} : 1;
    $page = max(1, $page);

    my $limit = looks_like_number($opts{limit}) ? $opts{limit} : 25;
    $limit = min(max(1, $limit), 100);

    my $advanced = $opts{advanced} ? 1 : 0;

    my $query = $opts{query};
    my $type  = $opts{type};

    my $search = $c->model('Search');
    my $ret = $search->external_search($type,
                                       $query,
                                       $limit,
                                       $page,
                                       $advanced);

    if (exists $ret->{error})
    {
        # Something went wrong with the search
        my $template = 'search/error/';

        # Switch on the response code to decide which template to provide
        given ($ret->{code})
        {
            when (404) { $template .= 'no-results.tt'; }
            when (403) { $template .= 'no-info.tt'; };
            when (414) { $template .= 'uri-too-large.tt'; };
            when (500) { $template .= 'internal-error.tt'; }
            when (400) { $template .= 'invalid.tt'; }
            when (503) { $template .= 'rate-limit.tt'; }

            default { $template .= 'general.tt'; }
        }

        $c->stash->{content}  = $ret->{error};
        $c->stash->{query}    = $query;
        $c->stash->{type}     = $type;
        $c->stash->{template} = $template;

        $c->detach;
    }
    else
    {
        $c->stash->{pager}    = $ret->{pager};
        $c->stash->{offset}   = $ret->{offset};
        $c->stash->{results}  = $ret->{results};
        $c->stash->{last_updated}  = $ret->{last_updated};
    }
}

sub filter : Private
{
    my ($self, $c, $type, $model, $default) = @_;

    my $query = $c->form( query_form => 'Search::Query', name => 'filter' );
    my $results = $c->form( results_form => 'Search::Results' );

    if ($c->form_posted_and_valid($results))
    {
        return $c->model($model)->get_by_id($results->field('selected_id')->value);
    }
    elsif ($c->form_posted_and_valid($query))
    {
        my $q = $query->field('query')->value;
        $c->stash(
            search_results => $self->_load_paged($c, sub {
                    $c->model('DirectSearch')->search($type, $q, shift, shift)
                })
        );
    }

    $c->detach;
}

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

Search using an external search engine

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
Copyright (C) 2012 Pavan Chander

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
