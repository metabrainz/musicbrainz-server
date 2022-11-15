package MusicBrainz::Server::Edit::Label::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Label';

sub _alias_model { shift->c->model('Label')->alias }

sub edit_name { N_l('Edit label alias') }
sub edit_kind { 'edit' }
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
