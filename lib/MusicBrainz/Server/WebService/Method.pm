package MusicBrainz::Server::WebService::Method;
use Moose::Role;

use HTTP::Throwable::Factory qw( http_throw );
use Try::Tiny;

requires 'execute';

has request_parsers => (
    is => 'ro',
    traits => [ 'Hash' ],
    isa => 'HashRef',
    predicate => 'handles_content_types',
    handles => {
        request_parser => 'get',
        supported_content_types => 'keys'
    }
);

has request_data => (
    is => 'ro',
    required => 1
);

has c => (
    is => 'ro',
    required => 1
);

sub process_request {
    my ($self, $request) = @_;

    my %args = %{ $request->path_components };
    if ($self->handles_content_types) {
        my $parser = $self->request_parser($request->header('Content-Type'))
            or http_throw('UnsupportedMediaType');

        %args = $parser->parse($request);
    }
    else {
        %args = (
            %{ $request->query_parameters },
            %args,
        );
    }

    my $result = $self->request_data->process({ %args });

    http_throw('BadRequest' => {
        message => $result->result('gid')->errors
    })
        unless $result->valid;

    $self->execute($result->clean);
}

1;
