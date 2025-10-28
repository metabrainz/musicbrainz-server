package MusicBrainz::Server::Edit::Series::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw ( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Series';

sub _alias_model { shift->c->model('Series')->alias }

sub edit_name { N_lp('Edit series alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_SERIES_EDIT_ALIAS }

sub _build_related_entities { { series => [ shift->series_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Series')->adjust_edit_pending($adjust, $self->series_id);
    $self->c->model('Series')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub series_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
