package MusicBrainz::Server::Data::CDStub;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::Entity';

use Readonly;
Readonly my $LIMIT_TOP_CDSTUBS => 1000;


sub _table
{
    return 'release_raw';
}

sub _columns
{
    return 'id, title, artist, added, lastmodified, lookupcount, modifycount, source, barcode, comment';
}

sub _column_mapping
{
    return {
        id => 'id',
        title => 'title',  
        artist => 'artist',
        date_added=> 'added',
        last_modified => 'lastmodified',
        lookup_count => 'lookupcount',
        modify_count => 'modifycount',
        source => 'source',
        barcode => 'barcode',
        comment => 'comment',
        discid => 'discid'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStub';
}

sub _dbh
{
    return shift->c->raw_dbh;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release', @objs);
}

sub load_top_cdstubs
{
    my ($self, $limit, $offset) = @_;
    my $query = "SELECT release_raw." . $self->_columns . ", discid
                 FROM " . $self->_table . ", cdtoc_raw 
                 WHERE release_raw.id = cdtoc_raw.release
                 ORDER BY lookupcount desc, modifycount DESC 
                 OFFSET ?
                 LIMIT  ?";
    return query_to_list_limited(
        $self->c->raw_dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $offset || 0, $LIMIT_TOP_CDSTUBS - $offset);
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
