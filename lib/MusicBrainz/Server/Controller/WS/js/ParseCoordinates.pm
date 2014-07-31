package MusicBrainz::Server::Controller::WS::js::ParseCoordinates;
use Moose;
use JSON;
use utf8;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }
use MusicBrainz::Server::Validation qw( validate_coordinates );

my $ws_defs = Data::OptList::mkopt([
    "parse-coordinates" => {
        method   => 'GET',
        required => [ qw(coordinates) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
    version => 'js',
    default_serialization_type => 'json',
};

sub parse_coordinates : Chained('root') PathPart('parse-coordinates') {
    my ($self, $c) = @_;

    my $input = $c->req->query_params->{coordinates};
    my $coordinates = validate_coordinates($input);
    $c->detach('bad_req') unless $coordinates;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json({ coordinates => $coordinates }))
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
