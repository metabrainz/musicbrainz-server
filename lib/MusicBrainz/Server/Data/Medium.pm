package MusicBrainz::Server::Data::Medium;

use Moose;
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Data::Utils qw( query_to_list placeholders );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'medium JOIN tracklist ON medium.tracklist=tracklist.id';
}

sub _columns
{
    return 'medium.id, tracklist AS tracklist_id, release AS release_id,
            position, format AS format_id, name, editpending AS edits_pending,
            trackcount AS track_count';
}

sub _id_column
{
    return 'medium.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        tracklist_id => 'tracklist_id',
        tracklist => sub {
            my $row = shift;
            return MusicBrainz::Server::Entity::Tracklist->new(
                id => $row->{tracklist_id},
                track_count => $row->{track_count},
            );
        },
        release_id => 'release_id',
        position => 'position',
        name => 'name',
        format_id => 'format_id',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Medium';
}

sub load
{
    my ($self, @releases) = @_;
    my %id_to_release = map { $_->id => $_ } @releases;
    my @ids = keys %id_to_release;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release IN (" . placeholders(@ids) . ")
                 ORDER BY release, position";
    my @mediums = query_to_list($self->c, sub { $self->_new_from_row(@_) },
                                $query, @ids);
    foreach my $medium (@mediums) {
        $id_to_release{$medium->release_id}->add_medium($medium);
    }
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
