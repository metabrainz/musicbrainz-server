package MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use Moose;
use 5.10.0;

use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw( gid_or_id merge_value );
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l l lp );
use MusicBrainz::Server::Entity::Util::MediumFormat qw( combined_medium_format_name );
use Scalar::Util qw( looks_like_number );

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit release label') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELEASE_EDITRELEASELABEL }

sub alter_edit_pending { { Release => [ shift->release_id ] } }

use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::MediumFormat';

subtype 'ReleaseLabelHash'
    => as Dict[
        label => Nullable[Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
        ]],
        catalog_number => Nullable[Str]
    ];

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str,
            barcode => Nullable[Str],
            combined_format => Nullable[Str],
            medium_formats => Nullable[ArrayRef[Str]],
            events => Optional[ArrayRef[Dict[
                date => Nullable[Str],
                country => Nullable[Dict[
                    id => Optional[Int],
                    gid => Optional[Str],
                    name => Optional[Str],
                ]],
            ]]]
        ],
        new => find_type_constraint('ReleaseLabelHash'),
        old => find_type_constraint('ReleaseLabelHash')
    ]
);

sub release_id { shift->data->{release}{id} }
sub release_label_id { shift->data->{release_label_id} }

sub foreign_keys {
    my $self = shift;

    my $data = $self->data;
    my $keys = { Release => { gid_or_id($data->{release}) => [ 'ArtistCredit' ] } };

    $keys->{Label}->{ gid_or_id($data->{old}{label}) } = [] if $self->data->{old}{label};
    $keys->{Label}->{ gid_or_id($data->{new}{label}) } = [] if $self->data->{new}{label};

    $keys->{Area} = [
        grep { $_ } map { gid_or_id($_->{country}) } grep { exists $_->{country} }
        @{ $data->{release}{events} // [] }
    ];

    return $keys;
}

sub process_medium_formats
{
    my ($self, $format_names) = @_;

    return combined_medium_format_name(map {
        if ($_ eq '(unknown)') {
            lp('(unknown)', 'medium format');
        }
        else {
            MediumFormat->new(name => $_)->l_name;
        }
        } @$format_names);
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;

    my $display_data = {
        release => $loaded->{Release}{ gid_or_id($data->{release}) } // Release->new(name => $data->{release}{name}),
        catalog_number => {
            new => $data->{new}{catalog_number},
            old => $data->{old}{catalog_number},
        },
        barcode => $data->{release}{barcode}
    };

    if ($data->{release}{medium_formats}) {
        $display_data->{combined_format} = $self->process_medium_formats($data->{release}{medium_formats});
    }

    $display_data->{events} = [
        map {
            my $event_display = {};

            if (exists $_->{country}) {
                my $country = $_->{country};
                my $country_gid_or_id = gid_or_id($country);

                $event_display->{country} = defined $country_gid_or_id && $loaded->{Area}{$country_gid_or_id};
                $event_display->{country} //= defined $country->{name} && MusicBrainz::Server::Entity::Area->new($country);
            }

            $event_display->{date} = MusicBrainz::Server::Entity::PartialDate->new($_->{date});
            $event_display;
        } @{ $data->{release}{events} // [] }
    ];

    $display_data->{events_json} = [
        map +{
            country => to_json_object($_->{country}),
            date => to_json_object($_->{date}),
        }, @{ $display_data->{events} }
    ];

    for (qw( new old )) {
        if (my $label = $data->{$_}{label}) {
            next unless %$label;
            $display_data->{label}{$_} = $loaded->{Label}{gid_or_id($label)} // Label->new(name => $label->{name});
        }
    }

    return $display_data;
}

around '_build_related_entities' => sub {
    my $orig = shift;
    my $self = shift;
    my $related = $self->$orig;
    my $current_label = $self->current_instance->label;

    $related->{label} = [
        $self->data->{new}{label} ? gid_or_id($self->data->{new}{label}) : (),
        $self->data->{old}{label} ? gid_or_id($self->data->{old}{label}) : (),
        $current_label ? $current_label->gid : (),
    ];

    return $related;
};

sub _serialize_label {
    my $label = shift;

    $label ? {
        gid => $label->gid,
        id => $label->id,
        name => $label->name,
    } : undef;
}

sub _mapping {
    return (
        label => sub { _serialize_label(shift->label) }
    );
}

sub initialize
{
    my ($self, %opts) = @_;
    my $release_label = delete $opts{release_label};
    die "You must specify the release label object to edit"
        unless defined $release_label;

    unless ($release_label->release) {
        $self->c->model('Release')->load($release_label);
        $self->c->model('Medium')->load_for_releases($release_label->release);
        $self->c->model('MediumFormat')->load($release_label->release->all_mediums);
        $self->c->model('ReleaseLabel')->load($release_label->release) unless $release_label->release->all_labels;
    }

    $self->throw_if_release_label_is_duplicate(
        $release_label->release,
        $opts{label} ? $opts{label}->id : undef,
        $opts{catalog_number}
    );

    unless ($release_label->label) {
        $self->c->model('Label')->load($release_label);
    }

    if ($opts{label}) {
        $opts{label} = _serialize_label($opts{label});
    }

    my $data = {
        release_label_id => $release_label->id,
        release => {
            id => $release_label->release->id,
            gid => $release_label->release->gid,
            name => $release_label->release->name,
            medium_formats => [ map { defined $_->format ? $_->format->name : '(unknown)' } $release_label->release->all_mediums ]
        },
        $self->_change_data($release_label, %opts),
    };

    # Keep old data for display (MBS-8534)
    $data->{old}{label} = _serialize_label($release_label->label);
    $data->{old}{catalog_number} = $release_label->catalog_number;

    my $release = $release_label->release;
    $self->c->model('Release')->load_release_events($release);

    $data->{release}{events} = [
        map +{
            date => $_->date->format,
            country => (defined $_->country_id ? {
                id => $_->country->id,
                gid => $_->country->gid,
                name => $_->country->name,
            } : undef),
        }, $release->all_events
    ];

    $data->{release}{barcode} = $release_label->release->barcode->format
        if $release_label->release->barcode;

    $self->data($data);
};

sub accept {
    my $self = shift;

    my $release_label = $self->release_label;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This release label no longer exists.'
    ) unless defined $release_label;

    my %args = %{ $self->merge_changes };

    if (exists $args{label}) {
        if (defined $args{label}) {
            my $label = $self->c->model('Label')->get_by_any_id(gid_or_id($args{label}));

            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                'The new label no longer exists.'
            ) unless $label;

            $args{label_id} = $label->id;
        } else {
            $args{label_id} = undef;
        }

        delete $args{label};
    }

    my $release = $self->c->model('Release')->get_by_any_id(gid_or_id($self->data->{release}));
    $self->c->model('ReleaseLabel')->load($release);

    $self->throw_if_release_label_is_duplicate(
        $release,
        exists($args{label_id}) ? $args{label_id} : $release_label->label_id,
        exists($args{catalog_number}) ? $args{catalog_number} : $release_label->catalog_number,
    );

    $self->c->model('ReleaseLabel')->update($self->release_label_id, \%args);
}

has release_label => (
    is => 'ro',
    default => sub {
        my $self = shift;
        my $release_label = $self->c->model('ReleaseLabel')->get_by_id($self->release_label_id);
        $self->c->model('Label')->load($release_label);
        return $release_label;
    },
    lazy => 1
);

sub ancestor_data {
    my $self = shift;

    my %data = %{ $self->data->{old} };

    if ($data{label}) {
        # Avoid conflicts by following merges.
        my $label = $self->c->model('Label')->get_by_any_id(gid_or_id($data{label}));

        $data{label} = _serialize_label($label) if $label;
    }

    return \%data;
}

sub current_instance {
    my $self = shift;
    return $self->release_label;
}

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('label') {
            return (
                merge_value($ancestor->{label}),
                merge_value(_serialize_label($current->label)),
                merge_value($new->{label}),
            );
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

sub _get_country_hash_from_id_or_name {
    my ($self, $id_or_name) = @_;

    return undef unless non_empty($id_or_name);

    my $country_hash = {};
    my $country;

    if (looks_like_number($id_or_name)) {
        $country_hash->{id} = $id_or_name;
        $country = $self->c->model('Area')->get_by_id($id_or_name);
    } else {
        $country_hash->{name} = $id_or_name;
        ($country) = $self->c->model('Area')->find_by_name($id_or_name);
    }

    if ($country) {
        $country_hash->{id} = $country->id;
        $country_hash->{gid} = $country->gid;
        $country_hash->{name} = $country->name;
    }

    $country_hash;
}

sub restore {
    my ($self, $data) = @_;

    my $release_data = $data->{release};
    my $release_date  = delete $release_data->{date};
    my $release_country = delete $release_data->{country};

    if (non_empty($release_date) || non_empty($release_country)) {
        $release_data->{events} = [
            {
                country => $self->_get_country_hash_from_id_or_name($release_country),
                date => $release_date,
            },
        ];
    }

    if (exists $release_data->{events}) {
        for my $event_data (@{ $release_data->{events} }) {
            my $id = delete $event_data->{country_id};
            my $name = delete $event_data->{country_name};

            if (defined($id)) {
                $event_data->{country} = $self->_get_country_hash_from_id_or_name($id);
            }

            if (defined($name) && !defined($event_data->{country})) {
                $event_data->{country} = $self->_get_country_hash_from_id_or_name($name);
            }
        }
    }

    $self->data($data);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
