package MusicBrainz::Server::XMLSerialization;

use strict;
use warnings;

use Class::MOP;
use XML::Twig;
use XML::Generator;

use Sub::Exporter -setup => {
    exports => [qw( serialize deserialize )]
};

my %inflators = (
    Hash => \&inflate_hash,
    Array => \&inflate_array,
    Blessed => \&inflate_blessed,
    '' => \&inflate_scalar,
);

my %serializers = (
    HASH => \&deflate_hash,
    ARRAY => \&deflate_array,
    '' => \&deflate_scalar,
);

sub deserialize {
    my $xml = shift;
    my $twig = XML::Twig->new;
    $twig->parse($xml);
    inflate($twig->root);
}

sub inflate {
    my $twig = shift;
    my $type = $twig->att('isa') || '';
    my $process = $inflators{$type};
    return $process->($twig);
}

sub inflate_hash {
    my $twig = shift;
    my $hash = {};
    for my $element ($twig->children) {
        my $key = $element->name;
        $hash->{$key} = inflate($element);
    }

    return $hash;
}

sub inflate_array {
    my $twig = shift;
    return [ map { inflate($_) } $twig->children('element') ]
}

sub inflate_scalar {
    my $twig = shift;
    my $undef = $twig->att('undef');
    return $undef && $undef eq 'undef' ? undef : $twig->text;
}

sub inflate_blessed {
    my $twig = shift;
    my $class = $twig->att('class');
    my $constructor = inflate_hash($twig);
    Class::MOP::load_class($class);
    return $class->new($constructor);
}

sub serialize {
    my $what = shift;
    my $generator = XML::Generator->new(pretty => 1);
    $generator->data({ deflate_container($what) }, deflate($generator, $what));
}

sub deflate {
    my ($gen, $what, %attributes) = @_;
    my $type = ref($what) || '';
    my $serializer = $serializers{$type} || \&deflate_blessed;
    $serializer->($gen, $what, %attributes);
}

sub deflate_container {
    my $for = shift;
    my %isa = (
        HASH => 'Hash',
        ARRAY => 'Array',
        '' => undef,
    );
    my $ref = ref($for) || '';
    if (exists $isa{$ref}) {
        return ( isa => $isa{$ref}, undef => defined($for) ? undef : "undef" );
    }
    else {
        return ( isa => 'Blessed', class => $ref );
    }
}

sub deflate_hash {
    my ($gen, $hash, %attributes) = @_;
    map {
        my $value = $hash->{$_};
        $gen->$_({ deflate_container($value) }, deflate($gen, $value))
    } keys %$hash
}

sub deflate_array {
    my ($gen, $array, %attributes) = @_;
    map { $gen->element({ deflate_container($_) }, deflate($gen, $_)) } @$array
}

sub deflate_scalar {
    my ($gen, $scalar) = @_;
    return $scalar;
}

sub deflate_blessed {
    my ($gen, $blessed) = @_;
    deflate_hash($gen, {
        map {
            $_->name => $_->get_value($blessed)
        } grep {
            $_->has_value($blessed)  
        } $blessed->meta->get_all_attributes
    });
}

1;
