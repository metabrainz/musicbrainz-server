package MusicBrainz::Server::Edit::Alias::Delete;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( :expire_action :quality );

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

sub edit_conditions
{
    return {
        $QUALITY_LOW => {
            duration      => 4,
            votes         => 1,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_NORMAL => {
            duration      => 14,
            votes         => 3,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_HIGH => {
            duration      => 14,
            votes         => 4,
            expire_action => $EXPIRE_REJECT,
            auto_edit     => 0,
        },
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
