package MusicBrainz::Server::Edit::Artist::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Artist';

sub _alias_model { shift->c->model('Artist')->alias }

sub edit_name { N_l('Edit artist alias') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_ARTIST_EDIT_ALIAS }

sub _build_related_entities { { artist => [ shift->artist_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Artist')->adjust_edit_pending($adjust, $self->artist_id);
    $self->c->model('Artist')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub artist_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
