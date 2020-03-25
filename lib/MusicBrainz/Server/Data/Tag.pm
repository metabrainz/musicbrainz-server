package MusicBrainz::Server::Data::Tag;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Entity::Tag;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );
use Readonly;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';

Readonly my $TAG_CLOUD_CACHE_TIMEOUT => 60 * 60 * 24; # 24 hours

sub _type { 'tag' }

sub _table
{
    return 'tag LEFT JOIN genre USING (name)';
}

sub _id_column
{
    return 'tag.id';
}

sub _columns
{
    return 'tag.id, tag.name, genre.id as genre_id';
}

sub _column_mapping
{
    return {
        id        => 'id',
        name      => 'name',
        genre_id  => 'genre_id',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Tag';
}

sub get_by_name
{
    my ($self, $name) = @_;
    my @result = $self->_get_by_keys('name', $name);
    return $result[0];
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'tag', @objs);
}

sub get_cloud
{
    my ($self, $limit) = @_;

    my $cache = $self->c->cache('tag');
    my $data = $cache->get('tag_cloud');
    return $data if defined $data;

    $limit ||= 100;

    my $entity_tag_subqueries = join ' UNION ALL ', map {
        my $entity_type = $_;
        "(SELECT tag, sum(count) AS count FROM ${entity_type}_tag " .
        'GROUP BY tag ORDER BY sum(count) DESC LIMIT $1)'
    } entities_with('tags');

    my $query =
        'SELECT tag.id, tag.name, sum(entity_tag.count) AS summed_count ' .
        'FROM tag JOIN (' . $entity_tag_subqueries . ') entity_tag ' .
        'ON entity_tag.tag = tag.id ' .
        'GROUP BY tag.id, tag.name ' .
        'ORDER BY summed_count ' .
        'DESC LIMIT $1';

    $data = [$self->query_to_list($query, [$limit], sub {
        my ($model, $row) = @_;

        return {
            count => $row->{summed_count},
            tag => $self->_entity_class->new(
                id => $row->{id},
                name => $row->{name},
            ),
        };
    })];

    $cache->set('tag_cloud', $data, $TAG_CLOUD_CACHE_TIMEOUT);
    return $data;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

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
