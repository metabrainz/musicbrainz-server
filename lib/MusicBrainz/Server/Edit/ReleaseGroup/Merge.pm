package MusicBrainz::Server::Edit::ReleaseGroup::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );

extends 'MusicBrainz::Server::Edit::Generic::Merge';

sub edit_name { "Merge release groups" }
sub edit_type { $EDIT_RELEASEGROUP_MERGE }
sub _merge_model { 'ReleaseGroup' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
