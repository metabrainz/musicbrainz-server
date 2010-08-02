package MusicBrainz::Server::Controller::WS::1::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller::WS::1' }

__PACKAGE__->config(
    model => 'Release',
);

my $ws_defs = Data::OptList::mkopt([
    release => {
        method => 'GET',
        inc    => [ qw( artist ) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::ArtistCredit';

sub root : Chained('/') PathPart('ws/1/release') CaptureArgs(0) { }

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;

    my $release = $c->stash->{entity};

    # This is always displayed, regardless of inc parameters
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('ReleaseStatus')->load($release);
    $c->model('Language')->load($release);
    $c->model('Script')->load($release);
    $c->model('Relationship')->load_subset([ 'url' ], $release);

    my $opts = {};
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release', $release, $c->stash->{inc}, $opts));
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
