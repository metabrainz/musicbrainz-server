package MusicBrainz::Server::WebService::2::Representation::XML::Serializer;
use Moose::Role;

use MusicBrainz::XML::Generator;

has xml => (
    is => 'ro',
    default => sub {
        MusicBrainz::XML::Generator->new( escape => 'always' );
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
sub predicate { 1 }

requires 'element';

sub serialize_resource {
    my $self = shift;
    my ($entity, %extra) = @_;

    if ($self->predicate($entity, %extra)) {
        $self->xml->${\$self->element}(
            { $self->attributes(@_) },
            $self->serialize_inner(@_),
            map { $self->serialize($_) } @{ $extra{inline} || [] }
        );
    }
}

1;
