package MusicBrainz::Server::Edit::Event::AddEventArt;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_EVENT_ART );
use MusicBrainz::Server::Entity::Event;
use MusicBrainz::Server::Entity::EventArt;
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Event',
     'MusicBrainz::Server::Edit::Event::RelatedEntities',
     'MusicBrainz::Server::Edit::Role::AddArt';

sub edit_name { N_lp('Add event art', 'singular, edit type') }
sub edit_template { 'AddEventArt' }
sub edit_type { $EDIT_EVENT_ADD_EVENT_ART }

sub art_archive_model { shift->c->model('EventArtArchive') }
sub event_ids { shift->entity_ids }

has '+data' => (
    isa => data_fields('event'),
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
