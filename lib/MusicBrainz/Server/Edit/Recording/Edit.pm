package MusicBrainz::Server::Edit::Recording::Edit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';

use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_type { $EDIT_RECORDING_EDIT }
sub edit_name { l('Edit recording') }
sub _edit_model { 'Recording' }
sub recording_id { return shift->entity_id }

around related_entities => sub {
    my ($orig, $self, @args) = @_;
    my %rel = %{ $self->$orig(@args) };
    if ($self->data->{new}{artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new}{artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old}{artist_credit});
        push @{ $rel{artist} }, keys(%new), keys(%old);
    }

    return \%rel;
};

sub change_fields
{
    Dict[
        name          => Optional[Str],
        artist_credit => Optional[ArtistCreditDefinition],
        length        => Nullable[Int],
        comment       => Nullable[Str]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        old => change_fields(),
        new => change_fields(),
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations);

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    $relations->{Recording} = { $self->data->{entity}{id} => [ 'ArtistCredit' ] };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name    => 'name',
        comment => 'comment',
        length  => 'length',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    $data->{recording} = $loaded->{Recording}{ $self->data->{entity}{id} }
        || Recording->new( name => $self->data->{entity}{name} );

    return $data;
}

before 'initialize' => sub
{
    my ($self, %opts) = @_;
    my $recording = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$recording->artist_credit) {
        $self->c->model('ArtistCredit')->load($recording);
    }

    if (exists $opts{length}) {
        delete $opts{length}
            if MusicBrainz::Server::Track::FormatTrackLength($opts{length}) eq
                MusicBrainz::Server::Track::FormatTrackLength($recording->length);
    }
};

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) },
    );
}

sub _edit_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit})
        if (exists $data->{artist_credit});
    return $data;
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if $self->data->{old}{length};
    return 0 if exists $self->data->{new}{comment};
    return 0 if exists $self->data->{new}{artist_credit};

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
