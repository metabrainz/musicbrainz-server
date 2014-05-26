package MusicBrainz::Server::ControllerUtils::Delete;
use strict;
use warnings;
use MusicBrainz::Server::Translation qw( l );

use Sub::Exporter -setup => {
    exports => [qw( cancel_or_action )]
};

=head2 cancel_or_action

Given an edit, maybe a redirect URI, and an action to take, if the edit can be
cancelled by the current user, do that; if not, take the action.

This function is used to implement delete page behavior of "if the current
editor added this thing and the edit's still open, cancel it instead of
entering a delete edit."
=cut

sub cancel_or_action {
    my ($c, $edit, $redirect, $action_callback) = @_;
    if ($edit && $edit->can_cancel($c->user)) {
        $c->stash->{edit} = $edit;
        $c->stash->{cancel_redirect} = $redirect if $redirect;
        $c->flash->{message} = l('Since your edit adding this object was still open, that edit has been cancelled instead of opening a new edit.');
        $c->forward('/edit/cancel', [ $edit->id ]);
    } else {
        $action_callback->();
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
