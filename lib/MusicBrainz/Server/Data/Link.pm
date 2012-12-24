package MusicBrainz::Server::Data::Link;

use Moose;
use namespace::autoclean;
use Sql;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    load_subobjects
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'link' };

sub _table
{
    return 'link';
}

sub _columns
{
    return 'id, link_type, begin_date_year, begin_date_month, begin_date_day,
            end_date_year, end_date_month, end_date_day, ended';
}

sub _column_mapping
{
    return {
        id         => 'id',
        type_id    => 'link_type',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, 'begin_date_') },
        end_date   => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, 'end_date_') },
        ended      => 'ended'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Link';
}

sub _load_attributes
{
    my ($self, $data, @ids) = @_;

    if (@ids) {
        my $query = "
            SELECT
                link,
                attr.id,
                attr.name AS name,
                root_attr.id AS root_id,
                root_attr.name AS root_name
            FROM link_attribute
                JOIN link_attribute_type AS attr ON attr.id = link_attribute.attribute_type
                JOIN link_attribute_type AS root_attr ON root_attr.id = attr.root
            WHERE link IN (" . placeholders(@ids) . ")
            ORDER BY link, attr.name";
        $self->sql->select($query, @ids);
        while (1) {
            my $row = $self->sql->next_row_hash_ref or last;
            my $id = $row->{link};
            if (exists $data->{$id}) {
                my $attr = MusicBrainz::Server::Entity::LinkAttributeType->new(
                    id => $row->{id},
                    name => $row->{name},
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        id => $row->{root_id},
                        name => $row->{root_name},
                    ),
                );
                $data->{$id}->add_attribute($attr);
            }
        }
        $self->sql->finish;
    }
}

sub get_by_ids
{
    my ($self, @ids) = @_;
    my $data = MusicBrainz::Server::Data::Entity::get_by_ids($self, @ids);
    $self->_load_attributes($data, @ids);
    return $data;
}

sub get_by_id
{
    my ($self, $id) = @_;
    my $obj = MusicBrainz::Server::Data::Entity::get_by_id($self, $id);
    if (defined $obj) {
        $self->_load_attributes({ $id => $obj }, $id);
    }
    return $obj;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'link', @objs);
}

sub find
{
    my ($self, $values) = @_;
    my (@joins, @conditions, @args);

    push @conditions, "link_type = ?";
    push @args, $values->{link_type_id};

    # end_date_implies_ended
    $values->{ended} = 1 if defined $values->{end_date} &&
        ($values->{end_date}->{year} ||
         $values->{end_date}->{month} ||
         $values->{end_date}->{day});

    push @conditions, "ended = ?";
    push @args, $values->{ended};

    foreach my $date_key (qw( begin_date end_date )) {
        my $column_prefix = $date_key;
        foreach my $key (qw( year month day )) {
            if (defined $values->{$date_key}->{$key}) {
                push @conditions, "${column_prefix}_${key} = ?";
                push @args, $values->{$date_key}->{$key};
            }
            else {
                push @conditions, "${column_prefix}_${key} IS NULL";
            }
        }
    }

    my @attrs = $values->{attributes} ? @{ $values->{attributes} } : ();

    push @conditions, "attribute_count = ?";
    push @args, scalar(@attrs);

    my $i = 1;
    foreach my $attr (@attrs) {
        push @joins, "JOIN link_attribute a$i ON a$i.link = link.id";
        push @conditions, "a$i.attribute_type = ?";
        push @args, $attr;
        $i += 1;
    }

    my $query = "SELECT id FROM link " . join(" ", @joins) . " WHERE " . join(" AND ", @conditions);
    return $self->sql->select_single_value($query, @args);
}

sub find_or_insert
{
    my ($self, $values) = @_;

    my $id = $self->find($values);
    return $id if defined $id;

    my @attrs = $values->{attributes} ? @{ $values->{attributes} } : ();

    my $row = {
        link_type      => $values->{link_type_id},
        attribute_count => scalar(@attrs),
        ended => $values->{ended}
    };
    add_partial_date_to_row($row, $values->{begin_date}, "begin_date");
    add_partial_date_to_row($row, $values->{end_date}, "end_date");
    $id = $self->sql->insert_row("link", $row, "id");

    foreach my $attr (@attrs) {
        $self->sql->insert_row("link_attribute", {
            link           => $id,
            attribute_type => $attr,
        });
    }

    return $id;
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
