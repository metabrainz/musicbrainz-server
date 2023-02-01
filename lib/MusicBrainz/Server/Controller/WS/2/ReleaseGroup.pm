package MusicBrainz::Server::Controller::WS::2::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use List::AllUtils qw( uniq );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     'release-group' => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     'release-group' => {
                         method   => 'GET',
                         linked   => [ qw(artist release collection) ],
                         inc      => [ qw(aliases artist-credits annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     'release-group' => {
                         action   => '/ws/2/releasegroup/lookup',
                         method   => 'GET',
                         inc      => [ qw(artists releases artist-credits aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'ReleaseGroup',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub release_group_toplevel {
    my ($self, $c, $stash, $rgs) = @_;

    my $inc = $c->stash->{inc};
    my @rgs = @{$rgs};

    $c->model('ReleaseGroup')->load_meta(@rgs);

    $self->linked_release_groups($c, $stash, $rgs);

    $c->model('ReleaseGroup')->annotation->load_latest(@rgs)
        if $inc->annotation;

    $self->load_relationships($c, $stash, @rgs);

    if ($inc->artists) {
        $c->model('ArtistCredit')->load(@rgs);

        my @acns = map { $_->artist_credit->all_names } @rgs;
        $c->model('Artist')->load(@acns);
        my @artists = uniq map { $_->artist } @acns;
        $c->model('ArtistType')->load(@artists);

        $self->linked_artists($c, $stash, \@artists);
    }

    if ($inc->releases) {
        my @releases;
        for my $rg (@rgs) {
            my $opts = $stash->store($rg);
            my @results = $c->model('Release')->find_by_release_group(
                $rg->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status} });
            $opts->{releases} = $self->make_list(@results);
            push @releases, @{$results[0]};
        }
        if (@releases) {
            $c->model('Release')->load_release_events(@releases);
            $self->linked_releases($c, $stash, \@releases);
        }
    }
}

sub base : Chained('root') PathPart('release-group') CaptureArgs(0) { }

sub release_group_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $rgs;
    if ($resource eq 'artist')
    {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my $show_all = 1;
        my @tmp = $c->model('ReleaseGroup')->find_by_artist(
            $artist->id, $show_all, $limit, $offset, filter => { type => $c->stash->{type} });
        $rgs = $self->make_list(@tmp, $offset);
    }
    elsif ($resource eq 'collection') {
        $rgs = $self->browse_by_collection($c, 'release_group', $id, $limit, $offset);
    }
    elsif ($resource eq 'release')
    {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('ReleaseGroup')->find_by_release($release->id, $limit, $offset);
        $rgs = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->release_group_toplevel($c, $stash, $rgs->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group-list', $rgs, $c->stash->{inc}, $stash));
}

sub release_group_search : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('release_group_browse') if ($c->stash->{linked});

    $self->_search($c, 'release-group');
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
