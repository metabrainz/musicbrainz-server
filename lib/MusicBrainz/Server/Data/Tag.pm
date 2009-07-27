package MusicBrainz::Server::Data::Tag;
use Moose;

use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Entity::AggregatedTag;
use MusicBrainz::Server::Entity::Tag;
use Sql;

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

has [qw( tag_table type )] => (
    isa => 'Str',
    is => 'rw'
);

sub find_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    $offset ||= 0;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ?" .
                "ORDER BY entity_tag.count DESC OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row($_[0]) },
        $query, $entity_id, $offset);
}

sub find_top_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ? " .
                "ORDER BY entity_tag.count DESC LIMIT ?";
    return query_to_list($self->c->dbh, sub { $self->_new_from_row($_[0]) },
                         $query, $entity_id, $limit);
}

sub _new_from_row
{
    my ($self, $row) = @_;
    MusicBrainz::Server::Entity::AggregatedTag->new(
        count => $row->{count},
        tag => MusicBrainz::Server::Entity::Tag->new(
            name => $row->{name},
        ),
    );
}

sub delete
{
    my ($self, @entity_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    $sql->Do("
        DELETE FROM " . $self->tag_table . "
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    my $raw_sql = Sql->new($self->c->raw_dbh);
    $raw_sql->Do("
        DELETE FROM " . $self->tag_table . "_raw
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    return 1;
}

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Tag

=head1 METHODS

=head2 delete(@entity_ids)

Delete tags for entities from @entity_ids.

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
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
