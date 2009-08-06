package MusicBrainz::Server::Controller::Tag;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub load : Chained('/') PathPart('tag') CaptureArgs(1)
{
    my ($self, $c, $name) = @_;

    my $tag = $c->model('Tag')->get_by_name($name);
    $c->stash->{tag} = $tag;
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'tag/index.tt';
}

sub artist : Chained('load')
{
    my ($self, $c) = @_;
}

sub label : Chained('load')
{
    my ($self, $c) = @_;
}

sub recording : Chained('load')
{
    my ($self, $c) = @_;
}

sub release_group : Chained('load') PathPart('release-group')
{
    my ($self, $c) = @_;
}

sub work : Chained('load')
{
    my ($self, $c) = @_;
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
