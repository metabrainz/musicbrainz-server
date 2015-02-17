package MusicBrainz::Server::Edit::Series::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw ( N_l );
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict );

use aliased 'MusicBrainz::Server::Entity::Series';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Series';
with 'MusicBrainz::Server::Edit::Role::SubscribeOnCreation' => {
    editor_subscription_preference => sub { shift->subscribe_to_created_series }
};
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add series') }
sub edit_type { $EDIT_SERIES_CREATE }
sub _create_model { 'Series' }
sub series_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name                    => Str,
        comment                 => Str,
        type_id                 => Int,
        ordering_type_id        => Int,
    ]
);

sub foreign_keys {
    my $self = shift;

    return {
        Series              => [ $self->entity_id ],
        SeriesType          => [ $self->data->{type_id} ],
        SeriesOrderingType  => [ $self->data->{ordering_type_id} ],
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        name                => $self->data->{name},
        comment             => $self->data->{comment},
        series              => $loaded->{Series}->{$self->entity_id},
        type                => $loaded->{SeriesType}->{$self->{data}->{type_id}},
        ordering_type       => $loaded->{SeriesOrderingType}->{$self->data->{ordering_type_id}},
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut
