package MusicBrainz::Server::Edit::Area::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_EDIT );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw ( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use JSON::Any;

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Area';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Area';

sub edit_name { N_l('Edit area') }
sub edit_type { $EDIT_AREA_EDIT }

sub _edit_model { 'Area' }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ended      => Optional[Bool],
        iso_3166_1  => Optional[ArrayRef[Str]],
        iso_3166_2  => Optional[ArrayRef[Str]],
        iso_3166_3  => Optional[ArrayRef[Str]],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
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
                          AreaType => 'type_id',
                      ));
    $relations->{Area} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        type       => [ qw( type_id AreaType )],
        name       => 'name',
        sort_name  => 'sort_name',
        ended      => 'ended'
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{area} = $loaded->{Area}{ $self->data->{entity}{id} }
        || Area->new( name => $self->data->{entity}{name} );

    for my $date_prop (qw( begin_date end_date )) {
        if (exists $self->data->{new}{$date_prop}) {
            $data->{$date_prop} = {
                new => PartialDate->new($self->data->{new}{$date_prop}),
                old => PartialDate->new($self->data->{old}{$date_prop}),
            };
        }
    }

    for my $prop (qw( iso_3166_1 iso_3166_2 iso_3166_3 )) {
        if (exists $self->data->{new}{$prop}) {
            $data->{$prop}->{old} = $self->data->{old}{$prop};
            $data->{$prop}->{new} = $self->data->{new}{$prop};
        }
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
        iso_3166_1 => sub {
            return $self->c->sql->select_single_column_array("SELECT code FROM iso_3166_1 WHERE area = ?", shift->id);
        },
        iso_3166_2 => sub {
            return $self->c->sql->select_single_column_array("SELECT code FROM iso_3166_2 WHERE area = ?", shift->id);
        },
        iso_3166_3 => sub {
            return $self->c->sql->select_single_column_array("SELECT code FROM iso_3166_3 WHERE area = ?", shift->id);
        },
    );
}

sub allow_auto_edit
{
    return 1;
}

sub current_instance {
    my $self = shift;
    my $area = $self->c->model('Area')->get_by_id($self->entity_id);
    $self->c->model('Area')->load_codes($area);
    return $area;
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

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
        default {
            return ($self->$orig(@_));
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation

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
