package MusicBrainz::Server::Data::Link;

use Moose;
use Sql;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Data::Utils qw(
    partial_date_from_row
    load_subobjects
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'link';
}

sub _columns
{
    return 'id, link_type, begindate_year, begindate_month, begindate_day,
            enddate_year, enddate_month, enddate_day';
}

sub _column_mapping
{
    return {
        id         => 'id',
        type_id    => 'link_type',
        begin_date => sub { partial_date_from_row(shift, 'begindate_') },
        end_date   => sub { partial_date_from_row(shift, 'enddate_') },
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Link';
}

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $data = MusicBrainz::Server::Data::Entity::get_by_ids($self, @ids);
    if (@ids) {
        my $query = "
            SELECT link, attr.name AS value, root_attr.name
            FROM link_attribute
                JOIN link_attribute_type AS attr ON attr.id = link_attribute.attribute_type
                JOIN link_attribute_type AS root_attr ON root_attr.id = attr.root
            WHERE link IN (" . placeholders(@ids) . ")
            ORDER BY link, attr.name";
        my $sql = Sql->new($self->c->mb->dbh);
        $sql->Select($query, @ids);
        while (1) {
            my $row = $sql->NextRowHashRef or last;
            my $id = $row->{link};
            if (exists $data->{$id}) {
                $data->{$id}->add_attribute(lc $row->{name}, lc $row->{value});
            }
        }
        $sql->Finish;
    }
    return $data;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'link', @objs);
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
