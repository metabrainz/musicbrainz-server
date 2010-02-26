package MusicBrainz::Server::Controller::Doc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;

sub show : Path('')
{
    my ($self, $c, @args) = @_;

    my $id = join '/', @args;
    $id =~ s/ /_/g;

    $c->detach('/error_404')
        if $id =~ /^Special:/;

    my $version = $c->model('WikiDocIndex')->get_page_version($id);
    my $page = $c->model('WikiDoc')->get_page($id, $version);

    if ($page->{canonical}) {
        $c->response->redirect($c->uri_for ('/doc', $page->{canonical}));
    }

    my $bare = $c->req->param('bare') || 0;
    $c->stash(
        id => $id,
        page => $page,
        wiki_server => &DBDefs::WIKITRANS_SERVER,
    );

    if ($bare) {
        $c->stash->{template} = $page ? 'doc/bare.tt' : 'doc/bare_error.tt';
    }
    else {
        $c->stash->{template} = $page ? 'doc/page.tt' : 'doc/error.tt';
    }
}

no Moose;
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
