package MusicBrainz::Server::Edit::Release::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Map );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities' => {
    -excludes => 'release_ids'
};
with 'MusicBrainz::Server::Edit::Release';

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
        medium_positions => Nullable[Map[ Int, Int ]]
    ]
);

sub edit_name { l('Merge releases') }
sub edit_type { $EDIT_RELEASE_MERGE }
sub _merge_model { 'Release' }

sub release_ids { @{ shift->_entity_ids } }

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            $self->data->{new_entity}{id} => [ 'ArtistCredit' ],
            map {
                $_->{id} => [ 'ArtistCredit' ]
            } @{ $self->data->{old_entities} }
        }
    }
}

sub do_merge
{
    my $self = shift;
    $self->c->model('Release')->merge(
        new_id => $self->new_entity->{id},
        old_ids => [ $self->_old_ids ],
        merge_strategy => $self->data->{merge_strategy},
        medium_positions => $self->data->{medium_positions}
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

