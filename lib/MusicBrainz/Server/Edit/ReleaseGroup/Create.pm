package MusicBrainz::Server::Edit::ReleaseGroup::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_preview
);
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

sub edit_name { l('Add release group') }
sub edit_type { $EDIT_RELEASEGROUP_CREATE }
sub _create_model { 'ReleaseGroup' }
sub release_group_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        type_id       => Nullable[Int],
        name          => Str,
        artist_credit => ArtistCreditDefinition,
        comment       => Nullable[Str]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist           => { load_artist_credit_definitions($self->data->{artist_credit}) },
        ReleaseGroup     => [ $self->entity_id ],
        ReleaseGroupType => [ $self->data->{type_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        artist_credit => artist_credit_preview ($loaded, $self->data->{artist_credit}),
        name          => $self->data->{name} || '',
        comment       => $self->data->{comment} || '',
        type          => $type ? $loaded->{ReleaseGroupType}->{ $type } : '',
        release_group => $loaded->{ReleaseGroup}{ $self->entity_id }
            || ReleaseGroup->new( name => $self->data->{name} )
    };
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    return $data
}

sub allow_auto_edit { 1 }


__PACKAGE__->meta->make_immutable;
no Moose;

1;
