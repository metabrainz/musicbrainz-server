package MusicBrainz::Server::Edit::Series::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
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
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';

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

    my $data = $self->data;
    my $name = $data->{name};
    my $comment = $data->{comment};
    my $type_id = $data->{type_id};
    my $ordering_type_id = $data->{ordering_type_id};

    return {
        name                => $name,
        comment             => $comment,
        series              => to_json_object((defined($self->entity_id) &&
                                $loaded->{Series}{$self->entity_id}) ||
                                Series->new(
                                    name => $name,
                                    comment => $comment,
                                    type_id => $type_id,
                                    ordering_type_id => $ordering_type_id,
                                ),
                            ),
        type                => to_json_object($loaded->{SeriesType}{$type_id}),
        ordering_type       => to_json_object($loaded->{SeriesOrderingType}{$ordering_type_id}),
    };
}

sub edit_template_react { 'AddSeries' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
