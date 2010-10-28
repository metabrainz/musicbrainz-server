package MusicBrainz::Server::Edit::Historic::MergeReleaseMAC;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE_MAC );

use base 'MusicBrainz::Server::Edit::Historic::MergeRelease';

sub edit_name     { 'Merge releases' }
sub historic_type { 25 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE_MAC }

1;
