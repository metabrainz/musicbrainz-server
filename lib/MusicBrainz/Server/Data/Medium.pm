package MusicBrainz::Server::Data::Medium;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    object_to_ids
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'medium' };

use Scalar::Util qw( weaken );

sub _table
{
    return 'medium';
}

sub _columns
{
    return 'medium.id, release, position, format, medium.name,
            medium.edits_pending, track_count,
            COALESCE((SELECT TRUE FROM track WHERE medium = medium.id AND position = 0), false) AS has_pregap,
            (SELECT count(*) FROM track WHERE medium = medium.id AND position > 0 AND is_data_track = false) AS cdtoc_track_count';
}

sub _id_column
{
    return 'medium.id';
}

sub _column_mapping
{
    return {
        id                  => 'id',
        track_count         => 'track_count',
        release_id          => 'release',
        position            => 'position',
        name                => 'name',
        format_id           => 'format',
        edits_pending       => 'edits_pending',
        has_pregap          => 'has_pregap',
        cdtoc_track_count   => 'cdtoc_track_count',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Medium';
}

sub load
{
    my ($self, @objs) = @_;
    return load_subobjects($self, 'medium', @objs);
}

sub load_track_durations {
    my ($self, @mediums) = @_;

    @mediums = grep { !$_->durations_loaded } @mediums;
    return unless @mediums;

    my %id_to_medium = object_to_ids(@mediums);
    my @ids = keys %id_to_medium;
    return unless @ids;

    my $query =
        'SELECT medium, pregap_length, cdtoc_track_lengths, data_track_lengths ' .
        'FROM medium_track_durations ' .
        'WHERE medium = any(?)';

    my $duration_rows = $self->sql->select_list_of_hashes($query, [\@ids]);
    for my $row (@$duration_rows) {
        for my $medium (@{ $id_to_medium{ $row->{medium} } }) {
            $medium->pregap_length($row->{pregap_length});
            $medium->cdtoc_track_lengths($row->{cdtoc_track_lengths});
            $medium->data_track_lengths($row->{data_track_lengths});
            $medium->durations_loaded(1);
        }
    }
}

sub load_for_releases
{
    my ($self, @releases) = @_;

    @releases = grep { !$_->mediums_loaded } @releases;
    return unless @releases;

    my %id_to_release = object_to_ids(@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 WHERE release IN (' . placeholders(@ids) . ')
                 ORDER BY release, position';
    my @mediums = $self->query_to_list($query, \@ids);
    foreach my $medium (@mediums) {
        foreach my $release (@{ $id_to_release{$medium->release_id} })
        {
            $medium->release($release);
            $release->add_medium($medium);
            weaken($medium->{release}); # XXX HACK!
        }
    }

    $self->load_track_durations(@mediums);
    $_->mediums_loaded(1) for @releases;
}

sub update
{
    my ($self, $medium_id, $medium_hash) = @_;
    die 'update cannot update tracklist' if exists $medium_hash->{tracklist};

    my $row = $self->_hash_to_row($medium_hash);
    return unless %$row;

    $self->sql->update_row('medium', $row, { id => $medium_id });

    if ($row->{format}) {
        my $has_discids = $self->sql->select_single_value('SELECT has_discids FROM medium_format WHERE id = ?', $row->{format});
        $self->sql->do('UPDATE track SET is_data_track = false WHERE medium = ?', $medium_id) unless $has_discids;
    }
}

sub insert
{
    my ($self, @medium_hashes) = @_;

    my @created;
    for my $medium_hash (@medium_hashes) {
        my $tracklist = delete $medium_hash->{tracklist};
        my $row = $self->_hash_to_row($medium_hash);

        my $medium_created = {
            id => $self->sql->insert_row('medium', $row, 'id'),
        };

        for my $track (@$tracklist) {
            $track->{medium_id} = $medium_created->{id};
            $track->{artist_credit_id} =
                $self->c->model('ArtistCredit')->find_or_insert(
                    delete $track->{artist_credit});
        };

        $self->c->model('Track')->insert(@$tracklist);

        push @created, $medium_created;
    }

    return @medium_hashes > 1 ? @created : $created[0];
}

sub can_delete { 1 }

sub delete
{
    my ($self, @ids) = @_;
    my @tocs = @{
        $self->sql->select_single_column_array(
            'SELECT id FROM medium_cdtoc WHERE medium IN (' . placeholders(@ids) . ')',
            @ids
        )
    };

    $self->c->model('MediumCDTOC')->delete($_) for @tocs;
    $self->sql->do('DELETE FROM track_gid_redirect WHERE new_id IN (SELECT id FROM track WHERE medium IN (' . placeholders(@ids) . '))', @ids);
    $self->sql->do('DELETE FROM track WHERE medium IN (' . placeholders(@ids) . ')', @ids);
    $self->sql->do('DELETE FROM medium WHERE id IN (' . placeholders(@ids) . ')', @ids);
}

sub _hash_to_row
{
    my ($self, $medium_hash) = @_;
    my %row;
    my $mapping = $self->_column_mapping;
    for my $col (qw( name format_id position release_id ))
    {
        next unless exists $medium_hash->{$col};
        my $mapped = $mapping->{$col} || $col;
        $row{$mapped} = $medium_hash->{$col};
    }
    return \%row;
}

sub find_for_cdstub {
    my ($self, $cdstub, $limit, $offset) = @_;
    my $query =
        'SELECT ' . join(', ', $self->c->model('Release')->_columns,
                         map { "medium.$_ AS m_$_" } qw(
                             id name track_count release position format edits_pending
                         )) . q(
           FROM (
                    SELECT id, ts_rank_cd(mb_simple_tsvector(name), query, 2) AS rank,
                           name
                    FROM release, plainto_tsquery('mb_simple', mb_lower(?)) AS query
                    WHERE mb_simple_tsvector(name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS name
           JOIN release ON name.id = release.id
           JOIN medium ON medium.release = release.id
      LEFT JOIN medium_format ON medium.format = medium_format.id
          WHERE track_count_matches_cdtoc(medium, ?)
          AND (medium_format.id IS NULL OR medium_format.has_discids)
       ORDER BY name.rank DESC, name.name COLLATE musicbrainz,
                release.artist_credit);

    $self->query_to_list(
        $query,
        [$cdstub->title, 10, $cdstub->track_count],
        sub {
            my ($model, $row) = @_;

            my $release = $self->c->model('Release')->_new_from_row($row);
            my $medium = $model->_new_from_row($row, 'm_');
            $medium->release($release);
            $medium;
        },
    );
}

sub set_lengths_to_cdtoc
{
    my ($self, $medium_id, $cdtoc_id) = @_;
    my $cdtoc = $self->c->model('CDTOC')->get_by_id($cdtoc_id)
        or die 'Could not load CDTOC';

    my $medium = $self->get_by_id($medium_id)
        or die 'Could not load tracklist';

    $self->c->model('Track')->load_for_mediums($medium);
    $self->c->model('ArtistCredit')->load($medium->all_tracks);

    my @recording_ids;
    my @info = @{ $cdtoc->track_details };
    my @medium_tracks = @{ $medium->cdtoc_tracks };

    for my $i (0..$#info) {
        my $track = $medium_tracks[$i];

        $self->c->model('Track')->update(
            $track->id, { length => $info[$i]->{length_time} }
        );

        push @recording_ids, $track->recording_id;
        $i++;
    }

    $self->c->model('Recording')->_delete_from_cache(@recording_ids);
}

=method reorder

    reorder

Takes a map of medium ids to their new position, and reorders them. For example:

   reorder( 91 => 1, 92 => 2 )

Will move medium #91 to be in position 1 and medium #92 to be in position 2

=cut

sub reorder {
    my ($self, %ordering) = @_;
    my @medium_ids = keys %ordering;

    $self->sql->do(
        'UPDATE medium SET position = -position
          WHERE id IN (' . placeholders(@medium_ids) . ')',
        @medium_ids);

    $self->sql->do(
        'UPDATE medium SET position =
                (SELECT position
                   FROM (VALUES ' . join(', ', ('(?::INTEGER, ?::INTEGER)') x @medium_ids) . ')
                     AS mpos (medium, position)
                  WHERE mpos.medium = medium.id)
          WHERE id IN (' . placeholders(@medium_ids) . ')',
        %ordering, @medium_ids
    )
}

sub load_related_info {
    my ($self, $user_id, @mediums) = @_;

    $self->c->model('MediumFormat')->load(@mediums);
    $self->c->model('Release')->load(@mediums);
    $self->c->model('Track')->load_for_mediums(@mediums);

    my @tracks = map { $_->all_tracks } @mediums;
    $self->c->model('Track')->load_related_info($user_id, @tracks);
}

sub load_related_info_paged {
    my ($self, $user_id, $medium, $page) = @_;

    $self->c->model('MediumFormat')->load($medium);
    $self->c->model('Release')->load($medium);

    my ($pager, $tracks) = $self->c->model('Track')->load_for_medium_paged(
        $medium->id,
        $page,
    );

    $self->c->model('Track')->load_related_info($user_id, @$tracks);
    $medium->tracks($tracks);
    $medium->has_loaded_tracks(1);
    $medium->tracks_pager($pager);
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
