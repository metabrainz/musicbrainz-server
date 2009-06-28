package MusicBrainz::Server::Edit::Artist::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Types qw( :edit_status );
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_CREATE }
sub edit_name { "Create Artist" }
sub edit_auto_edit { 1 }
sub entity_model { 'Artist' }
sub entity_id { shift->artist_id }

has 'artist_id' => (
    isa => 'Int',
    is  => 'rw'
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw'
);

sub entities
{
    my $self = shift;
    return {
        artist => [ $self->artist_id ],
    };
}

has '+data' => (
    isa => Dict[
        name => Str,
        gid => Optional[Str],
        sort_name => Optional[Str],
        type_id => Optional[Int],
        gender_id => Optional[Int],
        country_id => Optional[Int],
        comment => Optional[Str],
        begin_date => Optional[Dict[
            year => Int,
            month => Optional[Int],
            day => Optional[Int],
        ]],
        end_date => Optional[Dict[
            year => Int,
            month => Optional[Int],
            day => Optional[Int],
        ]],
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
__PACKAGE__->register_type;

no Moose;

1;

