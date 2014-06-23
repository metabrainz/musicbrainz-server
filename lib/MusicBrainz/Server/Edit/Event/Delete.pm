package MusicBrainz::Server::Edit::Event::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_DELETE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Event';

sub edit_type { $EDIT_EVENT_DELETE }
sub edit_name { N_l('Remove event') }
sub _delete_model { 'Event' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
