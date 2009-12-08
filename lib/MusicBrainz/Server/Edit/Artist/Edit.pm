package MusicBrainz::Server::Edit::Artist::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Edit::Utils qw( date_closure );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
);

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_ARTIST_EDIT }
sub edit_name { "Edit Artist" }

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

sub initialize
{
    my ($self, %opts) = @_;
    my $artist = delete $opts{artist};
    die "You must specify the artist object to edit" unless defined $artist;

    $self->artist($artist);
    $self->data({
        artist => $artist->id,
        $self->_change_data($artist, %opts)
    });
};

override 'accept' => sub
{
    my $self = shift;
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $self->c);
    $artist_data->update($self->artist_id, $self->data->{new});
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;
