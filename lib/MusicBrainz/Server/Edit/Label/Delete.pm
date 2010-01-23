package MusicBrainz::Server::Edit::Label::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );

extends 'MusicBrainz::Server::Edit::Generic::Delete';

sub edit_type { $EDIT_LABEL_DELETE }
sub edit_name { "Remove label" }
sub _delete_model { 'Label' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

