package MusicBrainz::Server::Edit::Label::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Label';

sub _alias_model { shift->c->model('Label')->alias }

sub edit_name { N_lp('Edit label alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_LABEL_EDIT_ALIAS }

sub _build_related_entities { { label => [ shift->label_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Label')->adjust_edit_pending($adjust, $self->label_id);
    $self->c->model('Label')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub label_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
