package MusicBrainz::Server::Edit::Recording::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );

extends 'MusicBrainz::Server::Edit::Generic::Merge';

sub edit_name { 'Merge recordings' }
sub edit_type { $EDIT_RECORDING_MERGE }
sub _merge_model { 'Recording' }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => {
            $self->data->{new_entity_id} => [ 'ArtistCredit' ],
            $self->data->{old_entity_id} => [ 'ArtistCredit' ],
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

