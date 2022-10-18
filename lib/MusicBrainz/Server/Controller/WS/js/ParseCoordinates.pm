package MusicBrainz::Server::Controller::WS::js::ParseCoordinates;
use Moose;
use namespace::autoclean;
use JSON;
use utf8;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }
use MusicBrainz::Server::Data::Utils qw( trim );
use MusicBrainz::Server::Validation qw( validate_coordinates );

my $ws_defs = Data::OptList::mkopt([
    'parse-coordinates' => {
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
    $input = trim($input);
    my $coordinates = validate_coordinates($input);
    $c->detach('bad_req') unless $coordinates;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json({ coordinates => $coordinates }))
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
