package MusicBrainz::Server::Data::Track;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Track;
use MusicBrainz::Server::Data::Medium;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
    object_to_ids
    placeholders
);
use Scalar::Util 'weaken';

extends 'MusicBrainz::Server::Data::CoreEntity';

with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'track' };

sub _type { 'track' }

sub _columns
{
    return 'track.id, track.gid, track.name, track.medium, track.recording,
            track.number, track.position, track.length, track.artist_credit,
            track.edits_pending, track.is_data_track';
}

sub _column_mapping {
    return {
        id               => 'id',
        gid              => 'gid',
        name             => 'name',
        recording_id     => 'recording',
        medium_id        => 'medium',
        number           => 'number',
        position         => 'position',
        length           => 'length',
        artist_credit_id => 'artist_credit',
        edits_pending    => 'edits_pending',
        is_data_track    => 'is_data_track',
    };
}

sub _id_column
{
    return 'track.id';
}

sub _medium_ids
{
    my ($self, @track_ids) = @_;
    return $self->sql->select_single_column_array(
        "SELECT distinct(medium)
           FROM track
          WHERE id IN (" . placeholders(@track_ids) . ")", @track_ids);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'track', @objs);
}

sub load_for_mediums
{
    my ($self, @media) = @_;

    $_->clear_tracks for @media;

    my %id_to_medium = object_to_ids(@media);
    my @ids = keys %id_to_medium;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE medium IN (" . placeholders(@ids) . ")
                 ORDER BY medium, position";
    my @tracks = $self->query_to_list($query, \@ids);

    foreach my $track (@tracks) {
        my @media = @{ $id_to_medium{$track->medium_id} };
        $_->add_track($track) for @media;
    }
    
    foreach my $medium (@media) {
        $medium->has_loaded_tracks(1);
    }
}

sub find_by_artist_credit
{
    my ($self, $artist_credit_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . ",
                    name COLLATE musicbrainz AS name_collate
                 FROM " . $self->_table . "
                 WHERE artist_credit = ?
                 ORDER BY name COLLATE musicbrainz";
    $self->query_to_list_limited($query, [$artist_credit_id], $limit, $offset);
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "
        SELECT *
        FROM (
          SELECT DISTINCT ON (track.id, medium.id)
            " . $self->_columns . ",
            medium.id AS m_id, medium.format AS m_format,
                medium.position AS m_position, medium.name AS m_name,
                medium.release AS m_release,
                medium.track_count AS m_track_count,
            release.id AS r_id, release.gid AS r_gid, release.name AS r_name,
                release.release_group AS r_release_group,
                release.artist_credit AS r_artist_credit_id,
                release.status AS r_status,
                release.packaging AS r_packaging,
                release.edits_pending AS r_edits_pending,
                release.comment AS r_comment,
            date_year, date_month, date_day
          FROM track
          JOIN medium ON medium.id = track.medium
          JOIN release ON release.id = medium.release
          LEFT JOIN (
            SELECT release, country, date_year, date_month, date_day
            FROM release_country
            UNION ALL
            SELECT release, NULL, date_year, date_month, date_day
            FROM release_unknown_country
          ) release_event ON release_event.release = release.id
          WHERE track.recording = ?
          ORDER BY track.id, medium.id, date_year, date_month, date_day, release.name COLLATE musicbrainz
        ) s
        ORDER BY date_year, date_month, date_day, r_name COLLATE musicbrainz";

    $self->query_to_list_limited(
        $query,
        [$recording_id],
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;

            my $track = $model->_new_from_row($row);
            my $medium = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');
            my $release = MusicBrainz::Server::Data::Release->_new_from_row($row, 'r_');
            $medium->release($release);
            $track->medium($medium);

            return $track;
        },
    );
}

sub _insert_hook_prepare {
    return { recording_ids => [] };
}

sub _insert_hook_make_row {
    my ($self, $track_hash, $extra_data) = @_;

    delete $track_hash->{id};
    $track_hash->{number} //= '';
    $track_hash->{is_data_track} //= 0;
    my $row = $self->_create_row($track_hash);

    push @{ $extra_data->{recording_ids} }, $row->{recording};

    return $row;
}

sub _insert_hook_after_each {
    my ($self, $created, $track_hash) = @_;

    $self->c->model('DurationLookup')->update($track_hash->{medium_id});
}

sub _insert_hook_after {
    my ($self, $created_entities, $extra_data) = @_;

    $self->c->model('Recording')->_delete_from_cache(@{ $extra_data->{recording_ids} });
}

sub update
{
    my ($self, $track_id, $update) = @_;
    my $old_recording = $self->sql->select_single_value('SELECT recording FROM track WHERE id = ? FOR UPDATE', $track_id);

    my $row = $self->_create_row($update);
    $self->sql->update_row('track', $row, { id => $track_id });

    my $mediums = $self->_medium_ids($track_id);
    $self->c->model('DurationLookup')->update($mediums->[0]);
    $self->c->model('Recording')->_delete_from_cache($row->{recording}, $old_recording);
}

sub delete
{
    my ($self, @track_ids) = @_;

    my $recording_query = 'SELECT recording FROM track ' .
        'WHERE id IN (' . placeholders(@track_ids) . ')';

    my $recording_ids = $self->sql->select_single_column_array(
        $recording_query, @track_ids
    );

    $self->remove_gid_redirects(@track_ids);

    my $query = 'DELETE FROM track ' .
        'WHERE id IN (' . placeholders(@track_ids) . ') RETURNING medium';

    my $mediums = $self->sql->select_single_column_array($query, @track_ids);

    $self->c->model('DurationLookup')->update($_) for @$mediums;
    $self->c->model('Recording')->_delete_from_cache(@$recording_ids);
    return 1;
}

sub merge_mediums
{
    my ($self, $new_medium_id, @old_medium_ids) = @_;

    my @track_merges = @{
        $self->sql->select_list_of_lists(
            'SELECT newt.id AS new_id,
                    array_agg(oldt.id) AS old_ids
               FROM track oldt
               JOIN track newt ON newt.position = oldt.position
              WHERE newt.medium = ?
                AND oldt.medium = any(?)
              GROUP BY newt.id',
            $new_medium_id,
            \@old_medium_ids,
        )
    };

    for my $track_merge (@track_merges) {
        my ($new_id, $old_ids) = @$track_merge;

        $self->_delete_and_redirect_gids('track', $new_id, @{$old_ids});
    }
}

sub _create_row {
    my ($self, $track_hash) = @_;

    my $row = hash_to_row($track_hash, { reverse %{ $self->_column_mapping } });

    if (exists $row->{length} && defined($row->{length})) {
        $row->{length} = undef if $row->{length} == 0;
    }

    return $row;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
