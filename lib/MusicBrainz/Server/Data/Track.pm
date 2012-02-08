package MusicBrainz::Server::Data::Track;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Track;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Data::Medium;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list
    query_to_list_limited
    placeholders
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
    return 'track.id, name.name, recording, tracklist, position, length,
            artist_credit, edits_pending';
}

sub _column_mapping
{
    return {
        id               => 'id',
        name             => 'name',
        recording_id     => 'recording',
        tracklist_id     => 'tracklist',
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

sub load_for_tracklists
{
    my ($self, @tracklists) = @_;
    my %id_to_tracklist;
    for my $tracklist (@tracklists) {
        $id_to_tracklist{$tracklist->id} ||= [];
        push @{ $id_to_tracklist{$tracklist->id} }, $tracklist;
    }
    my @ids = keys %id_to_tracklist;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE tracklist IN (" . placeholders(@ids) . ")
                 ORDER BY tracklist, position";
    my @tracks = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                               $query, @ids);
    foreach my $track (@tracks) {
        my @tracklists = @{ $id_to_tracklist{$track->tracklist_id} };
        $_->add_track($track) for @tracklists;
    }
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "
        SELECT
            track.id, track_name.name, track.tracklist, track.position,
                track.length, track.artist_credit, track.edits_pending,
                medium.id AS m_id, medium.format AS m_format,
                medium.position AS m_position, medium.name AS m_name,
                medium.tracklist AS m_tracklist,
                medium.release AS m_release,
                tracklist.track_count AS m_track_count,
            release.id AS r_id, release.gid AS r_gid, release_name.name AS r_name,
                release.release_group AS r_release_group,
                release.artist_credit AS r_artist_credit_id,
                release.date_year AS r_date_year,
                release.date_month AS r_date_month,
                release.date_day AS r_date_day,
                release.country AS r_country, release.status AS r_status,
                release.packaging AS r_packaging,
                release.edits_pending AS r_edits_pending,
                release.comment AS r_comment
        FROM
            track
            JOIN tracklist ON tracklist.id = track.tracklist
            JOIN medium ON medium.tracklist = tracklist.id
            JOIN release ON release.id = medium.release
            JOIN release_name ON release.name = release_name.id
            JOIN track_name ON track.name = track_name.id
        WHERE track.recording = ?
        ORDER BY date_year, date_month, date_day, musicbrainz_collate(release_name.name)
        OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row       = shift;
            my $track     = $self->_new_from_row($row);
            my $medium    = MusicBrainz::Server::Data::Medium->_new_from_row($row, 'm_');
            my $tracklist = $medium->tracklist;
            my $release   = MusicBrainz::Server::Data::Release->_new_from_row($row, 'r_');
            $medium->release($release);
            $tracklist->medium($medium);
            $track->tracklist($tracklist);

            # XXX HACK!!
            weaken($medium->{tracklist});

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
        my $row = $self->_create_row($track_hash, \%names);
        push @created, $class->new(
            id => $self->sql->insert_row('track', $row, 'id')
        );
    }
    return @created > 1 ? @created : $created[0];
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
