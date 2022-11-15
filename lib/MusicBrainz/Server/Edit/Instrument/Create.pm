package MusicBrainz::Server::Edit::Instrument::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict );

use aliased 'MusicBrainz::Server::Entity::Instrument';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Instrument';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Add instrument') }
sub edit_type { $EDIT_INSTRUMENT_CREATE }
sub _create_model { 'Instrument' }
sub instrument_id { shift->entity_id }
sub edit_template { 'AddInstrument' }

has '+data' => (
    isa => Dict[
        name        => Str,
        comment     => Nullable[Str],
        type_id     => Nullable[Int],
        description => Nullable[Str],
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        Instrument       => [ $self->entity_id ],
        InstrumentType   => [ $self->data->{type_id} ],
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name ) ),
        type        => $type ? to_json_object($loaded->{InstrumentType}{$type}) : undef,
        instrument  => to_json_object((defined($self->entity_id) &&
            $loaded->{Instrument}{ $self->entity_id }) ||
            Instrument->new( name => $self->data->{name} )
        ),
        comment     => $self->data->{comment},
        description => $self->data->{description},
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
