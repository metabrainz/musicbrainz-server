package MusicBrainz::Server::Edit::Work::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

sub _alias_model { shift->c->model('Work')->alias }

sub edit_name { N_l('Edit work alias') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_WORK_EDIT_ALIAS }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Work')->adjust_edit_pending($adjust, $self->work_id);
    $self->c->model('Work')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub work_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
