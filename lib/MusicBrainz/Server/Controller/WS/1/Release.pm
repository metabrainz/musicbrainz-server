package MusicBrainz::Server::Controller::WS::1::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );

__PACKAGE__->config(
    model => 'Release',
);

my $ws_defs = Data::OptList::mkopt([
    release => {
        method => 'GET',
        inc    => [ qw( artist  tags  release-groups tracks release-events labels isrcs
                        ratings puids _relations     counts discs          user-tags
                        user-ratings  track-level-rels ) ]
    },
    release => {
        method => 'POST',
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::ArtistCredit';
with 'MusicBrainz::Server::Controller::WS::1::Role::Relationships';
with 'MusicBrainz::Server::Controller::WS::1::Role::Serializer';

use aliased 'MusicBrainz::Server::Entity::CDTOC';

use MusicBrainz::Server::Exceptions;
use MusicBrainz::Server::Constants qw(
    $ACCESS_SCOPE_RATING
    $ACCESS_SCOPE_TAG
);
use MusicBrainz::Server::Validation qw( is_valid_discid );
use Try::Tiny;

sub root : Chained('/') PathPart('ws/1/release') CaptureArgs(0) { }

# We don't use the search server for disc ID lookups
around 'search' => sub
{
    my $orig = shift;
    my ($self, $c) = @_;

    if (my $disc_id = $c->req->query_params->{discid}) {
        $self->bad_req($c, 'Invalid argument "discid": not a valid disc ID')
            unless is_valid_discid($disc_id);
    }

    if (my $cdstubs = $c->req->query_params->{cdstubs}) {
        $self->bad_req($c, 'Invalid argument "cdstubs": must be "yes" or "no"')
            unless $cdstubs eq 'yes' || $cdstubs eq 'no';
    }

    if ($c->form_posted) {
        $c->forward('submit_cdstub');
    }
    elsif (my $disc_id = $c->req->query_params->{discid}) {
        my $inc = MusicBrainz::Server::WebService::WebServiceIncV1->new(
            artist => 1,
            counts => 1,
            release_events => 1,
            tracks => 1
        );

        $c->stash->{serializer}->add_namespace('ext', 'http://musicbrainz.org/ns/ext-1.0#');
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');

        my @releases;
        if (my @medium_cdtocs = $c->model('MediumCDTOC')->find_by_discid($disc_id)) {
            $c->model('Medium')->load(@medium_cdtocs);
            my @mediums = map { $_->medium } @medium_cdtocs;

            $c->model('MediumCDTOC')->load_for_mediums(@mediums);
            $c->model('Release')->load(@mediums);
            @releases = map { $_->release } @mediums;

            # Kind of weird, but this means all releases just have 1 medium - the medium
            # with the disc id
            $_->release->add_medium($_) for @mediums;

            $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseStatus')->load(@releases);
            $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
            $c->model('Language')->load(@releases);
            $c->model('Script')->load(@releases);
            $c->model('Relationship')->load_subset([ 'url' ], @releases);

            load_release_events($c, @releases);

            $c->model('Track')->load_for_mediums(@mediums);
            $c->model('Recording')->load(map { $_->all_tracks } @mediums);

            my @need_artists = (@releases, map { $_->all_tracks } @mediums);
            $c->model('ArtistCredit')->load(@need_artists);
            $c->model('Artist')->load(map { $_->artist_credit->all_names } @need_artists);

            my @recordings = map { $_->recording } map { $_->all_tracks } @mediums;
        }
        elsif (!exists $c->req->query_params->{cdstubs} || $c->req->query_params->{cdstubs} eq 'yes') {
            my $cd_stub_toc = $c->model('CDStubTOC')->get_by_discid($disc_id);
            if ($cd_stub_toc) {
                $c->model('CDStub')->load($cd_stub_toc);
                $c->model('CDStub')->increment_lookup_count($cd_stub_toc->cdstub->id);
                $c->model('CDStubTrack')->load_for_cdstub($cd_stub_toc->cdstub);

                push @releases, $cd_stub_toc->cdstub;
            }
        }

        $c->res->body($c->stash->{serializer}->serialize_list('release-list', \@releases, $inc, { score => 100 }));
  	}
    else {
        $self->$orig($c);
    }
};

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;

    my $release = $c->stash->{entity};

    my $scope = 0;
    $scope |= $ACCESS_SCOPE_RATING if $c->stash->{inc}->user_ratings;
    $scope |= $ACCESS_SCOPE_TAG if $c->stash->{inc}->user_tags;
    $self->authenticate($c, $scope) if $scope;

    # This is always displayed, regardless of inc parameters
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('ReleaseStatus')->load($release);
    $c->model('Language')->load($release);
    $c->model('Script')->load($release);

    # Don't load URL relationships twice
    my %rels = map { $_ => 1 } @{ $c->stash->{inc}->get_rel_types };
    $c->model('Relationship')->load_subset([ 'url' ], $release)
        unless $rels{url};

    if ($c->stash->{inc}->tags) {
        my ($tags, $hits) = $c->model('ReleaseGroup')->tags->find_tags($release->release_group->id);
        $c->stash->{data}{tags} = $tags;
    }

    if ($c->stash->{inc}->user_tags) {
        $c->stash->{data}{user_tags} = [
            $c->model('ReleaseGroup')->tags->find_user_tags($c->user->id, $release->release_group->id)
        ];
    }

    if ($c->stash->{inc}->tracks) {
        $c->model('Medium')->load_for_releases($release);

        my @mediums = $release->all_mediums;
        $c->model('Track')->load_for_mediums(@mediums);
        $c->model('Recording')->load(map { $_->all_tracks } @mediums);
        $c->model('ArtistCredit')->load(map { $_->all_tracks } @mediums)
            if $c->stash->{inc}->artist;

        my @recordings = map { $_->recording } map { $_->all_tracks } @mediums;

        $c->model('ISRC')->load_for_recordings(@recordings)
            if $c->stash->{inc}->isrcs;

        $c->model('RecordingPUID')->load_for_recordings(@recordings)
            if ($c->stash->{inc}->puids);

        if ($c->stash->{inc}->track_level_rels) {
            $self->load_relationships($c, @recordings);
        }
    }

    if ($c->stash->{inc}->release_events) {
        # If we ask for tracks we already have medium stuff loaded
        unless ($release->all_mediums) {
            $c->model('Medium')->load_for_releases($release)
        }

        my @mediums = $release->all_mediums;
        $c->model('MediumFormat')->load(@mediums);
        $c->model('ReleaseLabel')->load($release);

        load_release_events($c, $release);

        $c->model('Label')->load($release->all_labels)
            if $c->stash->{inc}->labels;
    }

    if ($c->stash->{inc}->discs) {
        $c->model('Medium')->load_for_releases($release)
            unless $release->all_mediums;

        my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
        $c->model('CDTOC')->load(@medium_cdtocs);
    }

    if ($c->stash->{inc}->ratings) {
        # Releases don't have ratings now, so we need to use release groups
        $c->model('ReleaseGroup')->load_meta($release->release_group);
    }

    if ($c->stash->{inc}->user_ratings) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, $release->release_group);
    }

    if ($c->stash->{inc}->counts) {
        $c->model('Medium')->load_for_releases($release)
            unless $release->all_mediums;

        $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums)
            unless $c->stash->{inc}->discs;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release', $release, $c->stash->{inc}, $c->stash->{data}));
}

sub submit_cdstub : Private
{
    my ($self, $c) = @_;
    $self->deny_readonly($c);

    my $discid = $c->req->params->{discid};
    my $toc = $c->req->params->{toc};
    my $client = $c->req->query_params->{client} or
        $self->bad_req($c, 'Missing mandatory client query parameter');

    $self->bad_req($c, 'Invalid argument: "client"') unless !ref($client);

    my @tracks;
    for (0..98) {
        my $track_artist = $c->req->params->{"artist$_"};
        my $track_title = $c->req->params->{"track$_"}
            or last;

        my $data = { title => $track_title };

        if ($track_artist) {
            $data->{artist} = $track_artist;
        }

        push @tracks, $data;
    }

    try {
        $c->model('CDStub')->insert({
            title => $c->req->params->{title},
            discid => $discid,
            toc => $toc,
            artist => $c->req->params->{artist},
            barcode => $c->req->params->{barcode} || undef,
            comment => $c->req->params->{comment} || undef,
            tracks => \@tracks
        });
    }
    catch {
        if (ref($_) && $_->isa('MusicBrainz::Server::Exceptions::InvalidInput')) {
            $self->bad_req($c, $_->message);
        }
        else {
            die $_;
        }
    }

    $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
    $c->res->body($self->serializer->xml( '' ));
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
