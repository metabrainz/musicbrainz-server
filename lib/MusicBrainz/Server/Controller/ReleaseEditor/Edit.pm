package MusicBrainz::Server::Controller::ReleaseEditor::Edit;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' }

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Edit' => 'Wizard';

sub edit : Chained('/release/load') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    my $wizard = Wizard->new(
        release => $release,
        c => $c,
        on_cancel => sub { $self->cancelled($c) },
        on_submit => sub { $self->do_redirect($c, $release) }
    );
    $wizard->run;
}

sub cancelled
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]))
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
