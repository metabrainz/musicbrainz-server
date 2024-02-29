package MusicBrainz::Server::Data::ReleaseLabel;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::ReleaseLabel;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    placeholders
    object_to_ids
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'release_label rl';
}

sub _build_columns
{
    return join q(, ), (
        'rl.id AS rl_id',
        'rl.release AS rl_release',
        'rl.label AS rl_label',
        'rl.catalog_number AS rl_catalog_number',
    );
}

has '_columns' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_columns',
);

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
    my %id_to_release = object_to_ids(grep { !$_->has_labels } @releases);
    my @ids = keys %id_to_release;
    return unless @ids; # nothing to do
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 LEFT JOIN label ON rl.label = label.id
                 WHERE release IN (' . placeholders(@ids) . ')
                 ORDER BY release, rl_catalog_number, label.name COLLATE musicbrainz';
    my @labels = $self->query_to_list($query, \@ids);
    foreach my $label (@labels) {
        foreach (@{ $id_to_release{$label->release_id} })
        {
            $_->add_label($label);
        }
    }
}

sub merge_labels {
    my ($self, $new_id, @old_ids) = @_;

    $self->sql->do(
        'UPDATE release_label SET label = ? WHERE label = any(?)',
        $new_id,
        \@old_ids,
    );

    $self->sql->do(
        'DELETE FROM release_label WHERE id IN (
            SELECT a.id
            FROM release_label a
            JOIN release_label b ON (
                b.release = a.release AND
                b.catalog_number IS NOT DISTINCT FROM a.catalog_number
            )
            WHERE a.id < b.id AND a.label = ? AND b.label = ?
        )',
        $new_id,
        $new_id,
    );
}

sub merge_releases
{
    my ($self, $new_id, @old_ids) = @_;
    my @ids = ($new_id, @old_ids);

    $self->sql->do(
        'DELETE FROM release_label
          WHERE release IN (' . placeholders(@ids) . ')
            AND id NOT IN (
                SELECT DISTINCT ON (label, catalog_number)
                       id
                  FROM release_label
                 WHERE release IN (' . placeholders(@ids) . ')
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

    my $release_id = $row->{release};
    $self->c->model('Series')->reorder_for_entities('release', $release_id);

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

    my $release_id = $row->{release} // $self->sql->select_single_value(
        'SELECT release FROM release_label WHERE id = ?', $id,
    );

    $self->c->model('Series')->reorder_for_entities('release', $release_id);
}

sub delete {
    my ($self, @release_label_ids) = @_;

    my $release_ids = $self->sql->select_single_column_array(
        'DELETE FROM release_label WHERE id = any(?) RETURNING release',
        \@release_label_ids,
    );

    $self->c->model('Series')->reorder_for_entities('release', @$release_ids);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
