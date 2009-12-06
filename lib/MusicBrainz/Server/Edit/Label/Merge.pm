package MusicBrainz::Server::Edit::Label::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Data::Label;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_MERGE }
sub edit_name { "Merge labels" }

sub related_entities
{
    my $self = shift;
    return {
        label => [ $self->old_label_id, $self->new_label_id ],
    }
}

sub alter_edit_pending
{
    my $self = shift;
    return {
        Label => [ $self->old_label_id, $self->new_label_id ],
    }
}

has 'old_label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{old_label} }
);

has 'new_label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{new_label} }
);

has '+data' => (
    isa => Dict[
        new_label => Int,
        old_label => Int,
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Label => [ $self->data->{old_label}, $self->data->{new_label} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        new => $loaded->{Label}->{ $self->data->{new_label} },
        old => $loaded->{Label}->{ $self->data->{old_label} },
    };
}

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
    $self->c->model('Label')->merge($self->new_label_id, $self->old_label_id);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
