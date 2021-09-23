package MusicBrainz::Server::Edit::Place::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw(
    $EDIT_PLACE_CREATE
    $EDIT_PLACE_EDIT
);
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( CoordinateHash Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    coordinate_closure
    date_closure
    merge_coordinates
    merge_partial_date
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Place';
use aliased 'MusicBrainz::Server::Entity::Area';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Coordinates';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Place';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_PLACE_CREATE,
    entity_type => 'place',
};
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';

sub edit_name { N_l('Edit place') }
sub edit_type { $EDIT_PLACE_EDIT }

sub _edit_model { 'Place' }

sub change_fields
{
    return Dict[
        name        => Optional[Str],
        comment     => Optional[Str],
        type_id     => Nullable[Int],
        address     => Optional[Str],
        area_id     => Nullable[Int],
        coordinates => Nullable[CoordinateHash],
        begin_date  => Optional[PartialDateHash],
        end_date    => Optional[PartialDateHash],
        ended       => Optional[Bool],
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

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
                         PlaceType => 'type_id',
                         Area      => 'area_id',
                      ));
    $relations->{Place} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        type       => [ qw( type_id PlaceType )],
        name       => 'name',
        ended      => 'ended',
        comment    => 'comment',
        address    => 'address',
        area       => [ qw( area_id Area ) ]
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{place} = to_json_object(
        $loaded->{Place}{ $self->data->{entity}{id} } ||
        Place->new( name => $self->data->{entity}{name} )
    );

    for my $side (qw( old new )) {
        $data->{area}{$side} = to_json_object($data->{area}{$side} // Area->new())
            if defined $self->data->{$side}{area_id};
    }

    for my $date_prop (qw( begin_date end_date )) {
        if (exists $self->data->{new}{$date_prop}) {
            $data->{$date_prop} = {
                new => to_json_object(PartialDate->new($self->data->{new}{$date_prop})),
                old => to_json_object(PartialDate->new($self->data->{old}{$date_prop})),
            };
        }
    }

    if (exists $self->data->{new}{coordinates}) {
        $data->{coordinates} = {
            new => defined $self->data->{new}{coordinates}
                ? to_json_object(Coordinates->new($self->data->{new}{coordinates}))
                : undef,
            old => defined $self->data->{old}{coordinates}
                ? to_json_object(Coordinates->new($self->data->{old}{coordinates}))
                : undef,
        };
    }

    if (exists $self->data->{new}{ended}) {
        $data->{ended} = {
            new => boolean_to_json($self->data->{new}{ended}),
            old => boolean_to_json($self->data->{old}{ended}),
        };
    }

    if (exists $data->{type}) {
        $data->{type}{old} = to_json_object($data->{type}{old});
        $data->{type}{new} = to_json_object($data->{type}{new});
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
        coordinates  => coordinate_closure('coordinates'),
    );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->entity_id);

    return 0 if exists $self->data->{old}{coordinates};

    my ($old_address, $new_address) = normalise_strings(
        $self->data->{old}{address}, $self->data->{new}{address});
    return 0 if $old_address ne $new_address;

    # Don't allow an autoedit if the area changed
    return 0 if defined $self->data->{old}{area_id};

    return $self->$orig(@args);
};

sub current_instance {
    my $self = shift;
    my $place = $self->c->model('Place')->get_by_id($self->entity_id);
    return $place;
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

sub edit_template_react { 'EditPlace' }

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('begin_date') {
            return merge_partial_date('begin_date' => $ancestor, $current, $new);
        }

        when ('end_date') {
            return merge_partial_date('end_date' => $ancestor, $current, $new);
        }

        when ('coordinates') {
            return merge_coordinates('coordinates' => $ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

before restore => sub {
    my ($self, $data) = @_;

    for my $side ($data->{old}, $data->{new}) {
        $side->{coordinates} = undef
            if defined $side->{coordinates} && !defined $side->{coordinates}{latitude};
    }
};

override _is_disambiguation_needed => sub {
    my ($self, %opts) = @_;

    my ($name, $area_id) = $opts{qw(name area_id)};
    my $duplicate_areas = $self->c->sql->select_single_column_array(
        'SELECT area FROM place
         WHERE id != ? AND lower(musicbrainz_unaccent(name)) = lower(musicbrainz_unaccent(?))',
        $self->current_instance->id, $name
    );

    return $self->_possible_duplicate_area($area_id, @$duplicate_areas);
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
