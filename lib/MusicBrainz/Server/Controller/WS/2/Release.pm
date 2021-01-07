package MusicBrainz::Server::Controller::WS::2::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Constants qw(
    $ACCESS_SCOPE_COLLECTION
    $ACCESS_SCOPE_SUBMIT_BARCODE
    $EDIT_RELEASE_EDIT_BARCODES
);
use List::AllUtils qw( uniq );
use List::UtilsBy qw( partition_by uniq_by );
use MusicBrainz::Server::WebService::XML::XPath;
use MusicBrainz::Server::Validation qw( is_guid is_valid_ean );
use Readonly;
use Try::Tiny;

my $ws_defs = Data::OptList::mkopt([
     release => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     release => {
                         method   => 'GET',
                         linked   => [ qw(area track_artist artist label
                                          recording release-group track
                                          collection) ],
                         inc      => [ qw(aliases artist-credits labels recordings discids
                                          tags user-tags genres user-genres ratings user-ratings
                                          release-groups media _relations annotation) ],
                         optional => [ qw(fmt limit offset) ],
     },
     release => {
                         action   => '/ws/2/release/lookup',
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups aliases
                                          tags user-tags genres user-genres ratings user-ratings collections user-collections
                                          artist-credits discids media recording-level-rels
                                          work-level-rels _relations annotation) ],
                         optional => [ qw(fmt) ],
     },
     release => {
                         method   => 'POST',
                         optional => [ qw( client ) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Release',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('release') CaptureArgs(0) { }

sub release_toplevel {
    my ($self, $c, $stash, $releases) = @_;

    my $inc = $c->stash->{inc};
    my @releases = @{$releases};

    $c->model('Release')->load_meta(@releases);
    $c->model('Release')->load_release_events(@releases);

    $self->linked_releases($c, $stash, $releases);

    $c->model('Release')->annotation->load_latest(@releases)
        if $inc->annotation;

    my %cover_art_presence =
        partition_by { $_->cover_art_presence eq 'present' ? 1 : 0 }
        @releases;

    if (my $art_present = $cover_art_presence{1}) {
        my @release_ids = map { $_->id } @$art_present;
        my $stats = $c->model('CoverArtArchive')->get_stats_for_releases(@release_ids);
        $stash->store($_)->{'cover-art-archive'} = $stats->{$_->id} for @$art_present;
    }

    if (my $art_not_present = $cover_art_presence{0}) {
        my $stats = {total => 0, front => 0, back => 0};
        $stash->store($_)->{'cover-art-archive'} = $stats for @$art_not_present;
    }

    my @rels_entities = @releases;
    my @ac_entities;

    if ($inc->artists)
    {
        push @ac_entities, @releases;
    }

    if ($inc->labels)
    {
        $c->model('ReleaseLabel')->load(@releases);

        my @release_labels = map { $_->all_labels } @releases;
        $c->model('Label')->load(@release_labels);

        my @labels = grep { defined } map { $_->label } @release_labels;
        $c->model('LabelType')->load(@labels);
        $self->linked_labels($c, $stash, \@labels);
    }

    if ($inc->release_groups)
    {
         $c->model('ReleaseGroup')->load(@releases);

         my @release_groups = map { $_->release_group } @releases;
         $c->model('ReleaseGroup')->load_meta(@release_groups);

         $self->linked_release_groups($c, $stash, \@release_groups);
    }

    if ($inc->recordings)
    {
        my @mediums = map { $_->all_mediums } @releases;

        if (!$inc->discids)
        {
            my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums(@mediums);
            $c->model('CDTOC')->load(@medium_cdtocs);
        }

        $c->model('Track')->load_for_mediums(@mediums);
        my @tracks = map { $_->all_tracks } @mediums;

        my @recordings = $c->model('Recording')->load(@tracks);
        $c->model('Recording')->load_meta(@recordings);
        $c->model('Recording')->load_first_release_date(@recordings);

        my $inc_artist_credits = $inc->artist_credits;
        if ($inc_artist_credits) {
            push @ac_entities, @tracks, @recordings;
        }

        # The maximum number of recordings to try to get relationships for, if
        # inc=recording-level-rels is specified. Certain releases with an enourmous
        # number of recordings (audiobooks) will almost always timeout, driving up
        # server load average for nothing. Ideally we can remove this limit as soon as
        # we resolve the performance issues we have.
        my $max_recording_relationships = 500;

        if ($inc->recording_level_rels && @recordings <= $max_recording_relationships) {
            push @rels_entities, @recordings;
        }

        # Disable artist-credits during linked_recordings, since we load
        # them below together with the tracks and release.
        $inc->artist_credits(0) if $inc_artist_credits;
        $self->linked_recordings($c, $stash, \@recordings);
        $inc->artist_credits(1) if $inc_artist_credits;
    }

    if ($inc->collections || $inc->user_collections) {
        if ($inc->user_collections) {
            $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);
        }
        my @collections;
        for my $release (@releases) {
            my ($collections, $total) = $c->model('Collection')->find_by({
                entity_type => 'release',
                entity_id => $release->id,
                # This should probably check $inc->user_collections instead of
                # $c->user_exists, but that would break the collections feature in
                # versions of Picard that didn't know about user-collections. Picard
                # would rely on user-tags or user-ratings to force authentication
                # and get private collections. See MBS-6152.
                show_private => $c->user_exists ? $c->user->id : undef,
                with_collaborations => 1,
            });

            push @collections, @{$collections};

            $stash->store($release)->{collections} =
                $self->make_list($collections, $total);
        }
        if (@collections) {
            $c->model('Editor')->load(@collections);
            $c->model('Collection')->load_entity_count(@collections);
            $c->model('CollectionType')->load(@collections);
        }
    }

    if (@ac_entities) {
        $c->model('ArtistCredit')->load(@ac_entities);

        my @acns = map { $_->all_names }
                   uniq map { $_->artist_credit } @ac_entities;

        $c->model('Artist')->load(@acns);
        my @artists = uniq map { $_->artist } @acns;
        $c->model('ArtistType')->load(@artists);

        $self->linked_artists($c, $stash, \@artists);
    }

    $self->load_relationships($c, $stash, @rels_entities);
}

sub release_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $releases;
    my $total;
    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless ($area);

        my @tmp = $c->model('Release')->find_by_area($area->id, $limit, $offset);
        $releases = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'artist') {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my @tmp = $c->model('Release')->find_by_artist(
            $artist->id, $limit, $offset, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
        $releases = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'collection') {
        $releases = $self->browse_by_collection($c, 'release', $id, $limit, $offset);
    } elsif ($resource eq 'track_artist') {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my @tmp = $c->model('Release')->find_by_track_artist(
            $artist->id, $limit, $offset, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
        $releases = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'track') {
        my $track = $c->model('Track')->get_by_gid($id);
        $c->detach('not_found') unless ($track);

        $c->model('Medium')->load($track);
        $c->model('Release')->load($track->medium);

        $c->stash->{inc}->recordings(1);
        $releases = $self->make_list([ $track->medium->release ], 1, 0);
    } elsif ($resource eq 'label') {
        my $label = $c->model('Label')->get_by_gid($id);
        $c->detach('not_found') unless ($label);

        my @tmp = $c->model('Release')->find_by_label(
            $label->id, $limit, $offset, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
        $releases = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'release-group') {
        my $rg = $c->model('ReleaseGroup')->get_by_gid($id);
        $c->detach('not_found') unless ($rg);

        my @tmp = $c->model('Release')->find_by_release_group(
            $rg->id, $limit, $offset, filter => { status => $c->stash->{status} });
        $releases = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'recording') {
        my $recording = $c->model('Recording')->get_by_gid($id);
        $c->detach('not_found') unless ($recording);

        my @tmp = $c->model('Release')->find_by_recording(
            $recording->id, $limit, $offset, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
        $releases = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->limit_releases_by_tracks($c, $releases->{items})
        if $c->stash->{inc}->recordings;

    $self->release_toplevel($c, $stash, $releases->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-list', $releases, $c->stash->{inc}, $stash));
}

sub release_search : Chained('root') PathPart('release') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('release_submit') if $c->request->method eq 'POST';
    $c->detach('release_browse') if ($c->stash->{linked});
    $self->_search($c, 'release');
}

sub release_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my $client = $c->req->query_params->{client} // $c->req->user_agent // '';

    my @submit;
    for my $node ($xp->find('/mb:metadata/mb:release-list/mb:release')->get_nodelist) {
        my $id = $xp->find('@mb:id', $node)->string_value or
            $self->_error($c, "All releases must have an MBID present");

        $self->_error($c, "$id is not a valid MBID")
            unless is_guid($id);

        my $barcode = $xp->find('mb:barcode', $node)->string_value or next;

        $self->_error($c, "$barcode is not a valid barcode")
            unless is_valid_ean($barcode);

        push @submit, { release => $id, barcode => $barcode };
    }

    my %gid_map = %{ $c->model('Release')->get_by_gids(map { $_->{release} } @submit) };

    for my $submission (@submit) {
        my $gid = $submission->{release};
        $self->_error($c, "$gid does not match any existing releases")
            unless exists $gid_map{$gid};
    }

    @submit = uniq_by { join(':', $_->{release}, $_->{barcode}) } @submit;
    @submit = $c->model('Release')->filter_barcode_changes(@submit);

    if (@submit) {
        $self->forbidden($c)
            unless $c->user->is_authorized($ACCESS_SCOPE_SUBMIT_BARCODE);
        $self->_error($c, 'Your client may not submit release barcodes')
            if $client eq '' || $client =~ /jaikoz/i; # MBS-8542

        try {
            $c->model('MB')->with_transaction(sub {
                $c->model('Edit')->create(
                    editor => $c->user,
                    privileges => $c->user->privileges,
                    edit_type => $EDIT_RELEASE_EDIT_BARCODES,
                    submissions => [ map +{
                        release => $gid_map{ $_->{release} },
                        barcode => $_->{barcode}
                    }, @submit ],
                    client_version => $client
                );
            });
        }
        catch {
            my $e = $_;
            $self->_error($c, "This edit could not be successfully created: $e");
        }
    }

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;

