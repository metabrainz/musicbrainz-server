package MusicBrainz::Server::Edit::Label::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw(
    $EDIT_LABEL_CREATE
    $EDIT_LABEL_EDIT
);
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    date_closure
    changed_relations
    changed_display_data
    merge_partial_date
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Validation qw( normalise_strings );
use MusicBrainz::Server::Translation qw( N_l );

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Area';

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Label';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::IPI';
with 'MusicBrainz::Server::Edit::Role::ISNI';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_LABEL_CREATE,
    entity_type => 'label',
};

sub edit_type { $EDIT_LABEL_EDIT }
sub edit_name { N_l('Edit label') }
sub edit_template_react { 'EditLabel' }
sub _edit_model { 'Label' }
sub label_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        label_code => Nullable[Int],
        area_id    => Nullable[Int],
        comment    => Nullable[Str],
        ipi_codes  => Optional[ArrayRef[Str]],
        isni_codes  => Optional[ArrayRef[Str]],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ended      => Optional[Bool]
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
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        LabelType => 'type_id',
        Area      => 'area_id',
    );

    $relations->{Label} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name       => 'name',
        sort_name  => 'sort_name',
        type       => [ qw( type_id LabelType ) ],
        label_code => 'label_code',
        comment    => 'comment',
        area       => [ qw( area_id Area ) ],
        ended      => 'ended'
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    for my $period (qw( begin end )) {
        my $field = $period . '_date';
        if (exists $self->data->{new}{$field}) {
            $data->{$field} = {
                new => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{new}{$field}),
                old => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{$field}),
            };
        }
    }

    $data->{label} = $loaded->{Label}{ $self->data->{entity}{id} }
        || Label->new( name => $self->data->{entity}{name} );

    if (exists $self->data->{new}{ipi_codes}) {
        $data->{ipi_codes}{old} = $self->data->{old}{ipi_codes};
        $data->{ipi_codes}{new} = $self->data->{new}{ipi_codes};
    }

    if (exists $self->data->{new}{isni_codes}) {
        $data->{isni_codes}{old} = $self->data->{old}{isni_codes};
        $data->{isni_codes}{new} = $self->data->{new}{isni_codes};
    }

    if (exists $data->{ended}) {
        $data->{ended}{old} = boolean_to_json($data->{ended}{old});
        $data->{ended}{new} = boolean_to_json($data->{ended}{new});
    }

    for my $side (qw( old new )) {
        $data->{area}{$side} //= Area->new()
            if defined $self->data->{$side}{area_id};
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
            my $ipis = $self->c->model('Label')->ipi->find_by_entity_id(shift->id);
            return [ map { $_->ipi } @$ipis ];
        },
        isni_codes => sub {
            my $isnis = $self->c->model('Label')->isni->find_by_entity_id(shift->id);
            return [ map { $_->isni } @$isnis ];
        },
    );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->entity_id);

    my ($old_label_code, $new_label_code) = normalise_strings(
        $self->data->{old}{label_code}, $self->data->{new}{label_code});
    return 0 if $self->data->{old}{label_code} &&
        $old_label_code ne $new_label_code;

    # Don't allow an autoedit if the area changed
    return 0 if defined $self->data->{old}{area_id};

    if (defined $self->data->{new}{ipi_codes}) {
        # If there's already IPIs for the label, not an autoedit
        if (@{ $self->data->{old}{ipi_codes} // [] }) {
            return 0;
        }

        # If there's already an entity with any of the IPIs, not an autoedit
        my $reused_ipis = $self->reused_ipis;

        if (%$reused_ipis) {
            return 0;
        }
    }
        
    if (defined $self->data->{new}{isni_codes}) {
        # If there's already ISNIs for the label, not an autoedit
        if (@{ $self->data->{old}{isni_codes} // [] }) {
            return 0;
        }

        # If there's already an entity with any of the ISNIs, not an autoedit
        my $reused_isnis = $self->reused_isnis;

        if (%$reused_isnis) {
            return 0;
        }
    }

    return $self->$orig(@args);
};

sub current_instance {
    my $self = shift;
    $self->c->model('Label')->get_by_id($self->entity_id),
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

sub _conflicting_entity_path {
    my ($self, $mbid) = @_;
    return "/label/$mbid";
}

sub restore {
    my ($self, $data) = @_;

    for my $side (qw( old new )) {
        $data->{$side}{area_id} = delete $data->{$side}{country_id}
            if exists $data->{$side}{country_id};

        $data->{$side}{ipi_codes} = [ delete $data->{$side}{ipi_code} // () ]
            if exists $data->{$side}{ipi_code};
    }

    $self->data($data);
}

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
