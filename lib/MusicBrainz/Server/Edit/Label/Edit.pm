package MusicBrainz::Server::Edit::Label::Edit;
use Moose;

use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash Nullable );
use MusicBrainz::Server::Edit::Utils qw( date_closure changed_relations changed_display_data );
use MusicBrainz::Server::Validation qw( normalise_strings );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Label';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

use aliased 'MusicBrainz::Server::Entity::Label';

sub edit_type { $EDIT_LABEL_EDIT }
sub edit_name { l('Edit label') }
sub _edit_model { 'Label' }
sub label_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        label_code => Nullable[Int],
        country_id => Nullable[Int],
        comment    => Nullable[Str],
        ipi_code   => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
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
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        LabelType => 'type_id',
        Country   => 'country_id',
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
        ipi_code   => 'ipi_code',
        country    => [ qw( country_id Country ) ],
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    for my $period (qw( begin end )) {
        my $field = $period . '_date';
        if (exists $self->data->{new}{$field}) {
            $data->{$field} = {
                new => partial_date_from_row($self->data->{new}{$field}),
                old => partial_date_from_row($self->data->{old}{$field}),
            };
        }
    }

    $data->{label} = $loaded->{Label}{ $self->data->{entity}{id} }
        || Label->new( name => $self->data->{entity}{name} );

    return $data;
}

sub _mapping
{
    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
    );
}

sub allow_auto_edit
{
    my ($self) = @_;

    # Changing name or sortname is allowed if the change only affects
    # small things like case etc.
    my ($old_name, $new_name) = normalise_strings(
        $self->data->{old}{name}, $self->data->{new}{name});
    my ($old_sort_name, $new_sort_name) = normalise_strings(
        $self->data->{old}{sort_name}, $self->data->{new}{sort_name});
    my ($old_label_code, $new_label_code) = normalise_strings(
        $self->data->{old}{label_code}, $self->data->{new}{label_code});

    return 0 if $old_name ne $new_name;
    return 0 if $old_sort_name ne $new_sort_name;
    return 0 if $self->data->{old}{label_code} &&
        $old_label_code ne $new_label_code;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if defined $self->data->{old}{country_id};

    # Adding a date is automatic if there was no date yet.
    return 0 if exists $self->data->{old}{begin_date}
        and partial_date_from_row($self->data->{old}{begin_date})->format ne '';
    return 0 if exists $self->data->{old}{end_date}
        and partial_date_from_row($self->data->{old}{end_date})->format ne '';

    return 0 if exists $self->data->{old}{type_id}
        and $self->data->{old}{type_id} != 0;

    if ($self->data->{old}{ipi_code}) {
        my ($old_ipi, $new_ipi) = normalise_strings($self->data->{old}{ipi_code},
                                                    $self->data->{new}{ipi_code});
        return 0 if $new_ipi ne $old_ipi;
    }

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->c->model('Label')->get_by_id($self->entity_id),
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
