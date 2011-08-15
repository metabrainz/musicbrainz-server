package MusicBrainz::Server::Edit::Artist::Split;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

use aliased 'MusicBrainz::Server::Entity::Artist';
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_SPLIT );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    verify_artist_credits
);
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { l('Split artist') }
sub edit_type { $EDIT_ARTIST_SPLIT }

sub alter_edit_pending
{
    my $self = shift;
    return {
        Artist => [ $self->data->{entity}{id} ]
    }
}


sub _build_related_entities {
    my ($self) = @_;

    my $related = {
        artist => [ $self->data->{entity}{id} ]
    };

    my %ac = load_artist_credit_definitions($self->data->{artist_credit});
    push @{ $related->{artist} }, keys(%ac);

    return $related;
};

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        artist_credit => ArtistCreditDefinition
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};

    $relations->{Artist} = {
        $self->data->{entity}{id} => [],
        load_artist_credit_definitions($self->data->{artist_credit})
    };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = {
        artist => $loaded->{Artist}{ $self->data->{entity}{id} } ||
            Artist->new( name => $self->data->{entity}{id} ),
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
    };

    return $data;
}

sub initialize {
    my ($self, %opts) = @_;
    my $artist = delete $opts{artist} or die 'Missing artist object';

    $opts{entity} = {
        id => $artist->id,
        name => $artist->name
    };

    $self->data(\%opts);
}

sub accept {
    my $self = shift;

    my $artist = $self->c->model('Artist')->get_by_id(
        $self->data->{entity}{id});

    verify_artist_credits($self->c, $self->data->{artist_credit});

    $self->c->model('ArtistCredit')->decompose_artist_to_credits(
        $artist->id,
        $self->data->{artist_credit}
    );
}

1;
