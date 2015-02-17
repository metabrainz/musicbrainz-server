package MusicBrainz::Server::Controller::Dialog;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub dialog : Path('/dialog') Edit {
    my ($self, $c) = @_;

    my $path = $c->req->query_params->{path};

    if (!$path) {
        $self->bad_request($c, 'path not specified');
    }
    elsif ($c->dispatcher->get_action_by_path($path)) {
        $c->stash( template => 'forms/dialog.tt' );
        $c->forward($path, [ within_dialog => 1 ]);
    }
    else {
        $self->bad_request($c, 'no such path');
    }
}

sub bad_request {
    my ($self, $c, $message) = @_;

    $c->res->status(400);
    $c->res->content_type('text/plain; charset=utf-8');
    $c->res->body($message);
}

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
