package MusicBrainz::Server::Edit::Alias::Delete;
use Moose;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

has '+data' => (
    isa => Dict[
        alias_id => Int,
        entity_id => Int,
    ]
);

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
    $self->data({
        entity_id => $opts{entity_id},
        alias_id => $opts{alias_id},
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
