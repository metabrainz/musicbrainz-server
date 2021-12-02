package MusicBrainz::Server::Edit::ReleaseGroup::Create;
use Moose;

use List::AllUtils qw( any );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Historic::Utils qw( get_historic_type );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_preview
    verify_artist_credits
    clean_submitted_artist_credits
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use Scalar::Util qw( looks_like_number );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::ReleaseGroup';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

sub edit_name { N_l('Add release group') }
sub edit_type { $EDIT_RELEASEGROUP_CREATE }
sub _create_model { 'ReleaseGroup' }
sub release_group_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        type_id       => Nullable[Int],
        name          => Str,
        artist_credit => ArtistCreditDefinition,
        comment       => Nullable[Str],
        secondary_type_ids => Optional[ArrayRef[Int]]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist           => { load_artist_credit_definitions($self->data->{artist_credit}) },
        ReleaseGroup     => [ $self->entity_id ],
        ReleaseGroupType => [ $self->data->{type_id} ],
        ReleaseGroupSecondaryType => $self->data->{secondary_type_ids}
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        artist_credit => to_json_object(artist_credit_preview($loaded, $self->data->{artist_credit})),
        name          => $self->data->{name} || '',
        comment       => $self->data->{comment} || '',
        # Older edits store historic (pre-split) "secondary" types
        type          => get_historic_type($type, $loaded),
        release_group => to_json_object((defined($self->entity_id) &&
                              $loaded->{ReleaseGroup}{ $self->entity_id }) ||
                                  ReleaseGroup->new( name => $self->data->{name} )),
        secondary_types => join(' + ', map { $loaded->{ReleaseGroupSecondaryType}{$_}->l_name }
                                    @{ $self->data->{secondary_type_ids} })
    };
}

sub initialize {
    my ($self, %opts) = @_;
    $opts{type_id} = delete $opts{primary_type_id};

    delete $opts{secondary_type_ids}
        unless any { looks_like_number($_) } @{ $opts{secondary_type_ids} // [] };

    $opts{artist_credit} = clean_submitted_artist_credits($opts{artist_credit});

    $self->data(\%opts);
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    $data->{primary_type_id} = delete $data->{type_id};
    $data->{comment} = '' unless defined $data->{comment};
    return $data;
}

sub edit_template_react { 'AddReleaseGroup' }

before accept => sub {
    my ($self) = @_;

    verify_artist_credits($self->c, $self->data->{artist_credit});
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
