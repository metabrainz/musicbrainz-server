package MusicBrainz::Server::Edit::Label::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_DELETE }
sub edit_name { "Delete Label" }
sub entity_model { 'Label' }
sub entity_id { shift->label_id }

has '+data' => (
    isa => Dict[
        label => Int
    ]
);

has 'label' => (
    isa => 'Label',
    is => 'rw'
);

sub entities
{
    my $self = shift;
    return {
        label => [ $self->label_id ],
    }
}

sub label_id
{
    return shift->data->{label};
}

sub initialize
{
    my ($self, %args) = @_;
    $self->data({ label => $args{label_id} });
}

override 'accept' => sub
{
    my $self = shift;
    my $label_data = MusicBrainz::Server::Data::Label->new(c => $self->c);
    $label_data->delete($self->label_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;

