package MusicBrainz::Server::Data::CDStubTrack;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'track_raw';
}

sub _columns
{
    return 'id, release, title, artist, sequence';
}

sub _column_mapping
{
    return {
        id => 'id',
        cdstub_id  => 'release',
        title => 'title',
        artist => 'artist',
        sequence => 'sequence',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStubTrack';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release', @objs);
}

sub load_for_cdstub
{
    my ($self, @cdstubs) = @_;
    my %id_to_cdstub = map { $_->id => $_ } @cdstubs;
    my @ids = keys %id_to_cdstub;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release IN (" . placeholders(@ids) . ")
                 ORDER BY release, sequence";
    my @tracks = query_to_list($self->c->sql, sub { $self->_new_from_row(@_) },
                               $query, @ids);
    foreach my $track (@tracks) {
        $id_to_cdstub{$track->cdstub_id}->add_track($track);
    }
}

sub update
{
    my ($self, $track_id, $hash) = @_;
    $self->sql->update_row('track_raw', $hash, { id => $track_id });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Robert Kaye

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
