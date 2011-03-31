package MusicBrainz::Server::Edit::Alias::Delete;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

has '+data' => (
    isa => Dict[
        alias_id  => Int,
        entity    => Dict[
            id   => Int,
            name => Str
        ],
        name      => Str,
    ]
);

sub build_display_data
{
    my $self = shift;
    return {
        alias => $self->data->{name}
    };
}

has 'alias_id' => (
    isa => 'Int',
    is => 'rw',
    default => sub { shift->data->{alias_id} },
    lazy => 1
);

has 'alias' => (
    is => 'rw',
);

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;
    $model->delete($self->alias_id);
}

sub initialize
{
    my ($self, %opts) = @_;
    my $alias = $opts{alias} or die 'Missing required "alias" argument';
    my $entity = delete $opts{entity} or die 'Missing required "entity" argument';

    $self->data({
        entity    => {
            id   => $entity->id,
            name => $entity->name
        },
        alias_id  => $alias->id,
        name      => $alias->name,
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
