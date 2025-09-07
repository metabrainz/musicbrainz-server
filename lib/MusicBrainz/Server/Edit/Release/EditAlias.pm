package MusicBrainz::Server::Edit::Release::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Release';

sub _alias_model { shift->c->model('Release')->alias }

sub edit_name { N_lp('Edit release alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_RELEASE_EDIT_ALIAS }

sub _build_related_entities { { release => [ shift->release_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Release')->adjust_edit_pending($adjust, $self->release_id);
    $self->c->model('Release')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub release_id { shift->data->{entity}{id} }

sub release_ids {}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
