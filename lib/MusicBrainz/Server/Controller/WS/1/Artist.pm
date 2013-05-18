package MusicBrainz::Server::Controller::WS::1::Artist;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );

__PACKAGE__->config(
    model => 'Artist',
);

my $ws_defs = Data::OptList::mkopt([
    artist => {
        method   => 'GET',
        inc      => [
            qw( aliases        release-groups _rel_status _rg_type   counts
                release-events discs          labels      _relations tags ratings
                user-tags      user-ratings ) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::Alias';
with 'MusicBrainz::Server::Controller::WS::1::Role::Rating';
with 'MusicBrainz::Server::Controller::WS::1::Role::Relationships';
with 'MusicBrainz::Server::Controller::WS::1::Role::Tags';

sub root : Chained('/') PathPart('ws/1/artist') CaptureArgs(0) { }

__PACKAGE__->config( paging_limit => 250 );

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;
    my $artist = $c->stash->{entity};

    $c->model('ArtistType')->load($artist);
    $c->model('Area')->load($artist);
    $c->model('Area')->load_codes($artist->area, $artist->begin_area, $artist->end_area);

    my @rg;
    if ($c->stash->{inc}->rg_type || $c->stash->{inc}->rel_status) {
        if ($c->stash->{inc}->various_artists)
        {
            @rg = $c->model('ReleaseGroup')->filter_by_track_artist($artist->id, filter => { type => $c->stash->{inc}->rg_type });
        }
        else
        {
            @rg = $c->model('ReleaseGroup')->filter_by_artist($artist->id, filter => { type => $c->stash->{inc}->rg_type });
        }
    }

    if (@rg) {
        $c->model('ArtistCredit')->load(@rg);
        $c->model('ReleaseGroupType')->load(@rg);
        $c->stash->{data}->{release_groups} = \@rg;
        my ($results, $hits) = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_release_group([ map { $_->id } @rg ], shift, shift)
        });

        $c->model('ReleaseStatus')->load(@$results);

        my @releases;
        if ($c->stash->{inc}->rel_status && @rg) {
            @releases = grep { defined($_->status_id) && $_->status_id == $c->stash->{inc}->rel_status } @$results;
        }
        else {
            @releases = @$results;
        }

        # make sure the release groups are hooked up to the releases, so
        # the serializer can get the release type from the release group.
        my %rel_to_rg_map = map { ( $_->id => $_ ) } @rg;
        map { $_->release_group($rel_to_rg_map{$_->release_group_id}) } @releases;

        if ($c->stash->{inc}->discs) {
            $c->model('Medium')->load_for_releases(@releases);
            my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums(map { $_->all_mediums } @releases);
            $c->model('CDTOC')->load(@medium_cdtocs);
        }

        $c->model('ReleaseStatus')->load(@releases);
        $c->model('Language')->load(@releases);
        $c->model('Script')->load(@releases);

        $c->model('Relationship')->load_subset([ 'url' ], @releases);
        $c->stash->{inc}->asin(1);

        $c->stash->{inc}->releases(1);
        $c->stash->{data}->{releases} = \@releases;

        if ($c->stash->{inc}->release_events) {
            $c->model('Medium')->load_for_releases(@releases)
                unless $c->stash->{inc}->discs;

            $c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
            $c->model('ReleaseLabel')->load(@releases);

            load_release_events($c, @releases);

            $c->model('Label')->load(map { $_->labels->[0] } @releases)
                if $c->stash->{inc}->labels;
        }

        if ($c->stash->{inc}->counts) {
            $c->model('Medium')->load_for_releases(@releases)
                unless $c->stash->{inc}->discs ||
                    $c->stash->{inc}->release_events;

            $c->model('MediumCDTOC')->load_for_mediums(map { $_->all_mediums } @releases)
                unless $c->stash->{inc}->discs;
        }
    }

    if ($c->stash->{inc}->labels)
    {
         my @labels = $c->model('Label')->find_by_artist($artist->id);
         $c->stash->{data}->{labels} = \@labels;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('artist', $artist, $c->stash->{inc}, $c->stash->{data}));
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
