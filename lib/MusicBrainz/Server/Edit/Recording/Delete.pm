package MusicBrainz::Server::Edit::Recording::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_DELETE );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Recording',
     'MusicBrainz::Server::Edit::Recording::RelatedEntities';

sub edit_type { $EDIT_RECORDING_DELETE }
sub edit_name { N_lp('Remove recording', 'edit type') }
sub _delete_model { 'Recording' }
sub recording_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{Recording} = {
        $self->recording_id => [ 'ArtistCredit' ],
    };
    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

