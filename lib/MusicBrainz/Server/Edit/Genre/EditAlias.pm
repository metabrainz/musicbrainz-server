package MusicBrainz::Server::Edit::Genre::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Genre';

sub _alias_model { shift->c->model('Genre')->alias }

sub edit_name { N_lp('Edit genre alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_GENRE_EDIT_ALIAS }

sub _build_related_entities { { genre => [ shift->genre_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Genre')->adjust_edit_pending($adjust, $self->genre_id);
    $self->c->model('Genre')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub genre_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
