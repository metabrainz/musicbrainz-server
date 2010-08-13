package MusicBrainz::Server::Controller::WS::1::Track;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller::WS::1' }

__PACKAGE__->config(
    model => 'Recording',
);

my $ws_defs = Data::OptList::mkopt([
    track => {
        method   => 'GET',
        inc      => [ qw( artist tags isrcs puids releases _relations ratings ) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::ArtistCredit';
with 'MusicBrainz::Server::Controller::WS::1::Role::Rating';
with 'MusicBrainz::Server::Controller::WS::1::Role::Tags';
with 'MusicBrainz::Server::Controller::WS::1::Role::Relationships';

sub root : Chained('/') PathPart('ws/1/track') CaptureArgs(0) { }

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;
    my $track = $c->stash->{entity};

    if ($c->stash->{inc}->isrcs) {
        $c->model('ISRC')->load_for_recordings($track);
    }

    if ($c->stash->{inc}->puids) {
        $c->model('RecordingPUID')->load_for_recordings($track);
    }

    if ($c->stash->{inc}->releases) {
        my ($releases) = $c->model('Release')->find_by_recording($track->id);

        $c->model('ReleaseStatus')->load(@$releases);
        $c->model('ReleaseGroup')->load(@$releases);
        $c->model('ReleaseGroupType')->load(map { $_->release_group } @$releases);
        $c->model('Script')->load(@$releases);
        $c->model('Language')->load(@$releases);

        $c->stash->{data}{releases} = $releases;
        $c->stash->{inc}->tracklist(1);

        unless ($c->stash->{inc}->artist) {
            $c->model('ArtistCredit')->load($track);
            $c->model('Artist')->load($track->artist_credit->names->[0])
                if (@{ $track->artist_credit->names } == 1);
        }
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('track', $track, $c->stash->{inc}, $c->stash->{data}));
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
