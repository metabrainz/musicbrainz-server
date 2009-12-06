package MusicBrainz::Server::Edit::Label::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_DELETE }
sub edit_name { "Delete Label" }

sub alter_edit_pending { { Label => [ shift->data->{label_id} ] } }
sub related_entities { { label => [ shift->data->{label_id} ] } }

has '+data' => (
    isa => Dict[
        label_id => Int,
        name => Str,
    ]
);

sub build_display_data
{
    my $self = shift;
    return {
        name => $self->data->{name}
    };
}

sub initialize
{
    my ($self, %args) = @_;
    my $label = delete $args{label} or die "Required 'label' object";

    $self->data({
        name     => $label->name,
        label_id => $label->id,
    });
}
    
override 'accept' => sub
{
    my $self = shift;
    $self->c->model('Label')->delete($self->data->{label_id});
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;

