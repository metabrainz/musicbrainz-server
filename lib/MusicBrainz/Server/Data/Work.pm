package MusicBrainz::Server::Data::Work;

use Moose;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    load_subobjects
    placeholders
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::BrowseVA';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'work' };

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Alias' => {
        alias_table        => schema->table('work_alias')
    },
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('work_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('work_meta') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('work_annotation') },
    'MusicBrainz::Server::Data::Role::Editable';

sub _build_table { schema->table('work') }

sub _table
{
    return 'work JOIN work_name name ON work.name=name.id';
}

sub _columns
{
    return 'work.id, gid, type AS type_id, name.name,
            work.artist_credit AS artist_credit_id, iswc,
            comment, editpending AS edits_pending';
}

sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        type_id          => 'type',
        name             => 'name',
        iswc             => 'iswc',
        artist_credit_id => 'artist_credit',
        comment          => 'comment',
        edits_pending    => 'editpending',
    };
}

sub _id_column
{
    return 'work.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Work';
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = work.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'work', @objs);
}

sub insert
{
    my ($self, @works) = @_;
    my $sql = Sql->new($self->c->dbh);
    my %names = $self->find_or_insert_names(map { $_->{name} } @works);
    my $class = $self->_entity_class;
    my @created;
    for my $work (@works)
    {
        my $row = $self->_hash_to_row($work, \%names);
        $row->{gid} = $work->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->insert_row('work', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @works > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $work_id, $update) = @_;
    my $sql = Sql->new($self->c->dbh);
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->update_row('work', $row, { id => $work_id });
}

sub delete
{
    my ($self, $work) = @_;
    $self->c->model('Relationship')->delete_entities('work', $work->id);
    $self->annotation->delete($work->id);
    $self->alias->delete_entities($work->id);
    $self->tags->delete($work->id);
    $self->rating->delete($work->id);
    $self->remove_gid_redirects($work->id);
    my $sql = Sql->new($self->c->dbh);
    $sql->do('DELETE FROM work WHERE id = ?', $work->id);
    return;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('work', $new_id, @old_ids);

    $self->_delete_and_redirect_gids('work', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $work, $names) = @_;
    my %row = (
        artist_credit => $work->{artist_credit},
        iswc => $work->{iswc},
        comment => $work->{comment},
        type => $work->{type_id},
    );

    if ($work->{name}) {
        $row{name} = $names->{$work->{name}};
    }

    return { defined_hash(%row) };
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
