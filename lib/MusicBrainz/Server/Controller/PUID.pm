package MusicBrainz::Server::Controller::PUID;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub load : Chained('/') PathPart('puid') CaptureArgs(1)
{
    my ($self, $c, $id) = @_;

    unless (MusicBrainz::Server::Validation::IsGUID($id)) {
        $c->detach('/error_404');
    }

    my $puid = $c->model('PUID')->get_by_puid($id);
    unless (defined $puid) {
        $c->detach('/error_404');
    }

    $c->stash( puid => $puid );
}

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $puid = $c->stash->{puid};
    my @recordings = $c->model('RecordingPUID')->find_by_puid($puid->id);
    $c->model('ArtistCredit')->load(map { $_->recording } @recordings);
    $c->stash(
        recordings => \@recordings,
        template   => 'puid/index.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
