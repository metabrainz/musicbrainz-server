package MusicBrainz::Server::EditSearch::Predicate::EditSubscription;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::EditSearch::Predicate';

has user => (
    is => 'ro',
    isa => 'MusicBrainz::Server::Authentication::User',
    required => 1
);

sub operator_cardinality_map {
  return (
    'subscribed' => undef,
    'not_subscribed' => undef,
  )
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $initial_exists_clause;
    my $exists_clause;

    if ($self->operator eq 'not_subscribed') {
        $initial_exists_clause = 'NOT EXISTS';
        $exists_clause = 'AND NOT EXISTS';
    } else {
        $initial_exists_clause = 'EXISTS';
        $exists_clause = 'OR EXISTS';
    }

    $query->add_where([ <<~"SQL", [ ($self->user->id) x 14 ] ]);
      $initial_exists_clause (
        SELECT TRUE
          FROM edit_area
         WHERE edit_area.area IN (
               SELECT area
                 FROM editor_collection_area
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_area.collection
                         AND editor = ?
                      )
               )
           AND edit_area.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_artist
         WHERE edit_artist.artist IN (
               SELECT artist
                 FROM editor_subscribe_artist
                WHERE editor = ?
                UNION
               SELECT artist
                 FROM editor_collection_artist
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_artist.collection
                         AND editor = ?
                      )
               )
           AND edit_artist.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_event
         WHERE edit_event.event IN (
               SELECT event
                 FROM editor_collection_event
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_event.collection
                         AND editor = ?
                      )
               )
           AND edit_event.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_instrument
         WHERE edit_instrument.instrument IN (
               SELECT instrument
                 FROM editor_collection_instrument
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_instrument.collection
                         AND editor = ?
                      )
               )
           AND edit_instrument.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_label
         WHERE edit_label.label IN (
               SELECT label
                 FROM editor_subscribe_label
                WHERE editor = ?
                UNION
               SELECT label
                 FROM editor_collection_label
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_label.collection
                         AND editor = ?
                      )
               )   
           AND edit_label.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_place
         WHERE edit_place.place IN (
               SELECT place
                 FROM editor_collection_place
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_place.collection
                         AND editor = ?
                      )
               )
           AND edit_place.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_recording
         WHERE edit_recording.recording IN (
               SELECT recording
                 FROM editor_collection_recording
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_recording.collection
                         AND editor = ?
                      )
               )
           AND edit_recording.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_release
         WHERE edit_release.release IN (
               SELECT release
                 FROM editor_collection_release
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_release.collection
                         AND editor = ?
                      )
               )
           AND edit_release.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_release_group
         WHERE edit_release_group.release_group IN (
               SELECT release_group
                 FROM editor_collection_release_group
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_release_group.collection
                         AND editor = ?
                      )
               )
           AND edit_release_group.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_series
         WHERE edit_series.series IN (
               SELECT series
                 FROM editor_subscribe_series
                WHERE editor = ?
                UNION
               SELECT series
                 FROM editor_collection_series
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_series.collection
                         AND editor = ?
                      )
               )
           AND edit_series.edit = edit.id
      ) $exists_clause (
        SELECT TRUE
          FROM edit_work
         WHERE edit_work.work IN (
               SELECT work
                 FROM editor_collection_work
                WHERE EXISTS (
                      SELECT TRUE 
                        FROM editor_subscribe_collection
                       WHERE collection = editor_collection_work.collection
                         AND editor = ?
                      )
               )
           AND edit_work.edit = edit.id
      )
      SQL
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
