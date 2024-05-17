package MusicBrainz::Server::Edit::Historic::MergeReleaseMAC;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MERGE_RELEASE_MAC );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Historic::MergeRelease';

sub edit_name     { N_lp('Merge releases', 'edit type') }
sub edit_kind     { 'merge' }
sub historic_type { 25 }
sub edit_type     { $EDIT_HISTORIC_MERGE_RELEASE_MAC }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
