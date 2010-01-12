package MusicBrainz::Server::Edit::ReleaseGroup::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Create release group' }
sub edit_type { $EDIT_RELEASEGROUP_CREATE }

sub related_entities { { release_group => [ shift->release_group_id ] } }
sub alter_edit_pending { { ReleaseGroup => [ shift->release_group_id ] } }

has '+data' => (
    isa => Dict[
        type_id => Nullable[Int],
        name => Str,
        artist_credit => ArtistCreditDefinition,
        comment => Nullable[Str]
    ]
);

has 'release_group' => (
    is => 'rw',
);

has 'release_group_id' => (
    isa => Int,
    is => 'rw'
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => { load_artist_credit_definitions($self->data->{artist_credit}) },
        ReleaseGroupType => [ $self->data->{type_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        name => $self->data->{name},
        comment => $self->data->{comment},
        type => $loaded->{ReleaseGroupType}->{ $self->data->{type_id} }
    };
}

sub insert
{
    my $self = shift;
    my %data = %{ $self->data };

    $data{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $data{artist_credit} });

    my $rg = $self->c->model('ReleaseGroup')->insert(\%data);
    $self->release_group($rg);
    $self->release_group_id($rg->id);
}

sub reject
{
    my $self = shift;
    $self->c->model('ReleaseGroup')->delete($self->release_group_id);
}

# release_group_id is handled separately, as it should not be copied if the edit is cloned
# (a new different release_group_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{release_group_id} = $self->release_group_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->release_group_id(delete $hash->{release_group_id});
};

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
