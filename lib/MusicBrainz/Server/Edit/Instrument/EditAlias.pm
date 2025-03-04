package MusicBrainz::Server::Edit::Instrument::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Instrument';

sub _alias_model { shift->c->model('Instrument')->alias }

sub edit_name { N_lp('Edit instrument alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_INSTRUMENT_EDIT_ALIAS }

sub _build_related_entities { { instrument => [ shift->instrument_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Instrument')->adjust_edit_pending($adjust, $self->instrument_id);
    $self->c->model('Instrument')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub instrument_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
