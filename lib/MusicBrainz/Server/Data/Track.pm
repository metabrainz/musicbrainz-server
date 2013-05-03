package MusicBrainz::Server::Data::Track;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Track;
use MusicBrainz::Server::Data::Medium;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    generate_gid
    load_subobjects
    object_to_ids
    placeholders
    query_to_list
    query_to_list_limited
);
use Scalar::Util 'weaken';

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'track_name' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'track' };

sub _table
{
    return 'track JOIN track_name name ON track.name=name.id';
}

sub _columns
{
    return 'track.id, track.gid, name.name, track.medium, track.recording,
            track.number, track.position, track.length, track.artist_credit,
            track.edits_pending';
}

sub _column_mapping
{
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
    };
}

sub _id_column
{
    return 'track.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Track';
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

    my %id_to_medium = object_to_ids (@media);
    my @ids = keys %id_to_medium;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE medium IN (" . placeholders(@ids) . ")
                 ORDER BY medium, position";
    my @tracks = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                               $query, @ids);

    foreach my $track (@tracks) {
        my @media = @{ $id_to_medium{$track->medium_id} };
        $_->add_track($track) for @media;
    }
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "
        SELECT *
        FROM (
          SELECT DISTINCT ON (track.id, medium.id)
            track.id, track_name.name, track.medium, track.position,
                track.length, track.artist_credit, track.edits_pending,
                medium.id AS m_id, medium.format AS m_format,
                medium.position AS m_position, medium.name AS m_name,
                medium.release AS m_release,
                medium.track_count AS m_track_count,
            release.id AS r_id, release.gid AS r_gid, release_name.name AS r_name,
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
          JOIN release_name ON release.name = release_name.id
          JOIN track_name ON track.name = track_name.id
          LEFT JOIN (
            SELECT release, country, date_year, date_month, date_day
            FROM release_country
            UNION ALL
            SELECT release, NULL, date_year, date_month, date_day
            FROM release_unknown_country
          ) release_event ON release_event.release = release.id
          WHERE track.recording = ?
          ORDER BY track.id, medium.id, date_year, date_month, date_day, musicbrainz_collate(release_name.name)
        ) s
        ORDER BY date_year, date_month, date_day, musicbrainz_collate(r_name)
        OFFSET ?";

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row       = shift;
            my $track     = $self->_new_from_row($row);
            my $medium    = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');
            my $release   = MusicBrainz::Server::Data::Release->_new_from_row($row, 'r_');
            $medium->release($release);
            $track->medium($medium);

            return $track;
        },
        $query, $recording_id, $offset || 0);
}

sub insert
{
    my ($self, @track_hashes) = @_;
    my %names = $self->find_or_insert_names(map { $_->{name} } @track_hashes);
    my $class = $self->_entity_class;
    my @created;
    for my $track_hash (@track_hashes) {
        delete $track_hash->{id};

        $track_hash->{number} ||= "".$track_hash->{position};

        my $row = $self->_create_row($track_hash, \%names);
        $row->{gid} = $track_hash->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('track', $row, 'id')
        );
    }
    return @created > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $track_id, $update) = @_;
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_create_row($update, \%names);
    $self->sql->update_row('track', $row, { id => $track_id });
}

sub delete
{
    my ($self, @track_ids) = @_;
    my $query = 'DELETE FROM track WHERE id IN (' . placeholders(@track_ids) . ')';
    $self->sql->do($query, @track_ids);
    return 1;
}

sub _create_row
{
    my ($self, $track_hash, $names) = @_;

    my $mapping = $self->_column_mapping;
    my %row = map {
        my $mapped = $mapping->{$_} || $_;
        $mapped => $track_hash->{$_}
    } keys %$track_hash;

    $row{name} = $names->{ $track_hash->{name} } if exists $track_hash->{name};

    if (exists $row{length} && defined($row{length})) {
        $row{length} = undef if $row{length} == 0;
    }

    return { %row };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
