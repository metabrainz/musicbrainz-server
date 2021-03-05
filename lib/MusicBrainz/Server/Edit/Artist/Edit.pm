package MusicBrainz::Server::Edit::Artist::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw(
    $ARTIST_TYPE_GROUP
    $EDIT_ARTIST_CREATE
    $EDIT_ARTIST_EDIT
);
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Area';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Artist';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::IPI';
with 'MusicBrainz::Server::Edit::Role::ISNI';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_ARTIST_CREATE,
    entity_type => 'artist',
};

sub edit_name { N_l('Edit artist') }
sub edit_type { $EDIT_ARTIST_EDIT }

sub edit_template_react { "EditArtist" }

sub _edit_model { 'Artist' }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        gender_id  => Nullable[Int],
        area_id    => Nullable[Int],
        begin_area_id => Nullable[Int],
        end_area_id => Nullable[Int],
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

around initialize => sub {
    my ($orig, $self, %opts) = @_;

    $opts{ended} = 1 if $opts{end_area_id};

    $self->$orig(%opts);
};

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
                          ArtistType => 'type_id',
                          Area => 'area_id',
                          Gender => 'gender_id',
                      ));
    changed_relations($self->data, $relations, (
                          Area => 'begin_area_id',
                      ));
    changed_relations($self->data, $relations, (
                          Area => 'end_area_id',
                      ));
    $relations->{Artist} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my @areas = qw( area begin_area end_area );

    my %map = (
        type       => [ qw( type_id ArtistType )],
        gender     => [ qw( gender_id Gender )],
        ( map { $_ => [ $_ . '_id', 'Area'] } @areas ),
        name       => 'name',
        sort_name  => 'sort_name',
        comment    => 'comment',
        ended      => 'ended'
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{artist} = to_json_object(
        $loaded->{Artist}{ $self->data->{entity}{id} } ||
        Artist->new( name => $self->data->{entity}{name} )
    );

    for my $area (@areas) {
        for my $side (qw( old new )) {
            $data->{$area}{$side} = to_json_object($data->{$area}{$side} // Area->new())
                if defined $self->data->{$side}{$area . '_id'};
        }
    }

    for my $date_prop (qw( begin_date end_date )) {
        if (exists $self->data->{new}{$date_prop}) {
            $data->{$date_prop} = {
                new => to_json_object(PartialDate->new($self->data->{new}{$date_prop})),
                old => to_json_object(PartialDate->new($self->data->{old}{$date_prop})),
            };
        }
    }

    for my $prop (qw( ipi_codes isni_codes )) {
        if (exists $self->data->{new}{$prop}) {
            $data->{$prop}{old} = $self->data->{old}{$prop};
            $data->{$prop}{new} = $self->data->{new}{$prop};
        }
    }

    if (exists $data->{ended}) {
        $data->{ended}{old} = boolean_to_json($data->{ended}{old});
        $data->{ended}{new} = boolean_to_json($data->{ended}{new});
    }

    if (exists $data->{type}) {
        $data->{type}{old} = to_json_object($data->{type}{old});
        $data->{type}{new} = to_json_object($data->{type}{new});
    }

    if (exists $data->{gender}) {
        $data->{gender}{old} = to_json_object($data->{gender}{old});
        $data->{gender}{new} = to_json_object($data->{gender}{new});
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
        isni_codes => sub {
            my $isnis = $self->c->model('Artist')->isni->find_by_entity_id(shift->id);
            return [ map { $_->isni } @$isnis ];
        },
    );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->entity_id);

    return 0 if exists $self->data->{old}{gender_id} &&
        defined($self->data->{old}{gender_id}) && $self->data->{old}{gender_id} != 0;

    return 0 if exists $self->data->{old}{area_id} &&
        defined($self->data->{old}{area_id}) && $self->data->{old}{area_id} != 0;

    return 0 if exists $self->data->{old}{begin_area_id} &&
        defined($self->data->{old}{begin_area_id}) && $self->data->{old}{begin_area_id} != 0;

    return 0 if exists $self->data->{old}{end_area_id} &&
        defined($self->data->{old}{end_area_id}) && $self->data->{old}{end_area_id} != 0;

    if (defined $self->data->{new}{ipi_codes}) {
        # If there's already IPIs for the artist, not an autoedit
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
        # If there's already ISNIs for the artist, not an autoedit
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
    $self->c->model('Artist')->get_by_id($self->entity_id);
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

around merge_changes => sub {
    my ($orig, $self, @args) = @_;

    my $merged = $self->$orig(@args);
    my $artist = $self->current_instance;
    my $gender_id = exists $merged->{gender_id} ?
            $merged->{gender_id} : $artist->gender_id;
    my $type_id = exists $merged->{type_id} ?
            $merged->{type_id} : $artist->type_id;

    if (defined $gender_id && defined $type_id) {
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
            'A group of artists cannot have a gender.'
        ) if ($type_id == $ARTIST_TYPE_GROUP) || $self->c->sql->select_single_value(
            'SELECT 1 FROM artist_type WHERE id = ? AND parent = ?',
            $type_id, $ARTIST_TYPE_GROUP,
        );
    }

    return $merged;
};

sub _conflicting_entity_path {
    my ($self, $mbid) = @_;
    return "/artist/$mbid";
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
