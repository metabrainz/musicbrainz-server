package MusicBrainz::Server::Edit::Historic::MergeReleaseMAC;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE_MAC );
use MusicBrainz::Server::Edit::Constants qw( %EDIT_KIND_LABELS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Historic::MergeRelease';

sub edit_name     { N_lp('Merge releases', 'edit type') }
sub edit_kind     { $EDIT_KIND_LABELS{'merge'} }
sub historic_type { 25 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE_MAC }

1;
