package MusicBrainz::Server::Edit::Artist::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_EDIT }
sub edit_name { "Create Artist" }

sub related_entities { { artist => [ shift->artist_id ] } }
sub alter_edit_pending { { Artist => [ shift->artist_id ] } }
sub models { [qw( Artist )] }

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{artist} }
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw'
);

subtype 'ArtistHash'
    => as Dict[
        name => Optional[Str],
        sort_name => Optional[Str],
        type_id => Nullable[Int],
        gender_id => Nullable[Int],
        country_id => Nullable[Int],
        comment => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
    ];

has '+data' => (
    isa => Dict[
        artist => Int,
        new => find_type_constraint('ArtistHash'),
        old => find_type_constraint('ArtistHash'),
    ]
);

sub _date_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return partial_date_to_hash($a->$attr); 
    };
}

sub _mapping
{
    return (
        begin_date => _date_closure('begin_date'),
        end_date => _date_closure('end_date'),
    );
}

sub initialize
{
    my ($self, %opts) = @_;
    my $artist = delete $opts{artist};
    die "You must specify the artist object to edit" unless defined $artist;

    $self->artist($artist);
    $self->data({
        old => $self->_change_hash($artist, keys %opts),
        new => { %opts },
        artist => $artist->id
    });
};

override 'accept' => sub
{
    my $self = shift;
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $self->c);
    $artist_data->update($self->artist_id, $self->data->{new});
};

__PACKAGE__->meta->make_immutable;
__PACKAGE__->register_type;

no Moose;
1;
