package MusicBrainz::Server::Edit::Label::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Merge';

sub edit_type { $EDIT_LABEL_MERGE }
sub edit_name { l('Merge labels') }

sub _merge_model { 'Label' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
