package MusicBrainz::Server::Data::Artwork;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Editable' => {
    table => 'cover_art_archive.cover_art'
};

sub _table
{
    return 'cover_art_archive.cover_art';
}

sub _columns
{
    return 'cover_art_archive.cover_art.id,
            cover_art_archive.cover_art.release,
            cover_art_archive.cover_art.comment,
            cover_art_archive.cover_art.edit,
            cover_art_archive.cover_art.ordering,
            cover_art_archive.cover_art.edits_pending';
}

sub _id_column
{
    return 'cover_art_archive.cover_art.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        release_id => 'release',
        comment => 'comment',
        edit_id => 'edit',
        ordering => 'ordering',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Artwork';
}

sub load_for_releases
{
    my ($self, @releases) = @_;
    my %id_to_release = object_to_ids (@releases);
    my @ids = keys %id_to_release;

    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release IN (" . placeholders(@ids) . ")
                 ORDER BY ordering";

    my @artwork = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                                $query, @ids);
    foreach my $image (@artwork) {
        foreach my $release (@{ $id_to_release{$image->release_id} })
        {
            $image->release ($release);
        }
    }

    return \@artwork;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
