package MusicBrainz::Server::Data::ReleaseLabel;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::ReleaseLabel;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    placeholders
    object_to_ids
    query_to_list
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'release_label rl';
}

sub _columns
{
    return 'rl.id AS rl_id, rl.release AS rl_release, rl.label AS rl_label,
            rl.catalog_number AS rl_catalog_number';
}

sub _column_mapping
{
    return {
        id             => 'rl_id',
        release_id     => 'rl_release',
        label_id       => 'rl_label',
        catalog_number => 'rl_catalog_number',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseLabel';
}

sub load
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids (@releases);
    my @ids = keys %id_to_release;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release IN (" . placeholders(@ids) . ")
                 ORDER BY release, rl_catalog_number";
    my @labels = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                               $query, @ids);
    foreach my $label (@labels) {
        foreach (@{ $id_to_release{$label->release_id} })
        {
            $_->add_label($label);
        }
    }
}

sub find_by_label
{
    my ($self, $label_id, $limit, $offset) = @_;
    $offset ||= 0;
    my $query = "SELECT " . $self->_columns . ",
                    " . MusicBrainz::Server::Data::Release->_columns . "
                 FROM " . $self->_table . "
                    JOIN release ON release.id=rl.release
                    JOIN release_name name ON release.name=name.id
                 WHERE rl.label = ?
                 ORDER BY date_year, date_month, date_day, catalog_number, musicbrainz_collate(name.name)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $rl = $self->_new_from_row(@_);
            $rl->release(MusicBrainz::Server::Data::Release->_new_from_row(@_));
            return $rl;
        },
        $query, $label_id, $offset);
}

sub merge_labels
{
    my ($self, $new_id, @old_ids) = @_;
    $self->sql->do('UPDATE release_label SET label = ?
              WHERE label IN ('.placeholders(@old_ids).')', $new_id, @old_ids);
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;
    my @ids = ($new_id, @old_ids);

    $self->sql->do(
        'DELETE FROM release_label
          WHERE release IN (' . placeholders(@ids) . ")
            AND id NOT IN (
                SELECT DISTINCT ON (label, catalog_number)
                       id
                  FROM release_label
                 WHERE release IN (" . placeholders(@ids) . ')
            )', @ids, @ids);

    $self->sql->do('UPDATE release_label SET release = ?
              WHERE release IN ('.placeholders(@old_ids).')', $new_id, @old_ids);

    # If we have >1 release_labels with the same label and at least 1 has a
    # catalog number, remove any release_labels that have a NULL catalog number
    $self->sql->do(
        'DELETE FROM release_label
           WHERE id IN (
             SELECT this.id
             FROM release_label this
             JOIN release_label other ON (
               other.id     != this.id AND
               other.release = this.release AND
               other.label   = this.label
             )
             WHERE this.release IN (' . placeholders(@ids) . ')
             AND this.catalog_number IS NULL
             AND this.label IS NOT NULL
             AND other.catalog_number IS NOT NULL
           )', @ids);
}

sub insert
{
    my ($self, $edit_hash) = @_;

    my $row = hash_to_row($edit_hash, {
        release => 'release_id',
        label => 'label_id',
        catalog_number => 'catalog_number',
    });

    my @created;
    my $class = $self->_entity_class;

    push @created, $class->new(id => $self->sql->insert_row('release_label', $row, 'id'));

    return wantarray ? @created : $created[0];
}

sub update
{
    my ($self, $id, $edit_hash) = @_;
    my $row = hash_to_row($edit_hash, {
        catalog_number => 'catalog_number',
        label => 'label_id',
    });
    $self->sql->update_row('release_label', $row, { id => $id });
}

sub delete
{
    my ($self, @release_label_ids) = @_;
    my $query = 'DELETE FROM release_label WHERE id IN (' . placeholders(@release_label_ids) . ')';
    $self->sql->do($query, @release_label_ids);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::ReleaseLabel

=head1 METHODS

=head2 loads (@releases)

Loads and sets labels for the specified releases. The data can be then
accessed using $release->labels.

=head2 find_by_label ($release_group_id, $limit, [$offset])

Finds releases by the specified label, and returns an array containing
a reference to the array of ReleaseLabel instances and the total number
of found releases. The returned ReleaseLabel objects will also have releases
loaded. The $limit parameter is used to limit the number of returned releass.

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
