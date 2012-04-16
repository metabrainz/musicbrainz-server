package MusicBrainz::Server::Controller::ISWC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'ISRC',
};

sub base : Chained('/') PathPart('isrc') CaptureArgs(0) { }

sub _load : Chained('/') PathPart('isrc') CaptureArgs(1)
{
    #my ($self, $c, $isrc) = @_;
    #return unless (is_valid_isrc($isrc));

    #my @isrcs = $c->model('ISRC')->find_by_isrc($isrc)
    #  or return;

    #$c->stash(
    #    isrcs => \@isrcs,
    #    isrc => $isrc,
    #);
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    #my $isrcs = $c->stash->{isrcs};
    #my @recordings = $c->model('Recording')->load(@$isrcs);
    #$c->model('ArtistCredit')->load(@recordings);
    #$c->stash(
    #    recordings => \@recordings,
    #    template   => 'isrc/index.tt',
    #);
}

sub delete : Chained('load') PatHPart {

}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
