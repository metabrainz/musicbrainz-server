package MusicBrainz::Server::Edit::Artist::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Artist',
    edit_name => N_lp('Add artist annotation', 'edit name'),
    edit_type => $EDIT_ARTIST_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
