package MusicBrainz::Server::Controller::WS::js::LastUpdatedRecordings;
use Moose;
use JSON;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

my $ws_defs = Data::OptList::mkopt([
    "last-updated-recordings" => {
        method   => 'GET',
        required => [ qw(artists) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub recent : Chained('root') PathPart('last-updated-recordings')
{
    my ($self, $c) = @_;

    my $artist_ids = $c->req->query_params->{artists};
    $artist_ids = [ $artist_ids ] if ref($artist_ids) ne 'ARRAY';
    $c->detach('bad_req') unless scalar @$artist_ids;

    my @recent = $c->model('Recording')->find_recent_by_artists($artist_ids);
    $c->model('ISRC')->load_for_recordings(@recent);
    $c->model('ArtistCredit')->load(@recent);

    my @output = map { $c->stash->{serializer}->_recording($_) } @recent;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json({ recordings => \@output }));
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
