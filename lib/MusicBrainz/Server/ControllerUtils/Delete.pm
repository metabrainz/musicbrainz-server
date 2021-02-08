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
    if ($edit && $edit->editor_may_cancel($c->user)) {
        $c->stash->{edit} = $edit;
        $c->stash->{cancel_redirect} = $redirect if $redirect;
        $c->flash->{message} = l('Since your edit adding this object was still open, that edit has been cancelled instead of opening a new edit.');
        $c->forward('/edit/cancel', [ $edit->id ]);
    } else {
        $action_callback->();
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
