package MusicBrainz::Server::Edit::Release::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( subtype as find_type_constraint );
use MooseX::Types::Moose qw( Int Str Maybe );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref partial_date_to_hash );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable PartialDateHash );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_RELEASE_EDIT }
sub edit_name { 'Edit Release '}

sub related_entities { { release => [ shift->release_id ] } }
sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub models { [qw( Release )] }

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release} }
);

has 'release' => (
    is => 'rw',
);

subtype 'ReleaseHash'
    => as Dict[
        name => Optional[Str],
        packaging_id => Nullable[Int],
        status_id => Nullable[Int],
        release_group_id => Optional[Int],
        barcode => Nullable[Str],
        country_id => Nullable[Int],
        date => Nullable[PartialDateHash],
        language_id => Nullable[Int],
        script_id => Nullable[Int],
        comment => Optional[Maybe[Str]],
        artist_credit => Optional[ArtistCreditDefinition]
    ];

has '+data' => (
    isa => Dict[
        release => Int,
        new => find_type_constraint('ReleaseHash'),
        old => find_type_constraint('ReleaseHash'),
    ]
);

sub _mapping
{
    return (
        date => sub { partial_date_to_hash(shift->date) },
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) }
    );
}

sub initialize
{
    my ($self, %opts) = @_;
    my $release = delete $opts{release};
    die "You must specify the release object to edit" unless defined $release;

    if (!$release->artist_credit_loaded)
    {
        my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $self->c);
        $ac_data->load($release);
    }

    $self->release($release);
    $self->data({
        old => $self->_change_hash($release, keys %opts),
        new => \%opts,
        release => $release->id,
    });
};

override 'accept' => sub
{
    my ($self) = @_;
    my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $self->c);
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);

    my %data = %{ $self->data->{new} };
    $data{artist_credit} = $ac_data->find_or_insert(@{ $data{artist_credit} });

    $release_data->update($self->release_id, \%data);
};

sub _xml_arguments { return ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
