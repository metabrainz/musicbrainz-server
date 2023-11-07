package MusicBrainz::Server::Edit::Release::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETE );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities',
     'MusicBrainz::Server::Edit::Release';

sub edit_type { $EDIT_RELEASE_DELETE }
sub edit_name { N_lp('Remove release', 'edit name') }
sub _delete_model { 'Release' }
sub release_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{Release} = {
        $self->release_id => [ 'ArtistCredit' ],
    };
    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

