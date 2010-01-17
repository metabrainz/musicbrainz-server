package MusicBrainz::Server::Edit::Artist::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
);

use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::Generic::Edit';

sub edit_type { $EDIT_ARTIST_EDIT }
sub edit_name { "Edit artist" }
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
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
    ];
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
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
        comment    => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
