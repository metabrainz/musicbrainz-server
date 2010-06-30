package MusicBrainz::Server::Controller::Editors;
use Moose;
use MusicBrainz::Server::Types qw(
    $BOT_FLAG
    $AUTO_EDITOR_FLAG
    $WIKI_TRANSCLUSION_FLAG
    $RELATIONSHIP_EDITOR_FLAG
);

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub index : Path Args(0) RequireAuth
{
    my ($self, $c) = @_;

    $c->stash->{bots} = [
        $c->model ('Editor')->find_by_privileges ($BOT_FLAG)
    ];

    $c->stash->{auto_editors} = [
        $c->model ('Editor')->find_by_privileges ($AUTO_EDITOR_FLAG)
    ];

    $c->stash->{transclusion_editors} = [
        $c->model ('Editor')->find_by_privileges ($WIKI_TRANSCLUSION_FLAG)
    ];

    $c->stash->{relationship_editors} = [
        $c->model ('Editor')->find_by_privileges ($RELATIONSHIP_EDITOR_FLAG)
    ];
}

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
