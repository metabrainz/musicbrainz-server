package MusicBrainz::Server::Entity::WorkAttributeTypeAllowedValue;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    name => 'value',
    type => 'WorkAttributeTypeAllowedValue',
    sort_criterion => 'l_value',
};

sub entity_type { 'work_attribute_type_allowed_value' }

has work_attribute_type_id => (
    is => 'rw',
    isa => 'Int',
);

sub l_value {
    my $self = shift;
    return lp($self->value, 'work_attribute_type_allowed_value')
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        workAttributeTypeID => $self->work_attribute_type_id,
        value => $self->value,
    };
};

__PACKAGE__->meta->make_immutable;
1;
