package MusicBrainz::Server::Edit::Recording::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Recording';

sub _alias_model { shift->c->model('Recording')->alias }

sub edit_name { N_lp('Edit recording alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_RECORDING_EDIT_ALIAS }

sub _build_related_entities { { recording => [ shift->recording_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Recording')->adjust_edit_pending($adjust, $self->recording_id);
    $self->c->model('Recording')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub recording_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
