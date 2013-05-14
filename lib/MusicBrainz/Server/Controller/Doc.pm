package MusicBrainz::Server::Controller::Doc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use MusicBrainz::Server::Validation qw( is_guid );

sub show : Path('')
{
    my ($self, $c, @args) = @_;

    my $id = join '/', @args;
    $id =~ s/ /_/g;

    my $version = $c->model('WikiDocIndex')->get_page_version($id);
    my $page = $c->model('WikiDoc')->get_page($id, $version);

    if ($page && $page->canonical)
    {
        my ($path, $fragment) = split /\#/, $page->{canonical}, 2;
        $fragment = $fragment ? '#'.$fragment : '';

        $c->response->redirect($c->uri_for('/doc', $path).$fragment, 301);
        return;
    }

    my $bare = $c->req->param('bare') || 0;
    $c->stash(
        id => $id,
        page => $page,
        google_custom_search => DBDefs->GOOGLE_CUSTOM_SEARCH,
    );

    if ($id =~ /^[^:]+:/i && $id !~ /^Category:/i) {
        $c->response->redirect(sprintf('http://%s/%s', DBDefs->WIKITRANS_SERVER, $id));
        $c->detach;
    }

    if ($page) {
        $c->stash->{template} = $bare ? 'doc/bare.tt' : 'doc/page.tt';
    }
    else {
        $c->response->status(404);
        $c->stash->{template} = $bare ? 'doc/bare_error.tt' : 'doc/error.tt';
    }
}

sub relationship_type : Path('/doc/relationship-types/') Args(1) {
    my ($self, $c, $link_type_gid) = @_;

    if (!is_guid($link_type_gid)) {
        $self->invalid_mbid($c, $link_type_gid);
    }

    my $relationship_type = $c->model('LinkType')->get_by_gid($link_type_gid)
        or $self->not_found($c);

    $c->model('LinkType')->load_documentation($relationship_type);
    $c->stash( relationship_type => $relationship_type );
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
