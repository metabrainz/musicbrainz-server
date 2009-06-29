package MusicBrainz::Server::Edit::Label::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Data::Label;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_MERGE }
sub edit_name { "Merge Labels" }
sub entity_model { 'Label' }
sub entity_id {
    my $self = shift;
    return [ $self->old_label_id, $self->new_label_id ]
}

sub entities
{
    return {
        label => shift->entity_id
    }
}

sub old_label_id
{
    return shift->data->{old_label};
}

sub new_label_id
{
    return shift->data->{new_label};
}

has [qw( old_label new_label )] => (
    isa => 'Label',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        new_label => Int,
        old_label => Int,
    ]
);

sub initialize
{
    my ($self, %args) = @_;
    $self->data({
        old_label => $args{old_label_id},
        new_label => $args{new_label_id}
    });
}

override 'accept' => sub
{
    my $self = shift;
    my $label_data = MusicBrainz::Server::Data::Label->new(c => $self->c);
    my $label = $label_data->merge($self->old_label_id => $self->new_label_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;
no Moose;

1;
