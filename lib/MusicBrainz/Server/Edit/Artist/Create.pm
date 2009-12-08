package MusicBrainz::Server::Edit::Artist::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE :expire_action :quality );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Utils qw( defined_hash );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_CREATE }
sub edit_name { "Create Artist" }

sub edit_conditions
{
    my $conditions = {
        duration      => 0,
        votes         => 0,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1,
    };
    return {
        $QUALITY_LOW    => $conditions,
        $QUALITY_NORMAL => $conditions,
        $QUALITY_HIGH   => $conditions,
    };
}

sub related_entities { return { artist => [ shift->artist_id ] } }

sub foreign_keys
{
    my $self = shift;
    return {
        ArtistType => [$self->data->{type_id}],
        Gender => [$self->data->{gender_id}],
        Country => [$self->data->{country_id}]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        ( map { $_ => $self->data->{$_} } qw( name sort_name comment ) ),
        type => $loaded->{ArtistType}->{$self->data->{type_id}},
        gender => $loaded->{Gender}->{$self->data->{gender_id}},
        country => $loaded->{Country}->{$self->data->{country_id}},
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date => PartialDate->new($self->data->{end_date}),
    };
}

sub models { [qw( Artist )] }

has 'artist_id' => (
    isa => 'Int',
    is  => 'rw'
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        name => Str,
        gid => Optional[Str],
        sort_name => Optional[Str],
        type_id => Optional[Int],
        gender_id => Optional[Int],
        country_id => Optional[Int],
        comment => Optional[Str],
        begin_date => Optional[PartialDateHash],
        end_date => Optional[PartialDateHash],
    ]
);

override 'accept' => sub
{
    my $self = shift;
    my %data = %{ $self->data };
    $data{sort_name} ||= $data{name};

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $self->c);
    my $artist = $artist_data->insert( \%data );

    $self->artist($artist);
    $self->artist_id($artist->id);
};

sub initialize
{
    my ($self, %args) = @_;
    $self->data({ defined_hash(%args) });
}

# artist_id is handled separately, as it should not be copied if the edit is cloned
# (a new different artist_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{artist_id} = $self->artist_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->artist_id(delete $hash->{artist_id});
};

__PACKAGE__->meta->make_immutable;

no Moose;

1;

