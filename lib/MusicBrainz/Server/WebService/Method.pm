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

has request_data_class => (
    isa => 'Str',
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
        try {
            %args = (
                %{ $request->query_parameters },
                %args,
            );
        }
        catch {
            http_throw('BadRequest' => $_);
        }
    }

    Class::MOP::load_class($self->request_data_class);
    $self->execute($self->request_data_class->new( %args ));
}

1;
