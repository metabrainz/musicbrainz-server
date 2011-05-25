package MusicBrainz::Server::Controller::WS::1::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

__PACKAGE__->config(
    namespace => 'ws/1/release-group',
    model     => 'ReleaseGroup',
);

my $ws_defs = Data::OptList::mkopt([
    'release-group' => {
        method   => 'GET',
        inc      => [ qw(artist releases _relations) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

sub root : Chained('/') PathPart('ws/1/release-group') CaptureArgs(0) { }

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;
    my $rg = $c->stash->{entity};

    $c->model('ReleaseGroupType')->load($rg);

    my $opts = {};
    if ($c->stash->{inc}->artist)
    {
        $c->model('ArtistCredit')->load($rg);

        # make sure sort_name is loaded if there is only one artist.
        $c->model('Artist')->load($rg->artist_credit->names->[0])
            if (@{$rg->artist_credit->names} == 1);
    }

    if ($c->stash->{inc}->releases)
    {
        $c->stash->{inc}->tracklist(1);

        $opts->{releases} = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_release_group($rg->id, shift, shift);
        });

        # make sure the release group is hooked up to the release, so
        # the serializer can get the release type from the release group.
        map { $_->release_group($rg) } @{$opts->{releases}};

        $c->model('ReleaseStatus')->load(@{$opts->{releases}});
        $c->model('Language')->load(@{$opts->{releases}});
        $c->model('Script')->load(@{$opts->{releases}});
        $c->model('Medium')->load_for_releases(@{$opts->{releases}});
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group', $rg, $c->stash->{inc}, $opts));
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
