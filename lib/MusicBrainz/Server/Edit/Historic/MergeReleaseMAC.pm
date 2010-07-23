package MusicBrainz::Server::Edit::Historic::MergeReleaseMAC;
use Moose;
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE_MAC );

extends 'MusicBrainz::Server::Edit::Historic::MergeRelease';

sub edit_name     { 'Merge releases' }
sub historic_type { 25 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE_MAC }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
