package MusicBrainz::Server::Edit::ReleaseGroup::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    partial_date_to_hash
);
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    changed_relations
    changed_display_data
    load_artist_credit_definitions
);
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( ArrayRef Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

sub edit_type { $EDIT_RELEASEGROUP_EDIT }
sub edit_name { l("Edit release group") }
sub _edit_model { 'ReleaseGroup' }
sub release_group_id { shift->data->{entity}{id} }

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
    return Dict[
        name => Optional[Str],
        type_id => Nullable[Int],
        artist_credit => Optional[ArtistCreditDefinition],
        comment => Nullable[Str],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        new => change_fields(),
        old => change_fields()
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        ReleaseGroupType => 'type_id',
    );

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    $relations->{ReleaseGroup} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name    => 'name',
        comment => 'comment',
        type    => [ qw( type_id ReleaseGroupType ) ],
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    $data->{release_group} = $loaded->{ReleaseGroup}{
        $self->data->{entity}{id}
    } || ReleaseGroup->new( name => $self->data->{entity}{name} );

    return $data;
}

sub _mapping
{
    my $for_change_hash = 1;

    return (
        artist_credit => sub {
            return artist_credit_to_ref(shift->artist_credit, $for_change_hash);
        }
    );
}

before 'initialize' => sub
{
    my ($self, %opts) = @_;
    my $release_group = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$release_group->artist_credit) {
        $self->c->model('ArtistCredit')->load($release_group);
    }
};

sub _edit_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit})
        if (exists $data->{artist_credit});
    return $data;
}

sub _xml_arguments { ForceArray => ['artist_credit'] }

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if defined $self->data->{old}{type_id};

    return 0 if exists $self->data->{new}{artist_credit};

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
