package MusicBrainz::Server::Entity::WorkAttributeType;
use Moose;
use MooseX::Types::Moose qw( ArrayRef );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'WorkAttributeType',
};

has name => (
    isa => 'Str',
    is => 'rw',
);

has comment => (
    isa => 'Str',
    is => 'rw',
);

has free_text => (
    is => 'rw',
    isa => 'Bool',
);

has description => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

has allowed_values => (
    isa => 'ArrayRef[WorkAttributeTypeAllowedValue]',
    is => 'rw',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_allowed_values => 'elements',
        add_allowed_value => 'push',
        clear_allowed_values => 'clear'
    }
);

sub l_name {
    my $self = shift;
    return lp($self->name, 'work_attribute_type')
}

sub l_comment {
    my $self = shift;
    return lp($self->name, 'work_attribute_type')
}

sub l_description {
    my $self = shift;
    return lp($self->name, 'work_attribute_type')
}

sub allows_value {
    my ($self, $value) = @_;

    return 1 if $self->free_text;
    my %allowed = map { $_->id => 1 } @{ $self->allowed_values };
    return exists $allowed{$value} ? 1 : 0;
}

sub to_json_hash {
    my $self = shift;

    return {
        id => +$self->id,
        name => $self->l_name,
        comment => $self->l_comment,
        freeText => $self->free_text ? \1 : \0,
        parentID => $self->parent_id,
        description => $self->l_description,
    };
}

__PACKAGE__->meta->make_immutable;
1;
