package MusicBrainz::Server::Data::Recording;

use Moose;
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Data::Track;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    placeholders
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'recording' };

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('recording_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('recording_meta') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('recording_annotation') },
    'MusicBrainz::Server::Data::Role::Editable',
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('recording_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::Subobject';

sub _build_table { schema->table('recording') }

sub _table
{
    return 'recording JOIN track_name name ON recording.name=name.id';
}

sub _columns
{
    return 'recording.id, gid, name.name,
            recording.artist_credit AS artist_credit_id, length,
            comment, editpending AS edits_pending';
}

sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        name             => 'name',
        artist_credit_id => 'artist_credit',
        length           => 'length',
        comment          => 'comment',
        edits_pending    => 'editpending',
    };
}

sub _id_column
{
    return 'recording.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Recording';
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = recording.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub insert
{
    my ($self, @recordings) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $track_data = MusicBrainz::Server::Data::Track->new(c => $self->c);
    my %names = $track_data->find_or_insert_names(map { $_->{name} } @recordings);
    my $class = $self->_entity_class;
    my @created;
    for my $recording (@recordings)
    {
        my $row = $self->_hash_to_row($recording, \%names);
        $row->{gid} = $recording->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->insert_row('recording', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @recordings > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $recording_id, $update) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $track_data = MusicBrainz::Server::Data::Track->new(c => $self->c);
    my %names = $track_data->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->update_row('recording', $row, { id => $recording_id });
}

sub can_delete
{
    my ($self, $recording_id) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $refcount = $sql->select_single_column_array('SELECT 1 FROM track WHERE recording = ?', $recording_id);
    return @$refcount == 0;
}

sub delete
{
    my ($self, $recording) = @_;
    return unless $self->can_delete($recording->id);

    $self->c->model('Relationship')->delete_entities('recording', $recording->id);
    $self->c->model('RecordingPUID')->delete_recordings($recording->id);
    $self->c->model('ISRC')->delete_recordings($recording->id);
    $self->annotation->delete($recording->id);
    $self->tags->delete($recording->id);
    $self->rating->delete($recording->id);
    $self->remove_gid_redirects($recording->id);
    my $sql = Sql->new($self->c->dbh);
    $sql->do('DELETE FROM recording WHERE id = ?', $recording->id);
    return;
}

sub _hash_to_row
{
    my ($self, $recording, $names) = @_;
    my %row = (
        artist_credit => $recording->{artist_credit},
        length => $recording->{length},
        comment => $recording->{comment},
    );

    if ($recording->{name}) {
        $row{name} = $names->{$recording->{name}};
    }

    return { defined_hash(%row) };
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('RecordingPUID')->merge_recordings($new_id, @old_ids);
    $self->c->model('ISRC')->merge_recordings($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('recording', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('recording', $new_id, @old_ids);

    # Move tracks to the new recording
    my $sql = Sql->new($self->c->dbh);
    $sql->do('UPDATE track SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')', $new_id, @old_ids);

    $self->_delete_and_redirect_gids('recording', $new_id, @old_ids);
    return 1;
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
