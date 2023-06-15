package MusicBrainz::Server::Edit::Area::Create;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_CREATE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Area';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_name { N_l('Add area') }
sub edit_type { $EDIT_AREA_CREATE }
sub _create_model { 'Area' }
sub area_id { shift->entity_id }


has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        sort_name  => Optional[Str],
        comment    => Nullable[Str],
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
    die 'You must specify iso_3166_1' unless defined $opts{iso_3166_1};
    die 'You must specify iso_3166_2' unless defined $opts{iso_3166_2};
    die 'You must specify iso_3166_3' unless defined $opts{iso_3166_3};
};

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name sort_name ) ),
        comment    => $self->data->{comment},
        type       => $type ? to_json_object($loaded->{AreaType}{$type}) : undef,
        begin_date => to_json_object(PartialDate->new($self->data->{begin_date})),
        end_date   => to_json_object(PartialDate->new($self->data->{end_date})),
        area       => to_json_object((defined($self->entity_id) &&
            $loaded->{Area}{ $self->entity_id }) ||
            Area->new( name => $self->data->{name} )
        ),
        ended      => boolean_to_json($self->data->{ended}),
        iso_3166_1 => @{ $self->data->{iso_3166_1} } ? $self->data->{iso_3166_1} : undef,
        iso_3166_2 => @{ $self->data->{iso_3166_2} } ? $self->data->{iso_3166_2} : undef,
        iso_3166_3 => @{ $self->data->{iso_3166_3} } ? $self->data->{iso_3166_3} : undef,
    };
}

sub edit_template { 'AddArea' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
