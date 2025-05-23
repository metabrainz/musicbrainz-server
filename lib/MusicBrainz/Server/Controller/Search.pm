package MusicBrainz::Server::Controller::Search;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::Controller';

use HTTP::Status qw( :constants );
use List::AllUtils qw( min max );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 type_to_model );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Form::Search::Search;
use Scalar::Util qw( looks_like_number );

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

        # $c->error may be set if an Internal Server Error occurs within the
        # direct/external search methods, e.g. a database query timeout.
        return if @{ $c->error };

        if ($type ne 'doc') {
            my $stash = $c->stash;

            my %props = (
                form => $stash->{form}->TO_JSON,
                lastUpdated => datetime_to_iso8601($stash->{last_updated}),
                pager => serialize_pager($stash->{pager}),
                query => $stash->{query},
                results => to_json_array($stash->{results}),
            );

            $c->stash(
                component_path => 'search/components/' . type_to_model($type) . 'Results',
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
                otherLookupForm => $c->stash->{otherlookup}->TO_JSON,
                searchForm => $c->stash->{form}->TO_JSON,
                tagLookupForm => $c->stash->{taglookup}->TO_JSON,
            },
            current_view => 'Node',
        );
    }
}

sub doc : Private
{
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'search/components/DocResults',
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

    my $model = $c->model(type_to_model($type));

    if ($model->can('load_aliases')) {
        $model->load_aliases(@entities);
    }

    if ($type eq 'artist') {
        $c->model('Artist')->load_related_info(@entities);
    }
    elsif ($type eq 'editor') {
        $c->model('Editor')->load_preferences(@entities);
    }
    elsif ($type eq 'release_group') {
        $c->model('ReleaseGroupType')->load(@entities);
        $c->model('ReleaseGroup')->load_has_cover_art(@entities);
    }
    elsif ($type eq 'release') {
        $c->model('Language')->load(@entities);
        $c->model('Release')->load_related_info(@entities);
        $c->model('Release')->load_meta(@entities);
        $c->model('Script')->load(@entities);
        $c->model('ReleaseStatus')->load(@entities);
        $c->model('ReleaseGroup')->load(@entities);
        $c->model('ReleaseGroupType')->load(map { $_->release_group }
            @entities);
    }
    elsif ($type eq 'label') {
        $c->model('LabelType')->load(@entities);
        $c->model('Area')->load(@entities);
    }
    elsif ($type eq 'recording') {
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
    elsif ($type eq 'work') {
        $c->model('Work')->load_authors(@entities);
        $c->model('Work')->load_other_artists(@entities);
        $c->model('Work')->load_recording_artists(@entities);
        $c->model('ISWC')->load_for_works(@entities);
        $c->model('Language')->load_for_works(@entities);
        $c->model('WorkType')->load(@entities);
    }
    elsif ($type eq 'area') {
        $c->model('AreaType')->load(@entities);
        $c->model('Area')->load_containment(@entities);
    }
    elsif ($type eq 'place') {
        $c->model('PlaceType')->load(@entities);
        $c->model('Area')->load(@entities);
    }
    elsif ($type eq 'instrument') {
        $c->model('InstrumentType')->load(@entities);
    }
    elsif ($type eq 'series') {
        $c->model('SeriesType')->load(@entities);
        $c->model('SeriesOrderingType')->load(@entities);
        $c->model('Series')->load_entity_count(@entities);
    }
    elsif ($type eq 'event') {
        $c->model('Event')->load_meta(@entities);
        $c->model('Event')->load_related_info(@entities);
        $c->model('Event')->load_areas(@entities);
    }
    elsif ($type eq 'tag') {
        $c->model('Genre')->load(@entities);
        $c->model('Genre')->load_aliases(map { $_->{genre} // () } @entities);
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
        my $code = $ret->{code};
        if ($code == HTTP_NOT_FOUND) { $template .= 'NoResults'; }
        elsif ($code == HTTP_FORBIDDEN) { $template .= 'NoInfo'; }
        elsif ($code == HTTP_URI_TOO_LONG) { $template .= 'UriTooLarge'; }
        elsif ($code == HTTP_INTERNAL_SERVER_ERROR) { $template .= 'InternalError'; }
        elsif ($code == HTTP_BAD_REQUEST) { $template .= 'Invalid'; }
        elsif ($code == HTTP_SERVICE_UNAVAILABLE) { $template .= 'RateLimited'; }
        else { $template .= 'General'; }

        my %props = (
            form => $c->stash->{form}->TO_JSON,
            error => $ret->{error},
            query => $query,
            type => $type,
        );

        $c->stash(
            component_path => $template,
            component_props => \%props,
            current_view => 'Node',
        );

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

1;

=head1 NAME

MusicBrainz::Server::Controller::Search - Handles searching the database

=head1 DESCRIPTION

This control handles searching the database for various data, such as
artists and releases, but also MusicBrainz specific data, such as editors
and tags.

=head1 METHODS

=head2 external

Search using an external search engine

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles
Copyright (C) 2012 Pavan Chander

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
