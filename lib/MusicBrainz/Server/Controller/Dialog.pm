package MusicBrainz::Server::Controller::Dialog;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub dialog : Path('/dialog') Edit {
    my ($self, $c) = @_;

    my $path = $c->req->query_params->{path};

    if (!$path) {
        $self->bad_request($c, 'path not specified');
    }

    my $path_uri = URI->new($path);
    $path = $path_uri->path;

    if ($c->dispatcher->get_action_by_path($path)) {
        %{ $c->req->query_params } = $path_uri->query_form;
        %{ $c->req->params } = $path_uri->query_form;
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
