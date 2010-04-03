package MusicBrainz::Schema::Loader;
use Moose;
use MooseX::Types::Moose qw( Str );
use Method::Signatures::Simple;
use namespace::autoclean;

extends 'Fey::Loader::Pg';

has 'schema' => (
    isa => Str,
    is  => 'ro',
);

method _schema_name { $self->schema }

__PACKAGE__->meta->make_immutable;
