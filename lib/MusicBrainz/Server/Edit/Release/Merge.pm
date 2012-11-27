package MusicBrainz::Server::Edit::Release::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw ( N_l );

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Map );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities' => {
    -excludes => 'release_ids'
};
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';

has '+data' => (
    isa => Dict[
        new_entity => Dict[
            id   => Int,
            name => Str
        ],
        old_entities => ArrayRef[ Dict[
            name => Str,
            id   => Int
        ] ],
        merge_strategy => Int,
        _edit_version => Int,
        medium_changes => Nullable[
            ArrayRef[Dict[
                release => Dict[
                    id => Int,
                    name => Str
                ],
                mediums => ArrayRef[Dict[
                    id           => Int,
                    old_position => Str | Int,
                    new_position => Int,
                    old_name => Nullable[Str],
                    new_name => Nullable[Str],
                ]]
            ]]]
    ]
);

sub edit_name { N_l('Merge releases') }
sub edit_type { $EDIT_RELEASE_MERGE }
sub _merge_model { 'Release' }

sub release_ids { @{ shift->_entity_ids } }

sub related_recordings
{
    my ($self, $releases) = @_;

    if ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
        my @tracks;
        $self->c->model('Medium')->load_for_releases(@$releases);
        my @tracklists = map { $_->tracklist }
                         map { $_->all_mediums } @$releases;
        $self->c->model('Track')->load_for_tracklists(@tracklists);
        @tracks = map { $_->all_tracks } @tracklists;
        return $self->c->model('Recording')->load(@tracks);
    } else {
        return ();
    }
}

sub foreign_keys
{
    my $self = shift;
    my $fks = {
        Release => {
            $self->data->{new_entity}{id} => [ 'ArtistCredit' ],
            map {
                $_->{id} => [ 'ArtistCredit' ]
            } @{ $self->data->{old_entities} }
        }
    };

    return $fks;
}

sub initialize {
    my ($self, %opts) = @_;
    $opts{_edit_version} = 3;
    $self->data(\%opts);
}

override build_display_data => sub
{
    my ($self, $loaded) = @_;
    my $data = super();

    if ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
        $data->{changes} = [
            map +{
                release => $loaded->{Release}{ $_->{release}{id} }
                    || Release->new( name => $_->{release}{name} ),
                mediums => $_->{mediums}
            }, @{ $self->data->{medium_changes} }
        ];
    }

    return $data;
};

sub do_merge
{
    my $self = shift;
    my $medium_names;
    if ($self->data->{_edit_version} > 2) {
        $medium_names = {
            map { $_->{id} => $_->{new_name} }
            map { @{ $_->{mediums} } }
            @{ $self->data->{medium_changes} }
        };
    }

    my %opts = (
        new_id => $self->new_entity->{id},
        old_ids => [ $self->_old_ids ],
        merge_strategy => $self->data->{merge_strategy},
        medium_positions => {
            map { $_->{id} => $_->{new_position} }
            map { @{ $_->{mediums} } }
            @{ $self->data->{medium_changes} }
        },
        medium_names => $medium_names
    );

    if (!$self->c->model('Release')->can_merge(%opts)) {
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
            'These releases could not be merged'
        );
    }

    $self->c->model('Release')->merge(%opts);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

