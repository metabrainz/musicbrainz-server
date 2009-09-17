package MusicBrainz::Server::Edit::ReleaseGroup::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    partial_date_to_hash
);
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( ArrayRef Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_RELEASEGROUP_EDIT }
sub edit_name { "Edit ReleaseGroup" }

sub related_entities { { release_group => [ shift->release_group_id ] } }
sub alter_edit_pending { { ReleaseGroup => [ shift->release_group_id ] } }
sub models { [qw( ReleaseGroup )] }

has 'release_group_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_group} }
);

has 'release_group' => (
    isa => 'ReleaseGroup',
    is => 'rw'
);

subtype 'ReleaseGroupHash'
    => as Dict[
        name => Optional[Str],
        type_id => Nullable[Int],
        artist_credit => Optional[ArtistCreditDefinition],
        comment => Nullable[Str],
    ];

has '+data' => (
    isa => Dict[
        release_group => Int,
        new => find_type_constraint('ReleaseGroupHash'),
        old => find_type_constraint('ReleaseGroupHash'),
    ]
);

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) }
    );
}

sub initialize
{
    my ($self, %args) = @_;
    my $release_group = delete $args{release_group};
    die "You must specify the release group object to edit" unless defined $release_group;

    if (!$release_group->artist_credit_loaded)
    {
        my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $self->c);
        $ac_data->load($release_group);
    }

    $self->release_group($release_group);
    $self->data({
        old => $self->_change_hash($release_group, keys %args),
        new => \%args,
        release_group => $release_group->id
    });
};

override 'accept' => sub
{
    my $self = shift;
    my $release_group_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $self->c);
    my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $self->c);

    my %data = %{ $self->data->{new} };
    $data{artist_credit} = $ac_data->find_or_insert(@{ $data{artist_credit} });
    $release_group_data->update($self->release_group_id, \%data);
};

sub _xml_arguments { ForceArray => ['artist_credit'] }

__PACKAGE__->meta->make_immutable;

no Moose;
1;
