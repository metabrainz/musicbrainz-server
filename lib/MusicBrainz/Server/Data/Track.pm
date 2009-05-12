package MusicBrainz::Server::Data::Track;

use Moose;
use MusicBrainz::Server::Entity::Track;
use MusicBrainz::Server::Data::Utils qw( query_to_list placeholders );

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'track JOIN track_name name ON track.name=name.id';
}

sub _columns
{
    return 'track.id, name.name, recording AS recording_id,
            tracklist AS tracklist_id, position, length,
            artist_credit AS artist_credit_id,
            editpending AS edits_pending';
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
    my ($self, @tracklists) = @_;
    my %id_to_tracklist = map { $_->id => $_ } @tracklists;
    my @ids = keys %id_to_tracklist;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE tracklist IN (" . placeholders(@ids) . ")
                 ORDER BY tracklist, position";
    my @tracks = query_to_list($self->c, sub { $self->_new_from_row(@_) },
                               $query, @ids);
    foreach my $track (@tracks) {
        $id_to_tracklist{$track->tracklist_id}->add_track($track);
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
