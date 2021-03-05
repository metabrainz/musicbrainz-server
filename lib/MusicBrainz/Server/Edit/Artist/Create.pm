package MusicBrainz::Server::Edit::Artist::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Artist';
with 'MusicBrainz::Server::Edit::Role::SubscribeOnCreation' => {
    editor_subscription_preference => sub { shift->subscribe_to_created_artists }
};
with 'MusicBrainz::Server::Edit::Role::Insert';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_name { N_l('Add artist') }
sub edit_type { $EDIT_ARTIST_CREATE }
sub _create_model { 'Artist' }
sub artist_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        gender_id  => Nullable[Int],
        area_id    => Nullable[Int],
        begin_area_id => Nullable[Int],
        end_area_id => Nullable[Int],
        comment    => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ipi_codes  => Optional[ArrayRef[Str]],
        isni_codes => Optional[ArrayRef[Str]],
        ended      => Optional[Bool]
    ]
);

before initialize => sub {
    my ($self, %opts) = @_;
    die "You must specify ipi_codes" unless defined $opts{ipi_codes};
    die "You must specify isni_codes" unless defined $opts{isni_codes};
};

around initialize => sub {
    my ($orig, $self, %opts) = @_;

    $opts{ended} = 1 if $opts{end_area_id};

    $self->$orig(%opts);
};

sub foreign_keys
{
    my $self = shift;
    return {
        Artist     => [ $self->entity_id ],
        ArtistType => [ $self->data->{type_id} ],
        Gender     => [ $self->data->{gender_id} ],
        Area       => [ $self->data->{area_id},
                        $self->data->{begin_area_id}, $self->data->{end_area_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};
    my $gender = $self->data->{gender_id};
    my $artist = to_json_object(
        ($self->entity_id && $loaded->{Artist}{ $self->entity_id }) ||
        Artist->new( name => $self->data->{name} )
    );

    return {
        ( map { $_ => $self->data->{$_} // '' } qw( name sort_name comment ) ),
        type       => $type ? to_json_object($loaded->{ArtistType}{$type}) : undef,
        gender     => $gender ? to_json_object($loaded->{Gender}{$gender}) : undef,
        ( map { $_ => $self->data->{$_ . '_id'} && to_json_object($loaded->{Area}{$self->data->{$_ . '_id'}} // Area->new()) } qw( area begin_area end_area ) ),
        begin_date => to_json_object(PartialDate->new($self->data->{begin_date})),
        end_date   => to_json_object(PartialDate->new($self->data->{end_date})),
        artist     => $artist,
        ipi_codes  => $self->data->{ipi_codes},
        isni_codes => $self->data->{isni_codes},
        ended      => boolean_to_json($self->data->{ended})
    };
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{sort_name} ||= $data->{name};
    return $data;
};

sub restore {
    my ($self, $data) = @_;

    $data->{area_id} = delete $data->{country_id}
        if exists $data->{country_id};

    $data->{ipi_codes} = [ delete $data->{ipi_code} // () ]
        if exists $data->{ipi_code};

    $self->data($data);
}

sub edit_template_react { 'AddArtist' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
