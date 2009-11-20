package MusicBrainz::Server::Edit::Release::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( subtype as find_type_constraint );
use MooseX::Types::Moose qw( Int Str Maybe );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    partial_date_to_hash
    partial_date_from_row
);
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_RELEASE_EDIT }
sub edit_name { 'Edit Release' }

sub related_entities { { release => [ shift->data->{release} ] } }
sub alter_edit_pending { { Release => [ shift->data->{release} ] } }

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

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
        ReleasePackaging => 'packaging_id',
        ReleaseStatus    => 'status_id',
        ReleaseGroup     => 'release_group_id',
        Country          => 'country_id',
        Language         => 'language_id',
        Script           => 'script_id',
    ));

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        packaging => [ qw( packaging_id ReleasePackaging )],
        status    => [ qw( status_id ReleaseStatus )],
        group     => [ qw( release_group_id ReleaseGroup )],
        country   => [ qw( country_id Country )],
        language  => [ qw( language_id Language )],
        script    => [ qw( script_id Script )],
        name      => 'name',
        barcode   => 'barcode',
        comment   => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    if (exists $self->data->{new}{date}) {
        $data->{date} = {
            new => partial_date_from_row($self->data->{new}{date}),
            old => partial_date_from_row($self->data->{old}{date}),
        };
    }

    return $data;
}

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

    $self->data({
        release => $release->id,
        $self->_change_data($release, %opts)
    });
}

override 'accept' => sub
{
    my ($self) = @_;
    my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $self->c);
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);

    my %data = %{ $self->data->{new} };
    $data{artist_credit} = $ac_data->find_or_insert(@{ $data{artist_credit} });

    $release_data->update($self->data->{release}, \%data);
};

sub _xml_arguments { return ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
