package MusicBrainz::Server::WebService::Request;
use Moose;
use namespace::autoclean;

has plack_request => (
    is => 'ro',
    required => 1,
    handles => [qw( path method query_parameters header )],
);

has path_components => (
    required => 1,
    is => 'ro'
);

1;
