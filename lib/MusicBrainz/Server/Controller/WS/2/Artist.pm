package MusicBrainz::Server::Controller::WS::2::Artist;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Readonly;
use MusicBrainz::Server::Validation qw( is_guid );

my $ws_defs = Data::OptList::mkopt([
     artist => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     artist => {
                         method   => 'GET',
                         linked   => [ qw(area recording release release-group work collection) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     artist => {
                         action   => '/ws/2/artist/lookup',
                         method   => 'GET',
                         inc      => [ qw(recordings releases release-groups works
                                          aliases various-artists annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Artist',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('artist') CaptureArgs(0) { }

sub artist_toplevel
{
    my ($self, $c, $stash, $artists) = @_;

    my $inc = $c->stash->{inc};
    my @artists = @{$artists};

    $self->linked_artists($c, $stash, $artists);

    $c->model('ArtistType')->load(@artists);
    $c->model('Gender')->load(@artists);
    $c->model('Area')->load(@artists);
    $c->model('Artist')->ipi->load_for(@artists);
    $c->model('Artist')->isni->load_for(@artists);

    $c->model('Artist')->annotation->load_latest(@artists)
        if $inc->annotation;

    $self->load_relationships($c, $stash, @artists);

    if ($inc->recordings) {
        my @recordings;
        for my $artist (@artists) {
            my $opts = $stash->store($artist);
            my @results = $c->model('Recording')->find_by_artist($artist->id, $MAX_ITEMS, 0);
            $opts->{recordings} = $self->make_list(@results);
            push @recordings, @{ $opts->{recordings}{items} };
        }
        $self->linked_recordings($c, $stash, \@recordings) if @recordings;
    }

    if ($inc->releases) {
        my @releases;
        for my $artist (@artists) {
            my $opts = $stash->store($artist);
            my @results;
            if ($inc->various_artists) {
                # Note: `find_by_track_artist` excludes releases where
                # `$artist->id` appears in the release artist credit.
                @results = $c->model('Release')->find_by_track_artist(
                    $artist->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type}});
            } else {
                @results = $c->model('Release')->find_by_artist(
                    $artist->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type}});
            }
            $opts->{releases} = $self->make_list(@results);
            push @releases, @{ $opts->{releases}{items} };
        }
        $self->linked_releases($c, $stash, \@releases) if @releases;
    }

    if ($inc->release_groups) {
        my @release_groups;
        my $show_all = 1;
        for my $artist (@artists) {
            my $opts = $stash->store($artist);
            my @results = $c->model('ReleaseGroup')->find_by_artist(
                $artist->id, $show_all, $MAX_ITEMS, 0, filter => { type => $c->stash->{type} });
            $opts->{release_groups} = $self->make_list(@results);
            push @release_groups, @{ $opts->{release_groups}{items} };
        }
        $self->linked_release_groups($c, $stash, \@release_groups) if @release_groups;
    }

    if ($inc->works) {
        my @works;
        for my $artist (@artists) {
            my $opts = $stash->store($artist);
            my @results = $c->model('Work')->find_by_artist($artist->id, $MAX_ITEMS, 0);
            $opts->{works} = $self->make_list(@results);
            push @works, @{ $opts->{works}{items} };
        }
        $self->linked_works($c, $stash, \@works) if @works;
    }
}

sub artist_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $artists;
    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless ($area);

        my @tmp = $c->model('Artist')->find_by_area($area->id, $limit, $offset);
        $artists = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'collection') {
        $artists = $self->browse_by_collection($c, 'artist', $id, $limit, $offset);
    } elsif ($resource eq 'recording') {
        my $recording = $c->model('Recording')->get_by_gid($id);
        $c->detach('not_found') unless ($recording);

        my @tmp = $c->model('Artist')->find_by_recording($recording->id, $limit, $offset);
        $artists = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'release')
    {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('Artist')->find_by_release($release->id, $limit, $offset);
        $artists = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'release-group')
    {
        my $rg = $c->model('ReleaseGroup')->get_by_gid($id);
        $c->detach('not_found') unless ($rg);

        my @tmp = $c->model('Artist')->find_by_release_group($rg->id, $limit, $offset);
        $artists = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'work')
    {
        my $work = $c->model('Work')->get_by_gid($id);
        $c->detach('not_found') unless ($work);

        my @tmp = $c->model('Artist')->find_by_work($work->id, $limit, $offset);
        $artists = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->artist_toplevel($c, $stash, $artists->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('artist-list', $artists, $c->stash->{inc}, $stash));
}

sub artist_search : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('artist_browse') if ($c->stash->{linked});
    $self->_search($c, 'artist');
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
