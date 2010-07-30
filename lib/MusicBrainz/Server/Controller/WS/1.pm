package MusicBrainz::Server::Controller::WS::1;

use Moose;
use Readonly;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::WebService::XMLSerializerV1;

sub serializers {
    return {
        xml => 'MusicBrainz::Server::WebService::XMLSerializerV1',
    };
}

sub begin : Private {
    my ($self, $c) = @_;
    $self->validate($c, $self->serializers) or $c->detach('bad_req');
}

# Don't render with TT
sub end : Private { }

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type("text/plain; charset=utf-8");
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}.
                  "\nFor usage, please see: http://musicbrainz.org/development/mmd\015\012"));
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->res->status(404);
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $self->serializers->{$self->get_default_serialization_type}->new();
    $c->stash->{error} = "Invalid resource: $resource. ";
    $c->detach('bad_req');
}

no Moose;
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
