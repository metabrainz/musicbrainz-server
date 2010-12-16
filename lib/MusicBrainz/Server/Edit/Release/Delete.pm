package MusicBrainz::Server::Edit::Release::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Delete';

sub edit_type { $EDIT_RELEASE_DELETE }
sub edit_name { l('Remove release') }
sub _delete_model { 'Release' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

