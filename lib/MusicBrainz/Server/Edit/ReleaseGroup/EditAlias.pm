package MusicBrainz::Server::Edit::ReleaseGroup::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT_ALIAS );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

sub _alias_model { shift->c->model('ReleaseGroup')->alias }

sub edit_name { N_lp('Edit release group alias', 'edit type') }
sub edit_kind { $EDIT_KIND_LABELS{'edit'} }
sub edit_type { $EDIT_RELEASEGROUP_EDIT_ALIAS }

sub _build_related_entities { { release_group => [ shift->release_group_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('ReleaseGroup')->adjust_edit_pending($adjust, $self->release_group_id);
    $self->c->model('ReleaseGroup')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub release_group_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
