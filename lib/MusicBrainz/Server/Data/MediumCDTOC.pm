package MusicBrainz::Server::Data::MediumCDTOC;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    hash_to_row
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'medium_cdtoc' };

sub _table
{
    return 'medium_cdtoc';
}

sub _columns
{
    return 'medium_cdtoc.id, medium, cdtoc, edits_pending';
}

sub _column_mapping
{
    return {
        id => 'id',
        medium_id => 'medium',
        cdtoc_id => 'cdtoc',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::MediumCDTOC';
}

sub find_by_medium
{
    my ($self, @medium_ids) = @_;
    return () unless @medium_ids;

    my $query = "
        SELECT " . $self->_columns . " FROM " . $self->_table . "
        WHERE medium IN (" . placeholders(@medium_ids) . ")
        ORDER BY id";
    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, @medium_ids);
}

sub load_for_mediums
{
    my ($self, @mediums) = @_;

    my %id_to_medium = map { $_->id => $_ } @mediums;
    my @list = $self->find_by_medium(keys %id_to_medium);
    foreach my $o (@list) {
        $id_to_medium{$o->medium_id}->add_cdtoc($o);
    }
    return @list;
}

sub find_by_discid
{
    my ($self, $discid) = @_;
    my $query =
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
           JOIN cdtoc ON cdtoc = cdtoc.id
          WHERE discid = ?
       ORDER BY medium_cdtoc.id ASC';
    return query_to_list(
        $self->sql, sub { $self->_new_from_row(@_) },
        $query, $discid);
}

sub get_by_medium_cdtoc
{
    my ($self, $medium_id, $cdtoc_id) = @_;
    my $query = 'SELECT ' . $self->_columns .
                 ' FROM ' . $self->_table .
                 ' WHERE medium = ? AND cdtoc = ?';
    my $medium_cdtoc = $self->sql->select_single_row_hash($query, $medium_id, $cdtoc_id);
    return $self->_new_from_row($medium_cdtoc);
}

sub insert
{
    my ($self, $hash) = @_;
    my $id = $self->sql->insert_row('medium_cdtoc', $hash, 'id');
    $self->c->model('CDStub')->delete(
        $self->sql->select_single_value(
            'SELECT discid FROM cdtoc WHERE id = ?',
            $hash->{cdtoc}
        )
    );

    # If all track times are undefined, then set them to the CDTOC
    my ($medium_id, $set_track_lengths) = @{ $self->sql->select_single_row_array(
        'SELECT track.medium, bool_and(track.length IS NULL)
           FROM track
          WHERE track.medium = ?
       GROUP BY track.medium',
        $hash->{medium}
    ) || [ undef, 0 ] };

    if ($set_track_lengths) {
        $self->c->model('Medium')->set_lengths_to_cdtoc(
            $medium_id,
            $hash->{cdtoc}
        );
    }

    return $id;
}

sub update
{
    my ($self, $medium_cdtoc_id, $update) = @_;
    $self->sql->update_row('medium_cdtoc', hash_to_row($update, { reverse %{ $self->_column_mapping } }),
        { id => $medium_cdtoc_id });
}

sub delete
{
    my ($self, $medium_cdtoc_id) = @_;
    my $cdtoc_id = $self->sql->select_single_value(
        'DELETE FROM ' . $self->_table . ' WHERE id = ?
           RETURNING cdtoc',
        $medium_cdtoc_id
    );
    # Delete the CDTOC if it is now unused
    $self->sql->do(
        'DELETE FROM cdtoc WHERE id IN (
             SELECT cd.id FROM cdtoc cd
          LEFT JOIN medium_cdtoc mcd ON mcd.cdtoc = cd.id
             WHERE cd.id = ? AND mcd.id IS NULL
         )', $cdtoc_id);
}

sub merge_mediums
{
    my ($self, $new_medium, @old_mediums) = @_;
    my @mediums = ($new_medium, @old_mediums);
    $self->sql->do(
        'DELETE FROM medium_cdtoc
               WHERE id NOT IN (
                         SELECT DISTINCT ON (cdtoc) id
                           FROM medium_cdtoc
                          WHERE medium IN ('.placeholders(@mediums).')
                     )
                AND medium IN (' . placeholders(@mediums) . ')',
        @mediums, @mediums
    );

    $self->sql->do(
        'UPDATE medium_cdtoc SET medium = ? WHERE medium IN ('.placeholders(@mediums).')',
        $new_medium, @mediums
    );
}

sub medium_has_cdtoc {
    my ($self, $medium_id, $cdtoc) = @_;
    return $self->sql->select_single_value(
        'SELECT TRUE
         FROM medium_cdtoc
         JOIN cdtoc ON medium_cdtoc.cdtoc = cdtoc.id
         WHERE medium = ? AND cdtoc.discid = ?',
        $medium_id, $cdtoc->discid
    ) || 0;
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
