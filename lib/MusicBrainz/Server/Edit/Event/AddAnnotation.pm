package MusicBrainz::Server::Edit::Event::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Event',
    edit_name => N_l('Add event annotation'),
    edit_type => $EDIT_EVENT_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
