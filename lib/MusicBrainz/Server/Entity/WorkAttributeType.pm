package MusicBrainz::Server::Entity::WorkAttributeType;
use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'WorkAttributeType',
};

sub entity_type { 'work_attribute_type' }

has free_text => (
    is => 'rw',
    isa => 'Bool',
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

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        free_text => boolean_to_json($self->free_text),
    };
};

__PACKAGE__->meta->make_immutable;
1;
