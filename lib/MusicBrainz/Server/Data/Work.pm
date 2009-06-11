package MusicBrainz::Server::Data::Work;

use Moose;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    placeholders
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::AnnotationRole' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'work_name' };

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

sub _id_column
{
    return 'work.id';
}

sub _gid_redirect_table
{
    return 'work_gid_redirect';
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
                 ORDER BY name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

sub insert
{
    my ($self, @works) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    my %names = $self->find_or_insert_names(map { $_->{name} } @works);
    my $class = $self->_entity_class;
    my @created;
    for my $work (@works)
    {
        my $row = $self->_hash_to_row($work, \%names);
        $row->{gid} = $work->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->InsertRow('work', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @works > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $work, $update) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->Update('work', $row, { id => $work->id });
    return $work;
}

sub delete
{
    my ($self, $work) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    $sql->Do('DELETE FROM work WHERE id = ?', $work->id);
    return;
}

sub _hash_to_row
{
    my ($self, $work, $names) = @_;
    my %row = (
        artist_credit => $work->{artist_credit},
        type => $work->{type},
        iswc => $work->{iswc},
        comment => $work->{comment},
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
