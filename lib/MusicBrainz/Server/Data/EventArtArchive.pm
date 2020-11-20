package MusicBrainz::Server::Data::EventArtArchive;
use Moose;
use namespace::autoclean;
use DBDefs;

with 'MusicBrainz::Server::Data::Role::ArtArchive';

sub art_archive_name { 'event' }
sub art_archive_entity { 'event' }
sub art_archive_type_booleans { qw( is_front ) }
sub art_model_name { 'EventArt' }
sub download_prefix { DBDefs->EVENT_ART_ARCHIVE_DOWNLOAD_PREFIX }

sub get_stats_for_events { shift->get_stats_for_entities(@_) }

sub insert_event_art { shift->insert_art(@_) }

sub update_event_art { shift->update_art(@_) }

sub reorder_event_art { shift->reorder_art(@_) }

sub merge_events {
    my ($self, $new_event, @old_events) = @_;

    $self->merge_entities($new_event, @old_events);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
