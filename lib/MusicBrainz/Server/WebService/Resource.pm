package MusicBrainz::Server::WebService::Resource;
use Moose::Role;
use namespace::autoclean;

use Plack::Response;
use HTTP::Throwable::Factory 'http_throw';

has representations => (
    is => 'ro',
    required => 1,
    isa => 'HashRef',
    traits => [ 'Hash' ],
    handles => {
        serializer => 'get'
    }
);

has methods => (
    isa => 'HashRef',
    is => 'ro',
    required => 1,
    traits => [ 'Hash' ],
    handles => {
        method_handler => 'get',
    }
);

sub handle_request {
    my ($self, $request) = @_;

    my $method = $self->method_handler($request->method)
        or return http_throw('MethodNotAllowed');

    my $resource = $method->process_request($request);

    my @accept = $request->header('Accept');
    warn $_ for @accept;
    for my $accept ($request->header('Accept')) {
        warn $accept;
        my $serializer = $self->serializer($accept)
            or next;

        return Plack::Response->new(
            200 => [] => $serializer->serialize($resource)
        )
            or http_throw('NotAcceptable');
    }

    http_throw('NotAcceptable');
}

1;
