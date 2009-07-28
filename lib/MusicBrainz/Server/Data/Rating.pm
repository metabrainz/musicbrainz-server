package MusicBrainz::Server::Data::Rating;

use Moose;
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use MusicBrainz::Server::Entity::Rating;

extends 'MusicBrainz::Server::Data::Entity';

has 'type' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

sub find_by_entity_id
{
    my ($self, $id) = @_;

    my $type = $self->type;
    my $query = "
        SELECT editor, rating FROM ${type}_rating_raw
        WHERE $type = ? ORDER BY rating DESC, editor";

    return query_to_list($self->c->raw_dbh, sub {
        my $row = $_[0];
        return MusicBrainz::Server::Entity::Rating->new(
            editor_id => $row->{editor},
            rating => $row->{rating},
        );
    }, $query, $id);
}

sub delete
{
    my ($self, @entity_ids) = @_;
    my $raw_sql = Sql->new($self->c->raw_dbh);
    $raw_sql->Do("
        DELETE FROM " . $self->type . "_rating_raw
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Rating

=head1 METHODS

=head2 delete(@entity_ids)

Delete ratings from the RAWDATA database for entities from @entity_ids.

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

