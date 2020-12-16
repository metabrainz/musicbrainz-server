package MusicBrainz::Server::Controller::WS::2::Recording;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::Buffer';
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_ADD_ISRCS
    $ACCESS_SCOPE_SUBMIT_ISRC
);

use MusicBrainz::Server::Validation qw( is_valid_isrc is_guid );
use MusicBrainz::Server::WebService::XML::XPath;
use Readonly;
use Try::Tiny;

my $ws_defs = Data::OptList::mkopt([
     recording => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     recording => {
                         method   => 'GET',
                         linked   => [ qw(artist release collection work) ],
                         inc      => [ qw(aliases artist-credits puids isrcs annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings
                                          work-level-rels) ],
                         optional => [ qw(fmt limit offset) ],
     },
     recording => {
                         action   => '/ws/2/recording/lookup',
                         method   => 'GET',
                         inc      => [ qw(artists releases artist-credits puids isrcs aliases
                                          _relations tags user-tags genres user-genres ratings user-ratings
                                          release-groups work-level-rels annotation) ],
                         optional => [ qw(fmt) ],
     },
     recording => {
                         method => 'POST'
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Recording',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('recording') CaptureArgs(0) { }

sub recording_toplevel
{
    my ($self, $c, $stash, $recordings) = @_;

    my $inc = $c->stash->{inc};
    my @recordings = @{$recordings};
    my @load_acs;

    $self->linked_recordings($c, $stash, $recordings);

    $c->model('Recording')->annotation->load_latest(@recordings)
        if $inc->annotation;

    $c->model('Recording')->load_first_release_date(@recordings);

    $self->load_relationships($c, $stash, @recordings);

    if ($inc->releases) {
        for my $recording (@recordings) {
            my $opts = $stash->store($recording);
            my @results;

            if ($inc->media) {
                @results = $c->model('Release')->load_with_medium_for_recording(
                    $recording->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
            } else {
                @results = $c->model('Release')->find_by_recording(
                    $recording->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
            }

            my @releases = @{$results[0]};

            $opts->{releases} = $self->make_list(@results);

            $self->linked_releases($c, $stash, \@releases);

            push @load_acs,
                map { $_->all_tracks }
                map { $_->all_mediums } @releases
                if $inc->artist_credits;

            if ($inc->release_groups) {
                $c->model('ReleaseGroup')->load(@releases);

                my @release_groups = map { $_->release_group } @releases;
                $c->model('ReleaseGroup')->load_meta(@release_groups);
                $c->model('ReleaseGroupType')->load(@release_groups);

                push @load_acs, @release_groups
                    if $inc->artist_credits;
            }
        }
    }

    if ($inc->artists) {
        push @load_acs, @recordings;
    }

    if (@load_acs) {
        $c->model('ArtistCredit')->load(@load_acs);
        my @acns = map { $_->artist_credit->all_names } @load_acs;
        $c->model('Artist')->load(@acns);
        $c->model('ArtistType')->load(map { $_->artist } @acns);

        if ($inc->artists) {
            $self->linked_artists(
                $c, $stash,
                [ map { $_->artist }
                  map { $_->artist_credit->all_names } @recordings ]
            );
        }
    }
}

sub recording_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $recordings;
    if ($resource eq 'artist')
    {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my @tmp = $c->model('Recording')->find_by_artist($artist->id, $limit, $offset);
        $recordings = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'collection') {
        $recordings = $self->browse_by_collection($c, 'recording', $id, $limit, $offset);
    }
    elsif ($resource eq 'release')
    {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('Recording')->find_by_release($release->id, $limit, $offset);
        $recordings = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'work')
    {
        my $work = $c->model('Work')->get_by_gid($id);
        $c->detach('not_found') unless ($work);

        my @tmp = $c->model('Recording')->find_by_works([$work->id], $limit, $offset);
        $recordings = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->recording_toplevel($c, $stash, $recordings->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('recording-list', $recordings, $c->stash->{inc}, $stash));
}

sub recording_search : Chained('root') PathPart('recording') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('recording_submit') if $c->req->method eq 'POST';
    $c->detach('recording_browse') if ($c->stash->{linked});

    $self->_search($c, 'recording');
}

sub recording_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    my $client = $c->req->query_params->{client}
        or $self->_error($c, 'You must provide information about your client, by the client query parameter');
    $self->bad_req($c, 'Invalid argument "client"') if ref($client);

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my (%submit_isrc);
    for my $node ($xp->find('/mb:metadata/mb:recording-list/mb:recording')->get_nodelist)
    {
        my $id = $xp->find('@mb:id', $node)->string_value or
            $self->_error($c, "All releases must have an MBID present");

        $self->_error($c, "$id is not a valid MBID")
            unless is_guid($id);

        my @isrcs = $xp->find('mb:isrc-list/mb:isrc', $node)->get_nodelist;
        for my $isrc_node (@isrcs) {
            my $isrc = $xp->find('@mb:id', $isrc_node)->string_value;
            $self->_error($c, "$isrc is not a valid ISRC")
                unless is_valid_isrc($isrc);

            $submit_isrc{ $id } ||= [];
            push @{ $submit_isrc{$id} }, $isrc;
        }
    }

    my %recordings_by_gid = %{ $c->model('Recording')->get_by_gids(keys %submit_isrc) };

    for my $recording_gid (keys %submit_isrc) {
        $self->_error($c, "$recording_gid does not match any known recordings")
            unless exists $recordings_by_gid{$recording_gid};
    }

    if (%submit_isrc) {
        $self->forbidden($c)
            unless $c->user->is_authorized($ACCESS_SCOPE_SUBMIT_ISRC);
    }

    if (!$c->user->has_confirmed_email_address) {
        $self->_error($c, "You must have a verified email address to submit edits");
    }

    $c->model('MB')->with_transaction(sub {
        # Submit ISRCs
        my $buffer = Buffer->new(
            limit => 100,
            on_full => sub {
                my $contents = shift;
                try {
                    $c->model('Edit')->create(
                        edit_type      => $EDIT_RECORDING_ADD_ISRCS,
                        editor         => $c->user,
                        isrcs          => $contents,
                        client_version => $client
                    );
                }
                    catch {
                        my $err = $_;
                        unless (blessed($err) && $err->isa('MusicBrainz::Server::Edit::Exceptions::NoChanges')) {
                            # Ignore the NoChanges exception
                            die $err;
                        }
                    };
            }
        );

        $buffer->flush_on_complete(sub {
            for my $recording_gid (keys %submit_isrc) {
                $buffer->add_items(map +{
                    recording => {
                        id => $recordings_by_gid{$recording_gid}->id,
                        name => $recordings_by_gid{$recording_gid}->name
                    },
                    isrc         => $_
                }, @{ $submit_isrc{$recording_gid} });
            }
        });
    });

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;

