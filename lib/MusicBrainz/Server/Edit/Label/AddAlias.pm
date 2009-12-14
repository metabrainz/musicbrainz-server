package MusicBrainz::Server::Edit::Label::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ALIAS );

extends 'MusicBrainz::Server::Edit::Alias::Add';

sub _alias_model { shift->c->model('Label')->alias }

sub edit_name { 'Add label alias' }
sub edit_type { $EDIT_LABEL_ADD_ALIAS }

sub related_entities { { label => [ shift->label_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Label')->adjust_edit_pending($adjust, $self->label_id);
    $self->c->model('Label')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

around 'foreign_keys' => sub
{
    my $orig = shift;
    my $self = shift;

    my $keys = $self->$orig();
    $keys->{Label}->{ $self->label_id } = [];

    return $keys;
};

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{label} = $loaded->{Label}->{ $self->label_id };

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

