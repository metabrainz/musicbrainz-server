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

sub attributes { }
sub serialize_inner { }

requires 'element';

sub serialize_resource {
    my $self = shift;
    my ($entity, %extra) = @_;

    $self->xml->${\$self->element}(
        { $self->attributes(@_) },
        $self->serialize_inner(@_),
        map { $self->serialize($_) } @{ $extra{inline} || [] }
    );
}

1;
