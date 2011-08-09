package MusicBrainz::Server::Edit::Artist::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
);
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { l('Edit artist') }
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
        and $self->data->{old}{type_id} != 0;

    return 0 if exists $self->data->{old}{gender_id}
        and $self->data->{old}{gender_id} != 0;

    return 0 if exists $self->data->{old}{country_id}
        and $self->data->{old}{country_id} != 0;

    if ($self->data->{old}{ipi_code}) {
        my ($old_ipi, $new_ipi) = normalise_strings($self->data->{old}{ipi_code},
                                                    $self->data->{new}{ipi_code});
        return 0 if $new_ipi ne $old_ipi;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
