package MusicBrainz::Server::Edit::Event::EditAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_EDIT_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Edit';
with 'MusicBrainz::Server::Edit::Event';

sub _alias_model { shift->c->model('Event')->alias }

sub edit_name { N_l('Edit event alias') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_EVENT_EDIT_ALIAS }

sub _build_related_entities { { event => [ shift->event_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Event')->adjust_edit_pending($adjust, $self->event_id);
    $self->c->model('Event')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub event_id { shift->data->{entity}{id} }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
