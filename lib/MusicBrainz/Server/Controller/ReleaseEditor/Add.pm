package MusicBrainz::Server::Controller::ReleaseEditor::Add;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::ReleaseEditor' };

use aliased 'MusicBrainz::Server::Wizard::ReleaseEditor::Add' => 'Wizard';

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;
    my $wizard = Wizard->new(
        c => $c,
        on_submit => sub {
            my $wizard = shift;
            $self->do_redirect($c, $wizard->release);
        },
        on_cancel => sub {
            $self->cancelled($c)
        }
    );
    $wizard->run;
}

sub cancelled {
    my ($self, $c) = @_;

    my $rg_gid = $c->req->query_params->{'release-group'};
    my $label_gid = $c->req->query_params->{'label'};
    my $artist_gid = $c->req->query_params->{'artist'};

    if ($rg_gid)
    {
        $c->response->redirect($c->uri_for_action('/release_group/show', [ $rg_gid ]));
    }
    elsif ($label_gid)
    {
        $c->response->redirect($c->uri_for_action('/label/show', [ $label_gid ]));
    }
    elsif ($artist_gid)
    {
        $c->response->redirect($c->uri_for_action('/artist/show', [ $artist_gid ]));
    }
    else
    {
        $c->response->redirect($c->uri_for_action('/index'));
    }
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
