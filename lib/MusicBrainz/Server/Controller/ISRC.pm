package MusicBrainz::Server::Controller::ISRC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_REMOVE_ISRC );
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Validation qw( is_valid_isrc );
use List::UtilsBy qw( sort_by );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'ISRC',
};

sub base : Chained('/') PathPart('isrc') CaptureArgs(0) { }

sub _load : Chained('/') PathPart('isrc') CaptureArgs(1)
{
    my ($self, $c, $isrc) = @_;
    return unless (is_valid_isrc($isrc));

    my @isrcs = $c->model('ISRC')->find_by_isrc($isrc)
      or return;

    $c->stash(
        isrcs => \@isrcs,
        isrc => $isrc,
    );
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $isrcs = $c->stash->{isrcs};
    my @recordings = sort_by { $_->name } $c->model('Recording')->load(@$isrcs);
    $c->model('ArtistCredit')->load(@recordings);
    $c->stash(
        recordings => \@recordings,
        template   => 'isrc/index.tt',
    );
}

sub delete : Local RequireAuth
{
    my ($self, $c) = @_;

    my $isrc_id = $c->req->query_params->{isrc_id};
    my $isrc = $c->model('ISRC')->get_by_id($isrc_id);

    $c->model('Recording')->load($isrc);
    $c->model('ArtistCredit')->load($isrc->recording);

    $c->stash( isrc => $isrc );

    if (!$isrc) {
        $c->detach('/error_500');
        $c->stash( message => l('This ISRC does not exist' ));
    }

    $self->edit_action($c,
        form        => 'Confirm',
        edit_args   => { isrc => $isrc },
        type        => $EDIT_RECORDING_REMOVE_ISRC,
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/isrc/show', [ $isrc->isrc ]));
        }
    );
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
