package MusicBrainz::Server::Edit::Work::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_MERGE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

sub edit_type { $EDIT_WORK_MERGE }
sub edit_name { l("Merge works") }
sub work_ids { @{ shift->_entity_ids } }

sub _merge_model { 'Work' }

sub foreign_keys
{
    my $self = shift;
    return {
        Work => {
            $self->data->{new_entity}{id} => [ 'ArtistCredit' ],
            map {
                $_->{id} => [ 'ArtistCredit' ]
            } @{ $self->data->{old_entities} }
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
