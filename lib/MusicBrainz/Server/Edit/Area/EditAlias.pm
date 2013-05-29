package MusicBrainz::Server::Edit::Area::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Area';

sub _alias_model { shift->c->model('Area')->alias }

sub edit_name { N_l('Edit area alias') }
sub edit_type { $EDIT_AREA_EDIT_ALIAS }

sub _build_related_entities { { area => [ shift->area_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Area')->adjust_edit_pending($adjust, $self->area_id);
    $self->c->model('Area')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub area_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
