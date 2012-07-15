package MusicBrainz::Server::Edit::Artist::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Translation qw ( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use JSON::Any;

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Artist';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::IPI';

sub edit_name { N_l('Edit artist') }
sub edit_type { $EDIT_ARTIST_EDIT }

sub _edit_model { 'Artist' }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        gender_id  => Nullable[Int],
        country_id => Nullable[Int],
        comment    => Nullable[Str],
        ipi_code   => Nullable[Str],
        ipi_codes  => Optional[ArrayRef[Str]],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ended      => Optional[Bool]
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
                          ArtistType => 'type_id',
                          Country => 'country_id',
                          Gender => 'gender_id',
                      ));
    $relations->{Artist} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        type       => [ qw( type_id ArtistType )],
        gender     => [ qw( gender_id Gender )],
        country    => [ qw( country_id Country )],
        name       => 'name',
        sort_name  => 'sort_name',
        ipi_code   => 'ipi_code',
        comment    => 'comment',
        ended      => 'ended'
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{artist} = $loaded->{Artist}{ $self->data->{entity}{id} }
        || Artist->new( name => $self->data->{entity}{name} );

    if (exists $self->data->{new}{begin_date}) {
        $data->{begin_date} = {
            new => PartialDate->new($self->data->{new}{begin_date}),
            old => PartialDate->new($self->data->{old}{begin_date}),
        };
    }

    if (exists $self->data->{new}{end_date}) {
        $data->{end_date} = {
            new => PartialDate->new($self->data->{new}{end_date}),
            old => PartialDate->new($self->data->{old}{end_date}),
        };
    }

    if (exists $self->data->{new}{end_date}) {
        $data->{end_date} = {
            new => PartialDate->new($self->data->{new}{end_date}),
            old => PartialDate->new($self->data->{old}{end_date}),
        };
    }

    if (exists $self->data->{new}{ipi_codes}) {
        $data->{ipi_codes}->{old} = $self->data->{old}{ipi_codes};
        $data->{ipi_codes}->{new} = $self->data->{new}{ipi_codes};
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
        ipi_codes => sub {
            my $ipis = $self->c->model('Artist')->ipi->find_by_entity_id(shift->id);
            return [ map { $_->ipi } @$ipis ];
        },
    );
}

sub allow_auto_edit
{
    my ($self) = @_;

    # Changing name or sortname is allowed if the change only affects
    # small things like case etc.
    my ($old_name, $new_name) = normalise_strings(
        $self->data->{old}{name}, $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_sort_name, $new_sort_name) = normalise_strings(
        $self->data->{old}{sort_name}, $self->data->{new}{sort_name});
    return 0 if $old_sort_name ne $new_sort_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    # Adding a date is automatic if there was no date yet.
    return 0 if exists $self->data->{old}{begin_date}
        and partial_date_from_row($self->data->{old}{begin_date})->format ne '';
    return 0 if exists $self->data->{old}{end_date}
        and partial_date_from_row($self->data->{old}{end_date})->format ne '';

    return 0 if exists $self->data->{old}{type_id}
        and defined($self->data->{old}{type_id}) && $self->data->{old}{type_id} != 0;

    return 0 if exists $self->data->{old}{gender_id}
        and defined($self->data->{old}{gender_id}) && $self->data->{old}{gender_id} != 0;

    return 0 if exists $self->data->{old}{country_id}
        and defined($self->data->{old}{country_id}) && $self->data->{old}{country_id} != 0;

    return 0 if exists $self->data->{old}{ended}
        and $self->data->{old}{ended} != $self->data->{new}{ended};

    if ($self->data->{old}{ipi_code}) {
        my ($old_ipi, $new_ipi) = normalise_strings($self->data->{old}{ipi_code},
                                                    $self->data->{new}{ipi_code});
        return 0 if $new_ipi ne $old_ipi;
    }

    return 0 if $self->data->{new}{ipi_codes};

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->c->model('Artist')->get_by_id($self->entity_id),
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
