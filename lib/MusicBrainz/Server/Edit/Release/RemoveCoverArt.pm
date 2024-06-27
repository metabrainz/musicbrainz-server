package MusicBrainz::Server::Edit::Release::RemoveCoverArt;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART );
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Entity::ReleaseArt;
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release',
     'MusicBrainz::Server::Edit::Release::RelatedEntities',
     'MusicBrainz::Server::Edit::Role::RemoveArt';

sub edit_name { N_lp('Remove cover art', 'singular, edit type') }
sub edit_type_name_context { 'singular, edit type' }
sub edit_template { 'RemoveCoverArt' }
sub edit_type { $EDIT_RELEASE_REMOVE_COVER_ART }

sub art_archive_model { shift->c->model('CoverArtArchive') }
sub release_ids { shift->entity_ids }

has '+data' => (
    isa => data_fields('cover'),
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
