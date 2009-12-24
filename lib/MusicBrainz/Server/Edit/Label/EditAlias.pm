package MusicBrainz::Server::Edit::Label::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT_ALIAS );

extends 'MusicBrainz::Server::Edit::Alias::Edit';

sub _alias_model { shift->c->model('Label')->alias }

sub edit_name { 'Edit label alias' }
sub edit_type { $EDIT_LABEL_EDIT_ALIAS }

sub related_entities { { label => [ shift->label_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Label')->adjust_edit_pending($adjust, $self->label_id);
    $self->c->model('Label')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub label_id { shift->data->{entity_id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
