package MusicBrainz::Server::Edit::Place::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_MERGE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Place';

sub edit_type { $EDIT_PLACE_MERGE }
sub edit_name { N_l('Merge places') }
sub place_ids { @{ shift->_entity_ids } }

sub _merge_model { 'Place' }

sub foreign_keys
{
    my $self = shift;
    return {
        Place => {
            map {
                $_ => [ 'PlaceType' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

sub edit_template { 'MergePlaces' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
