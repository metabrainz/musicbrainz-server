package MusicBrainz::Server::Edit::Historic::MergeReleaseMAC;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE_MAC );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Historic::MergeRelease';

sub edit_name     { N_l('Merge releases') }
sub edit_kind     { 'merge' }
sub historic_type { 25 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE_MAC }

1;
