package MusicBrainz::Server::WebService::2::Representation::Mock;
use Moose;

use HTTP::Throwable::Factory qw( http_throw );
use Module::Pluggable::Object;
use Scalar::Util 'blessed';

with 'Sloth::Representation';

sub content_type { 'mock/ref' }

sub serialize {
    my ($self, $resource) = @_;
    return $resource;
}

1;
