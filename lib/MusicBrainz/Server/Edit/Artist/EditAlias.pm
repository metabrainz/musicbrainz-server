package MusicBrainz::Server::Edit::Artist::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT_ALIAS );

extends 'MusicBrainz::Server::Edit::Alias::Edit';

sub _alias_model { shift->c->model('Artist')->alias }

sub edit_name { 'Edit artist alias' }
sub edit_type { $EDIT_ARTIST_EDIT_ALIAS }

sub related_entities { { artist => [ shift->artist_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Artist')->adjust_edit_pending($adjust, $self->artist_id);
    $self->c->model('Artist')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub artist_id { shift->data->{entity_id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
