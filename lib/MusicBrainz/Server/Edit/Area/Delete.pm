package MusicBrainz::Server::Edit::Area::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_DELETE );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Area';

sub edit_name { N_lp('Remove area', 'edit type') }
sub edit_type { $EDIT_AREA_DELETE }

sub _delete_model { 'Area' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
