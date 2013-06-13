package MusicBrainz::Server::Edit::Area::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw ( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Area';

sub edit_name { N_l('Add area') }
sub edit_type { $EDIT_AREA_CREATE }
sub _create_model { 'Area' }
sub area_id { shift->entity_id }


has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ended      => Optional[Bool],
        iso_3166_1  => Optional[ArrayRef[Str]],
        iso_3166_2  => Optional[ArrayRef[Str]],
        iso_3166_3  => Optional[ArrayRef[Str]],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Area       => [ $self->entity_id ],
        AreaType   => [ $self->data->{type_id} ],
    };
}

before initialize => sub {
    my ($self, %opts) = @_;
    die "You must specify iso_3166_1" unless defined $opts{iso_3166_1};
    die "You must specify iso_3166_2" unless defined $opts{iso_3166_2};
    die "You must specify iso_3166_3" unless defined $opts{iso_3166_3};
};

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name sort_name ) ),
        type       => $type ? $loaded->{AreaType}->{$type} : '',
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date   => PartialDate->new($self->data->{end_date}),
        area       => ($self->entity_id && $loaded->{Area}->{ $self->entity_id }) ||
            Area->new( name => $self->data->{name} ),
        ended      => $self->data->{ended} // 0,
        iso_3166_1 => @{ $self->data->{iso_3166_1} } ? $self->data->{iso_3166_1} : undef,
        iso_3166_2 => @{ $self->data->{iso_3166_2} } ? $self->data->{iso_3166_2} : undef,
        iso_3166_3 => @{ $self->data->{iso_3166_3} } ? $self->data->{iso_3166_3} : undef,
    };
}

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
