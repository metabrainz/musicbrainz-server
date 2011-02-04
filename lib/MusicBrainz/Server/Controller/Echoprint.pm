package MusicBrainz::Server::Controller::Echoprint;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub load : Chained('/') PathPart('echoprint') CaptureArgs(1)
{
    my ($self, $c, $id) = @_;

    unless (MusicBrainz::Server::Validation::IsEchoprint($id)) {
        $c->detach('/error_404');
    }

    my $echoprint = $c->model('Echoprint')->get_by_echoprint($id);
    unless (defined $echoprint) {
        $c->detach('/error_404');
    }


    $c->stash( echoprint => $echoprint );
}

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $echoprint = $c->stash->{echoprint};
    my @recordings = $c->model('RecordingEchoprint')->find_by_echoprint($echoprint->id);
    $c->model('ArtistCredit')->load(map { $_->recording } @recordings);
    $c->stash(
        recordings => \@recordings,
        template   => 'echoprint/index.tt',
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
