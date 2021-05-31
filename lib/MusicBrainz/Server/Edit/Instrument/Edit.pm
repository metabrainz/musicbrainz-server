package MusicBrainz::Server::Edit::Instrument::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_EDIT );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Instrument';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Instrument';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit instrument') }
sub edit_type { $EDIT_INSTRUMENT_EDIT }
sub edit_template_react { "EditInstrument" }

sub _edit_model { 'Instrument' }

sub change_fields {
    return Dict[
        name        => Optional[Str],
        comment     => Nullable[Str],
        type_id     => Nullable[Int],
        description => Nullable[Str],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        new => change_fields(),
        old => change_fields(),
    ]
);

sub foreign_keys {
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
                        InstrumentType => 'type_id',
                      ));
    $relations->{Instrument} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %map = (
        type        => [ qw( type_id InstrumentType )],
        name        => 'name',
        comment     => 'comment',
        description => 'description',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{instrument} = to_json_object(
        $loaded->{Instrument}{ $self->data->{entity}{id} } ||
        Instrument->new( name => $self->data->{entity}{name} )
    );

    if (defined $data->{type}) {
        $data->{type}{old} = to_json_object($data->{type}{old});
        $data->{type}{new} = to_json_object($data->{type}{new});
    }

    return $data;
}

sub current_instance {
    my $self = shift;
    my $instrument = $self->c->model('Instrument')->get_by_id($self->entity_id);
    return $instrument;
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
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
