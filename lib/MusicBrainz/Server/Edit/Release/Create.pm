package MusicBrainz::Server::Edit::Release::Create;
use Carp;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use aliased 'MusicBrainz::Server::Entity::Barcode';
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CREATE );
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    NullableOnPreview
    PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_preview
    verify_artist_credits
);
use MusicBrainz::Server::Entity::ReleaseEvent;
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

sub edit_name { N_l('Add release') }
sub edit_type { $EDIT_RELEASE_CREATE }
sub _create_model { 'Release' }
sub release_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name             => Str,
        artist_credit    => ArtistCreditDefinition,
        release_group_id => NullableOnPreview[Int],
        comment          => Nullable[Str],

        barcode          => Nullable[Str],
        language_id      => Nullable[Int],
        packaging_id     => Nullable[Int],
        script_id        => Nullable[Int],
        status_id        => Nullable[Int],

        events => Optional[ArrayRef[Dict[
            date => Nullable[PartialDateHash],
            country_id => Nullable[Int],
        ]]]
    ]
);

after 'initialize' => sub {
    my $self = shift;

    return if $self->preview;

    croak "No release_group_id specified" unless $self->data->{release_group_id};
};

sub foreign_keys
{
    my $self = shift;
    my $fks = {
        Artist           => { load_artist_credit_definitions($self->data->{artist_credit}) },
        Area             => [ map { $_->{country_id} } @{ $self->data->{events} } ],
        ReleaseStatus    => [ $self->data->{status_id} ],
        ReleasePackaging => [ $self->data->{packaging_id} ],
        Script           => [ $self->data->{script_id} ],
        Language         => [ $self->data->{language_id} ],
    };

    $fks->{ReleaseGroup} = { $self->data->{release_group_id} => [ 'ArtistCredit' ] }
        if $self->data->{release_group_id};

    unless ($self->preview) {
        $fks->{Release} = { $self->entity_id => [ 'ArtistCredit' ] };
    }

    return $fks;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $status = $self->data->{status_id};
    my $script = $self->data->{script_id};
    my $lang = $self->data->{language_id};

    $self->c->model('Area')->load_codes(map { $loaded->{Area}->{ $_->{country_id} } } @{ $self->data->{events} });

    return {
        artist_credit => artist_credit_preview ($loaded, $self->data->{artist_credit}),
        name          => $self->data->{name} || '',
        comment       => $self->data->{comment} || '',
        packaging     => defined($self->data->{packaging_id}) &&
                           $loaded->{ReleasePackaging}{ $self->data->{packaging_id} },
        status        => defined($status) &&
                           $loaded->{ReleaseStatus}->{ $status },
        script        => defined($script) &&
                           $loaded->{Script}{ $script },
        language      => defined($lang) &&
                           $loaded->{Language}{ $lang },
        barcode       => Barcode->new ($self->data->{barcode}),
        release_group => (defined($self->data->{release_group_id}) &&
                           $loaded->{ReleaseGroup}{ $self->data->{release_group_id} }) ||
                               ReleaseGroup->new( name => '[removed]' ),
        release       => (defined($self->entity_id) &&
                              $loaded->{Release}{ $self->entity_id }) ||
                                  Release->new( name => $self->data->{name} ),
        events => [
            map {
                MusicBrainz::Server::Entity::ReleaseEvent->new(
                    country => defined($_->{country_id})
                        ? $loaded->{Area}{ $_->{country_id} }
                        : undef,
                    date => PartialDate->new({
                        year => $_->{date}{year},
                        month => $_->{date}{month},
                        day => $_->{date}{day}
                    })
                )
            } @{ $self->data->{events} }
        ]
    };
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    return $data
}

sub restore {
    my ($self, $data) = @_;

    $self->entity_id(delete $data->{entity_id})
        if $data->{entity_id};

    if (exists $data->{date} || exists $data->{country_id}) {
        $data->{events} = [{
            exists $data->{date}
                ? (date => delete $data->{date}) : (),

            exists $data->{country_id}
                ? (country_id => delete $data->{country_id}) : ()
        }]
    }

    $self->data($data);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
