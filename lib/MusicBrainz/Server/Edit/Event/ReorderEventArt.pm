package MusicBrainz::Server::Edit::Event::ReorderEventArt;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_REORDER_EVENT_ART );
use MusicBrainz::Server::Entity::Event;
use MusicBrainz::Server::Entity::EventArt;
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Event',
     'MusicBrainz::Server::Edit::Event::RelatedEntities',
     'MusicBrainz::Server::Edit::Role::ReorderArt';

sub edit_name { N_lp('Reorder event art', 'plural, edit type') }
sub edit_type_name_context { 'plural, edit type' }
sub edit_template { 'ReorderEventArt' }
sub edit_type { $EDIT_EVENT_REORDER_EVENT_ART }

sub art_archive_model { shift->c->model('EventArtArchive') }
sub event_ids { shift->entity_ids }

has '+data' => (
    isa => data_fields(),
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
