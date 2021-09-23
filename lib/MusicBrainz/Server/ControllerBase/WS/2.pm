package MusicBrainz::Server::ControllerBase::WS::2;
use Moose;
BEGIN { extends 'Catalyst::Controller'; }

use DBDefs;
use HTTP::Status qw( :constants );
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( type_to_model model_to_type object_to_ids );
use MusicBrainz::Server::Validation qw( is_guid is_nat );
use MusicBrainz::Server::WebService::Format;
use MusicBrainz::Server::WebService::JSONSerializer;
use MusicBrainz::Server::WebService::XMLSerializer;
use Readonly;
use Scalar::Util qw( looks_like_number );
use List::Util qw( sum );
use List::UtilsBy qw( partition_by );
use Try::Tiny;

with 'MusicBrainz::Server::WebService::Format' =>
{
    serializers => [
        'MusicBrainz::Server::WebService::XMLSerializer',
        'MusicBrainz::Server::WebService::JSONSerializer',
    ]
};

with 'MusicBrainz::Server::Controller::Role::Profile' => {
    threshold => DBDefs->PROFILE_WEB_SERVICE()
};

with 'MusicBrainz::Server::Controller::Role::CORS';
with 'MusicBrainz::Server::Controller::Role::ETags';

sub bad_req : Private
{
    my ($self, $c) = @_;

    $c->res->status(400);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub deny_readonly : Private
{
    my ($self, $c) = @_;
    if (DBDefs->DB_READ_ONLY) {
        $c->res->status(503);
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->output_error('The database is currently in readonly mode and cannot handle your request'));
        $c->detach;
    }
}

sub success : Private
{
    my ($self, $c) = @_;
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_success);
}

sub forbidden : Private
{
    my ($self, $c) = @_;
    $c->res->status(401);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error('You are not authorized to access this resource.'));
    $c->detach;
}

sub unauthorized : Private
{
    my ($self, $c) = @_;
    $c->res->status(401);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error('Your credentials '.
        'could not be verified. Either you supplied the wrong credentials '.
        q{(e.g., bad password), or your client doesn't understand how to }.
        'supply the credentials required.'));
    $c->detach;
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->res->status(404);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error('Not Found'));
}

sub invalid_mbid : Private
{
    my ($self, $c, $id) = @_;
    $c->stash->{error} = 'Invalid mbid.';
    $c->detach('bad_req');
}

sub method_not_allowed : Private {
    my ($self, $c) = @_;

    $c->res->status(405);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error(
        $c->req->method . ' is not allowed on this endpoint.'
    ));
}

sub not_implemented : Private
{
    my ($self, $c) = @_;

    $c->res->status(501);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error(q(This hasn't been implemented yet.)));
}

sub begin : Private {
    my ($self, $c) = @_;

    $c->stash->{current_view} = 'WS';
    $c->stash->{serializer} = $self->get_serialization($c);
}

sub end : Private { }

sub root : Chained('/') PathPart('ws/2') CaptureArgs(0)
{
    my ($self, $c) = @_;

    try {
        $self->validate($c) or $c->detach('bad_req');
    }
    catch {
        my $err = $_;
        if (eval { $err->isa('MusicBrainz::Server::WebService::Exceptions::UnknownIncParameter') }) {
            $self->_error($c, $err->message);
        }
        $c->detach;
    };

    $self->authenticate($c, $c->stash->{authorization_scope})
        if ($c->stash->{authorization_required});
}

sub authenticate {
    my ($self, $c, $scope) = @_;

    try {
        $c->authenticate({}, 'musicbrainz.org') unless $c->user_exists;
    } catch {
        # A 400 response code is already set in this case.
        $c->detach if $c->stash->{bad_auth_encoding};

        # $c->authenticate will try to detach on its own if it can't
        # authenticate using any method. But we want to return our own custom
        # error messages, via $self->forbidden or $self->unauthorized. So, we
        # catch Catalyst::Exception::Detach and handle that below.
        my $error = $_;
        unless (eval { $error->isa('Catalyst::Exception::Detach') }) {
            eval { $error = $error->message };
            $self->_error($c, $error);
        }
    };

    if (!$c->user || !$c->user->is_authorized($scope)) {
        my @authorization = $c->req->headers->header('Authorization');
        if (@authorization || exists $c->req->params->{access_token}) {
            $self->unauthorized($c);
        } else {
            $self->forbidden($c);
        }
    }
}

sub _error
{
    my ($self, $c, $error) = @_;

    $c->stash->{error} = $error;
    $c->detach('bad_req');
}

sub _search
{
    my ($self, $c, $entity) = @_;

    my $result = $c->model('WebService')->xml_search($entity, $c->stash->{args});
    if (DBDefs->SEARCH_X_ACCEL_REDIRECT && exists $result->{redirect_url}) {
        $c->res->headers->header(
            'X-Accel-Redirect' => $result->{redirect_url}
        );
    } else {
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        if (exists $result->{xml})
        {
            $c->res->body($result->{xml});
        }
        else
        {
            $c->res->status($result->{code});
            $c->res->body($c->stash->{serializer}->output_error($result->{error}));
        }
    }
}

sub _tags_and_ratings
{
    my $self = shift;
    $self->_tags(@_);
    $self->_ratings(@_);
}

sub _tags
{
    my ($self, $c, $modelname, $entities, $stash) = @_;

    my %map = object_to_ids(@$entities);
    my $model = $c->model($modelname);

    my @todo = grep { $c->stash->{inc}->$_ } qw( tags user_tags genres user_genres );

    for my $type (@todo) {
        my $find_method = 'find_' . $type . '_for_entities';
        my @tags = $model->tags->$find_method(
                        ($type =~ /^user_/ ? $c->user->id : ()),
                        map { $_->id } @$entities);

        my %tags_by_entity = partition_by { $_->entity_id } @tags;
        for my $id (keys %tags_by_entity) {
            $stash->store($map{$id}->[0])->{$type} = $tags_by_entity{$id};
        }
    }
}

sub _ratings
{
    my ($self, $c, $modelname, $entities, $stash) = @_;

    my %map = object_to_ids(@$entities);
    my $model = $c->model($modelname);

    if ($c->stash->{inc}->ratings)
    {
        $model->load_meta(@$entities);

        for (@$entities)
        {
            if ($_->rating_count)
            {
                $stash->store($_)->{ratings} = {
                    rating => $_->rating * 5 / 100,
                    count => $_->rating_count,
                };
            }
        }
    }

    if ($c->stash->{inc}->user_ratings)
    {
        $model->rating->load_user_ratings($c->user->id, @$entities);
        for (@$entities)
        {
            $stash->store($_)->{user_ratings} = $_->user_rating * 5 / 100
                if $_->user_rating;
        }
    }
}

sub _aliases {
    my ($self, $c, $model, $entities, $stash) = @_;

    if ($c->stash->{inc}->aliases) {
        my @aliases = @{ $c->model($model)->alias->find_by_entity_id(map { $_->id } @$entities) };

        $c->model($model)->alias_type->load(@aliases);

        my $entity_id = model_to_type($model) . '_id';
        my %alias_per_entity;

        for (@aliases) {
            $alias_per_entity{$_->$entity_id} = [] unless $alias_per_entity{$_->$entity_id};
            push @{ $alias_per_entity{$_->$entity_id} }, $_;
        }

        for (@$entities) {
            $stash->store($_)->{aliases} = $alias_per_entity{$_->id};
        }
    }
}

sub _limit_and_offset
{
    my ($self, $c) = @_;

    my $args = $c->stash->{args};
    my $limit = $args->{limit} ? $args->{limit} : 25;
    my $offset = $args->{offset} ? $args->{offset} : 0;

    if (!(is_nat($limit) && is_nat($offset))) {
        $self->_error(
            $c, q(The 'limit' and 'offset' parameters must be positive integers)
        );
    }

    return ($limit > 100 ? 100 : $limit, $offset);
}

sub make_list
{
    my ($self, $results, $total, $offset) = @_;

    return {
        items => $results,
        total => defined $total ? $total : scalar @$results,
        offset => defined $offset ? $offset : 0
    };
}

=head2 limit_releases_by_tracks

Truncates a list of releases such that the entire list doesn't contain more
than C<DBDefs::WS_TRACK_LIMIT> tracks in total (but returns at least one
release). The idea is to limit browse queries that contain an excessive number
of tracks when C<inc=recordings> is specified.

Note: This mutates the passed-in array reference C<$releases>.

=cut

sub limit_releases_by_tracks {
    my ($self, $c, $releases) = @_;

    my $track_count = 0;
    my $release_count = 0;

    for my $release (@{$releases}) {
        $c->model('Medium')->load_for_releases($release);
        $track_count += (sum map { $_->track_count } $release->all_mediums) // 0;
        last if $track_count > DBDefs->WS_TRACK_LIMIT && $release_count > 0;
        $release_count++;
    }

    @$releases = @$releases[0 .. ($release_count - 1)];
}

sub linked_artists
{
    my ($self, $c, $stash, $artists) = @_;

    $self->_tags_and_ratings($c, 'Artist', $artists, $stash);
    $self->_aliases($c, 'Artist', $artists, $stash);
}

sub linked_areas
{
    my ($self, $c, $stash, $areas) = @_;

    $self->_tags($c, 'Area', $areas, $stash);
    $self->_aliases($c, 'Area', $areas, $stash);
}

sub linked_instruments
{
    my ($self, $c, $stash, $instruments) = @_;

    $self->_tags($c, 'Instrument', $instruments, $stash);
    $self->_aliases($c, 'Instrument', $instruments, $stash);
}

sub linked_collections
{
    my ($self, $c, $stash, $collections) = @_;
}

sub linked_labels
{
    my ($self, $c, $stash, $labels) = @_;

    $self->_tags_and_ratings($c, 'Label', $labels, $stash);
    $self->_aliases($c, 'Label', $labels, $stash);
}

sub linked_places
{
    my ($self, $c, $stash, $places) = @_;

    $self->_tags_and_ratings($c, 'Place', $places, $stash);
    $self->_aliases($c, 'Place', $places, $stash);
}

sub linked_recordings
{
    my ($self, $c, $stash, $recordings) = @_;

    if ($c->stash->{inc}->isrcs)
    {
        my @isrcs = $c->model('ISRC')->find_by_recordings(map { $_->id } @$recordings);

        my %isrc_per_recording;
        for (@isrcs)
        {
            $isrc_per_recording{$_->recording_id} = [] unless $isrc_per_recording{$_->recording_id};
            push @{ $isrc_per_recording{$_->recording_id} }, $_;
        };

        for (@$recordings)
        {
            $stash->store($_)->{isrcs} = $isrc_per_recording{$_->id};
        }
    }

    if ($c->stash->{inc}->artist_credits)
    {
        $c->model('ArtistCredit')->load(@$recordings);

        my @acns = map { $_->artist_credit->all_names } @$recordings;
        $c->model('Artist')->load(@acns);
        my @artists = uniq map { $_->artist } @acns;
        $c->model('ArtistType')->load(@artists);

        $self->linked_artists($c, $stash, \@artists);
    }

    $self->_tags_and_ratings($c, 'Recording', $recordings, $stash);
    $self->_aliases($c, 'Recording', $recordings, $stash);
}

sub linked_releases
{
    my ($self, $c, $stash, $releases) = @_;

    $c->model('ReleaseStatus')->load(@$releases);
    $c->model('ReleasePackaging')->load(@$releases);
    $c->model('Release')->load_release_events(@$releases);

    $c->model('Language')->load(@$releases);
    $c->model('Script')->load(@$releases);

    my @mediums;
    if ($c->stash->{inc}->media || $c->stash->{inc}->recordings)
    {
        @mediums = map { $_->all_mediums } @$releases;

        unless (@mediums)
        {
            $c->model('Medium')->load_for_releases(@$releases);
            @mediums = map { $_->all_mediums } @$releases;
        }

        $c->model('MediumFormat')->load(@mediums);
    }

    if ($c->stash->{inc}->discids)
    {
        my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums(@mediums);
        $c->model('CDTOC')->load(@medium_cdtocs);
    }

    if ($c->stash->{inc}->artist_credits)
    {
        $c->model('ArtistCredit')->load(@$releases);

        my @acns = map { $_->artist_credit->all_names } @$releases;
        $c->model('Artist')->load(@acns);
        $c->model('ArtistType')->load(map { $_->artist } @acns);
    }

    $self->_tags($c, 'Release', $releases, $stash);
    $self->_aliases($c, 'Release', $releases, $stash);
}

sub linked_release_groups
{
    my ($self, $c, $stash, $release_groups) = @_;

    $c->model('ReleaseGroupType')->load(@$release_groups);

    if ($c->stash->{inc}->artist_credits)
    {
        $c->model('ArtistCredit')->load(@$release_groups);

        my @acns = map { $_->artist_credit->all_names } @$release_groups;
        $c->model('Artist')->load(@acns);
        my @artists = uniq map { $_->artist } @acns;
        $c->model('ArtistType')->load(@artists);

        $self->linked_artists($c, $stash, \@artists);
    }

    $self->_tags_and_ratings($c, 'ReleaseGroup', $release_groups, $stash);
    $self->_aliases($c, 'ReleaseGroup', $release_groups, $stash);
}

sub linked_works
{
    my ($self, $c, $stash, $works) = @_;

    $c->model('ISWC')->load_for_works(@$works);
    $c->model('Language')->load_for_works(@$works);

    $self->_tags_and_ratings($c, 'Work', $works, $stash);
    $self->_aliases($c, 'Work', $works, $stash);
}

sub linked_series {
    my ($self, $c, $stash, $series) = @_;

    $self->_tags($c, 'Series', $series, $stash);
    $self->_aliases($c, 'Series', $series, $stash);
}

sub linked_events
{
    my ($self, $c, $stash, $events) = @_;

    $self->_tags_and_ratings($c, 'Event', $events, $stash);
    $self->_aliases($c, 'Event', $events, $stash);
}

sub _validate_post
{
    my ($self, $c) = @_;

    my $h = $c->request->headers;

    unless ($h->content_type eq 'application/xml' &&
            $h->content_type_charset eq 'UTF-8') {
        $c->stash->{error} = '/ws/2/ only supports POST in application/xml; charset=UTF-8';
        $c->forward('bad_req');
        $c->res->status(415);
        $c->detach;
    }

    $self->_error($c, 'Please specify the name and version number of your client application.')
        unless $c->req->params->{client};
}

sub _validate_entity
{
    my ($self, $c) = @_;

    my $gid = $c->stash->{args}->{id};
    my $entity = $c->stash->{args}->{entity};
    $entity =~ s/-/_/;

    my $model = type_to_model($entity);

    if (!$gid || !is_guid($gid))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    if (!$model)
    {
        $c->stash->{error} = 'Invalid entity type.';
        $c->detach('bad_req');
    }

    $entity = $c->model($model)->get_by_gid($gid);
    $c->detach('not_found') unless ($entity);

    return ($entity, $model);
}

sub load_relationships {
    my ($self, $c, $stash, @for) = @_;

    if ($c->stash->{inc}->has_rels)
    {
        my $types = $c->stash->{inc}->get_rel_types();
        my @rels = $c->model('Relationship')->load_subset($types, @for);

        my @entities_with_rels = @for;

        my @works =
            uniq
            map { $_->target }
            grep { $_->target_type eq 'work' }
            map { $_->all_relationships } @for;

        if ($c->stash->{inc}->work_level_rels)
        {
            push(@entities_with_rels, @works);
            # Avoid returning recording-work relationships for other recordings
            $c->model('Relationship')->load_subset_cardinal($types, @works);
        }
        $self->linked_works($c, $stash, \@works);

        my %rels_by_target_type =
            partition_by { $_->target_type }
            map { $_->all_relationships } @entities_with_rels;

        for my $target_type (keys %rels_by_target_type) {
            my $rels = $rels_by_target_type{$target_type};
            if ($ENTITIES{$target_type}->{type} && $ENTITIES{$target_type}->{type}{simple}) {
                $c->model(type_to_model($target_type) . 'Type')->load(
                    map { $_->target } @$rels,
                );
            }
            if ($target_type eq 'place') {
                $c->model('AreaType')->load(map { $_->area } map { $_->target } @$rels);
            }
        }

        my $collect_works = sub {
            my $relationship = shift;
            return (
                ($relationship->target_type eq 'work' && $relationship->target) || (),
                ($relationship->source_type eq 'work' && $relationship->source) || (),
            );
        };

        my @releases = map { $_->target } grep { $_->target_type eq 'release' }
            map { $_->all_relationships } @for;

        my @load_language_for = (
            @releases,
            map { $collect_works->($_) } (@rels, map { $_->all_relationships } @works)
        );

        $c->model('Language')->load(@load_language_for);
        $c->model('Script')->load(@releases);
        $c->model('Release')->load_release_events(@releases);
    }
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
