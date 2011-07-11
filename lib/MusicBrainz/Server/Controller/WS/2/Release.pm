package MusicBrainz::Server::Controller::WS::2::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDIT_BARCODES
);
use MusicBrainz::Server::WebService::XML::XPath;
use Readonly;
use TryCatch;

my $ws_defs = Data::OptList::mkopt([
     release => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ],
     },
     release => {
                         method   => 'GET',
                         linked   => [ qw(artist label recording release-group) ],
                         inc      => [ qw(artist-credits labels recordings discids media _relations) ],
                         optional => [ qw(limit offset) ],
     },
     release => {
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups aliases
                                          tags user-tags ratings user-ratings
                                          artist-credits discids media recording-level-rels
                                          work-level-rels _relations) ]
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

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Release',
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('release') CaptureArgs(0) { }

sub release_toplevel
{
    my ($self, $c, $stash, $release) = @_;

    $c->model('Release')->load_meta($release);
    $self->linked_releases ($c, $stash, [ $release ]);

    my @rels_entities = $release;

    if ($c->stash->{inc}->artists)
    {
        $c->model('ArtistCredit')->load($release);

        my @artists = map { $c->model('Artist')->load ($_); $_->artist } @{ $release->artist_credit->names };

        $self->linked_artists ($c, $stash, \@artists);
    }

    if ($c->stash->{inc}->labels)
    {
        $c->model('ReleaseLabel')->load($release);
        $c->model('Label')->load($release->all_labels);

        my @labels = grep { defined } map { $_->label } $release->all_labels;

        $self->linked_labels ($c, $stash, \@labels);
    }

    if ($c->stash->{inc}->release_groups)
    {
         $c->model('ReleaseGroup')->load($release);
         $c->model('ReleaseGroup')->load_meta($release->release_group);

         my $rg = $release->release_group;

         $self->linked_release_groups ($c, $stash, [ $rg ]);
    }

    if ($c->stash->{inc}->recordings)
    {
        my @mediums;
        if (!$c->stash->{inc}->media)
        {
            $c->model('Medium')->load_for_releases($release);
        }

        @mediums = $release->all_mediums;

        my @tracklists = grep { defined } map { $_->tracklist } @mediums;
        $c->model('Track')->load_for_tracklists(@tracklists);
        $c->model('ArtistCredit')->load(map { $_->all_tracks } @tracklists)
            if ($c->stash->{inc}->artist_credits);

        my @recordings = $c->model('Recording')->load(map { $_->all_tracks } @tracklists);
        $c->model('Recording')->load_meta(@recordings);

        if ($c->stash->{inc}->recording_level_rels)
        {
            push @rels_entities, @recordings;
        }

        $self->linked_recordings ($c, $stash, \@recordings);
    }

    if ($c->stash->{inc}->has_rels)
    {
        my $types = $c->stash->{inc}->get_rel_types();
        $c->model('Relationship')->load_subset($types, @rels_entities);

        if ($c->stash->{inc}->work_level_rels)
        {
            my @works =
                map { $_->target }
                grep { $_->target_type eq 'work' }
                map { $_->all_relationships } @rels_entities;
            $c->model('Relationship')->load_subset($types, @works);
        }
    }

}

sub release: Chained('root') PathPart('release') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $release = $c->model('Release')->get_by_gid($gid);
    unless ($release) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;

    $self->release_toplevel ($c, $stash, $release);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release', $release, $c->stash->{inc}, $stash));
}

sub release_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset ($c);

    if (!MusicBrainz::Server::Validation::IsGUID($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $releases;
    my $total;
    if ($resource eq 'artist')
    {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my @tmp = $c->model('Release')->find_by_artist (
            $artist->id, $limit, $offset, $c->stash->{status}, $c->stash->{type});
        $releases = $self->make_list (@tmp, $offset);
    }
    elsif ($resource eq 'label')
    {
        my $label = $c->model('Label')->get_by_gid($id);
        $c->detach('not_found') unless ($label);

        my @tmp = $c->model('Release')->find_by_label (
            $label->id, $limit, $offset, $c->stash->{status}, $c->stash->{type});
        $releases = $self->make_list (@tmp, $offset);
    }
    elsif ($resource eq 'release-group')
    {
        my $rg = $c->model('ReleaseGroup')->get_by_gid($id);
        $c->detach('not_found') unless ($rg);

        my @tmp = $c->model('Release')->find_by_release_group (
            $rg->id, $limit, $offset, $c->stash->{status});
        $releases = $self->make_list (@tmp, $offset);
    }
    elsif ($resource eq 'recording')
    {
        my $recording = $c->model('Recording')->get_by_gid($id);
        $c->detach('not_found') unless ($recording);

        my @tmp = $c->model('Release')->find_by_recording (
            $recording->id, $limit, $offset, $c->stash->{status}, $c->stash->{type});
        $releases = $self->make_list (@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    for (@{ $releases->{items} })
    {
        $self->release_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-list', $releases, $c->stash->{inc}, $stash));
}

sub release_search : Chained('root') PathPart('release') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('release_submit') if $c->request->method eq 'POST';
    $c->detach('release_browse') if ($c->stash->{linked});
    $self->_search ($c, 'release');
}

sub release_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my @submit;
    for my $node ($xp->find('/mb:metadata/mb:release-list/mb:release')->get_nodelist) {
        my $id = $xp->find('@mb:id', $node)->string_value or
            $self->_error ($c, "All releases must have an MBID present");

        $self->_error($c, "$id is not a valid MBID")
            unless MusicBrainz::Server::Validation::IsGUID($id);

        my $barcode = $xp->find('mb:barcode', $node)->string_value or next;

        $self->_error($c, "$barcode is not a valid barcode")
            unless MusicBrainz::Server::Validation::IsValidEAN($barcode);

        push @submit, { release => $id, barcode => $barcode };
    }

    my %gid_map = %{ $c->model('Release')->get_by_gids(map { $_->{release} } @submit) };

    for my $submission (@submit) {
        my $gid = $submission->{release};
        $self->_error($c, "$gid does not match any existing releases")
            unless exists $gid_map{$gid};
    }

    if (@submit) {
        try {
            $c->model('Edit')->create(
                editor_id => $c->user->id,
                privileges => $c->user->privileges,
                edit_type => $EDIT_RELEASE_EDIT_BARCODES,
                submissions => [ map +{
                    release => {
                        id => $gid_map{ $_->{release} }->id,
                        name => $gid_map{ $_->{release} }->name
                    },
                    barcode => $_->{barcode}
                }, @submit ]
            );
        }
        catch ($e) {
            $self->_error($c, "This edit could not be successfully created: $e");
        }
    }

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;

