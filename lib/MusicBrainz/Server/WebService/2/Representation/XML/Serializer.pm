package MusicBrainz::Server::WebService::2::Representation::XML::Serializer;
use Moose::Role;

use MusicBrainz::XML::Generator;

has xml => (
    is => 'ro',
    default => sub {
        MusicBrainz::XML::Generator->new;
    }
);

has parent => (
    is => 'ro',
    handles => {
        serialize => 'serialize_resource'
    }
);

sub attributes { +{} }

requires 'serialize_inner', 'element';

sub serialize_resource {
    my $self = shift;

    $self->xml->${\$self->element}(
        $self->attributes(@_),
        $self->serialize_inner(@_)
    );
}

1;
