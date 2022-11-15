package MusicBrainz::Server::Edit::Release::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Release';

sub _alias_model { shift->c->model('Release')->alias }

sub edit_name { N_l('Edit release alias') }
sub edit_kind { 'edit' }
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
