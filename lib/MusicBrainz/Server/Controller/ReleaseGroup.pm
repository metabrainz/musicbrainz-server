package MusicBrainz::Server::Controller::ReleaseGroup;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

__PACKAGE__->config(
    model       => 'ReleaseGroup',
    entity_name => 'rg',
    namespace   => 'release_group',
);

sub base : Chained('/') PathPart('release-group') CaptureArgs(0) { }

sub release_group : Chained('load') PathPart('') CaptureArgs(0)
{
    my ($self, $c) = @_;
    
    $c->model('ReleaseGroupType')->load($c->stash->{rg});
    $c->model('ArtistCredit')->load($c->stash->{rg});
}

sub show : Chained('release_group') PathPart('')
{
    my ($self, $c) = @_;
    $c->stash(template => 'release_group/index.tt');
}

1;

=head1 NAME

MusicBrainz::Server::Controller::ReleaseGroup - controller for release groups

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
