package MusicBrainz::Server::Edit::Artist::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw ( l ln );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { l('Add artist') }
sub edit_type { $EDIT_ARTIST_CREATE }
sub _create_model { 'Artist' }
sub artist_id { shift->entity_id }

sub foreign_keys
{
    my $self = shift;
    return {
        Artist     => [ $self->entity_id ],
        ArtistType => [ $self->data->{type_id} ],
        Gender     => [ $self->data->{gender_id} ],
        Country    => [ $self->data->{country_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};
    my $gender = $self->data->{gender_id};
    my $country = $self->data->{country_id};

    return {
        ( map { $_ => $self->data->{$_} || '' } qw( name sort_name comment ipi_code ) ),
        type       => $type ? $loaded->{ArtistType}->{$type} : '',
        gender     => $gender ? $loaded->{Gender}->{$gender} : '',
        country    => $country ? $loaded->{Country}->{$country} : '',
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date   => PartialDate->new($self->data->{end_date}),
        artist     => $loaded->{Artist}->{ $self->entity_id } ||
            Artist->new( name => $self->data->{name} )
    };
}

has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        gender_id  => Nullable[Int],
        country_id => Nullable[Int],
        comment    => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ipi_code   => Nullable[Str],
    ]
);

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{sort_name} ||= $data->{name};
    return $data;
};

sub allow_auto_edit { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
