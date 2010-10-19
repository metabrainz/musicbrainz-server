package MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';

sub edit_type { $EDIT_RELEASEGROUP_DELETE }
sub edit_name { l("Remove release group") }
sub _delete_model { 'ReleaseGroup' }
sub release_group_id { shift->entity_id }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

