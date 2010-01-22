package MusicBrainz::Server::Edit::Generic::Merge;
use Moose;
use MooseX::ABC;

use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
requires '_merge_model';

sub alter_edit_pending
{
    my $self = shift;
    return {
        $self->_merge_model => $self->_entities
    }
}

sub related_entities
{
    my $self = shift;
    return {
        model_to_type($self->_merge_model) => $self->_entities
    }
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

has '+data' => (
    isa => Dict[
        new_entity_id => Int,
        old_entity_id => Int,
    ]
);

sub new_entity_id { shift->data->{new_entity_id} }
sub old_entity_id { shift->data->{old_entity_id} }

sub foreign_keys
{
    my $self = shift;
    return {
        $self->_merge_model => $self->_entities
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $model = $self->_merge_model;
    return {
        old => $loaded->{ $model }->{ $self->old_entity_id },
        new => $loaded->{ $model }->{ $self->new_entity_id }
    }
}

override 'accept' => sub
{
    my $self = shift;
    $self->c->model( $self->_merge_model )->merge($self->new_entity_id, $self->old_entity_id);
};

sub _entities
{
    my $self = shift;
    return [
        $self->old_entity_id,
        $self->new_entity_id
    ];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

