package MusicBrainz::Server::Data::Role::ValueSet;

use MooseX::Role::Parameterized;
use namespace::autoclean;
use Moose::Util qw( ensure_all_roles );
use MusicBrainz::Server::Data::ValueSet;

my @str_params = qw(
    entity_type
    plural_value_type
    value_attribute
    value_class
    value_type
);

parameter \@str_params => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

role {
    my $params = shift;

    requires qw( c );

    my $entity_type         = $params->entity_type;
    my $plural_value_type   = $params->plural_value_type;
    my $value_attribute     = $params->value_attribute;
    my $value_class         = $params->value_class;
    my $value_type          = $params->value_type;

    has $value_type => (
        is => 'ro',
        builder => qq(_build_$value_type),
        lazy => 1,
    );

    method qq(_build_$value_type) => sub {
        my $self = shift;

        my $cls = MusicBrainz::Server::Data::ValueSet->new(
            c                   => $self->c,
            entity_type         => $entity_type,
            plural_value_type   => $plural_value_type,
            value_attribute     => $value_attribute,
            value_class         => $value_class,
            value_type          => $value_type,
        );
        ensure_all_roles(
            $cls,
            'MusicBrainz::Server::Data::Role::PendingEdits' => {
                table => qq(${entity_type}_$value_type),
            },
        );
    };

    after update => sub {
        my ($self, $entity_id, $update) = @_;

        my $values = $update->{$plural_value_type};
        if (defined $values) {
            $self->$value_type->set($entity_id, @$values);
        }
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
