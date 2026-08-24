package MusicBrainz::Server::Data::Link;

use Moose;
use namespace::autoclean;
use Sql;
use MusicBrainz::Server::Entity::Link;
use MusicBrainz::Server::Entity::LinkAttribute;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    load_subobjects
    non_empty
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';

sub _type { 'link' }

sub _table
{
    return 'link';
}

sub _build_columns
{
    return join q(, ), qw(
        id
        link_type
        begin_date_year
        begin_date_month
        begin_date_day
        end_date_year
        end_date_month
        end_date_day
        ended
    );
}

has '_columns' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_columns',
);

sub _column_mapping
{
    return {
        id         => 'id',
        type_id    => 'link_type',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, 'begin_date_') },
        end_date   => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, 'end_date_') },
        ended      => 'ended',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Link';
}

sub _load_attributes
{
    my ($self, $data, @ids) = @_;

    return unless @ids;

    my $rows = $self->sql->select_list_of_hashes(<<~'SQL', \@ids);
        SELECT link,
               attribute_type,
               attr_credit.credited_as,
               COALESCE(text_value, '') AS text_value
        FROM link_attribute
        LEFT OUTER JOIN link_attribute_text_value
                  USING (link, attribute_type)
        LEFT OUTER JOIN link_attribute_credit attr_credit
                  USING (link, attribute_type)
        WHERE link = any(?)
        ORDER BY link, attribute_type
        SQL

    return unless @$rows;

    my @attributes;
    for my $row (@$rows) {
        my $attribute = MusicBrainz::Server::Entity::LinkAttribute->new(
            type_id => $row->{attribute_type},
            credited_as => $row->{credited_as},
            text_value => $row->{text_value},
        );
        $data->{ $row->{link} }->add_attribute($attribute);
        push @attributes, $attribute;
    }

    $self->c->model('LinkAttributeType')->load(@attributes);

    return;
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

    push @conditions, 'link_type = ?';
    push @args, $values->{link_type_id};

    # end_date_implies_ended
    $values->{ended} = 1 if defined $values->{end_date} &&
        ($values->{end_date}->{year} ||
         $values->{end_date}->{month} ||
         $values->{end_date}->{day});

    $values->{ended} //= 0;

    push @conditions, 'ended = ?';
    push @args, $values->{ended};

    foreach my $date_key (qw( begin_date end_date )) {
        my $column_prefix = $date_key;
        foreach my $key (qw( year month day )) {
            if (non_empty($values->{$date_key}->{$key})) {
                push @conditions, "${column_prefix}_${key} = ?";
                push @args, $values->{$date_key}->{$key};
            } else {
                push @conditions, "${column_prefix}_${key} IS NULL";
            }
        }
    }

    my @attrs = @{ $values->{attributes} // [] };

    push @conditions, 'attribute_count = ?';
    push @args, scalar(@attrs);

    my $i = 1;
    foreach my $attr (@attrs) {
        push @joins, "JOIN link_attribute a$i ON a$i.link = link.id";

        if (non_empty($attr->{type}{id})) {
            push @conditions, "a$i.attribute_type = ?";
            push @args, $attr->{type}{id};
        } else {
            push @joins, "JOIN link_attribute_type lat$i ON lat$i.id = a$i.attribute_type";
            push @conditions, "lat$i.gid = ?";
            push @args, $attr->{type}{gid};
        }

        push @joins,
            "LEFT JOIN link_attribute_credit ac$i ON
               (a$i.attribute_type = ac$i.attribute_type
                  AND a$i.link = ac$i.link)";

        if (non_empty($attr->{credited_as})) {
            push @conditions, "ac$i.credited_as = ?";
            push @args, $attr->{credited_as};
        } else {
            push @conditions, "ac$i.credited_as IS NULL";
        }

        if (non_empty($attr->{text_value})) {
            push @joins, "JOIN link_attribute_text_value latv$i ON latv$i.link = link.id";
            push @conditions, "latv$i.attribute_type = ?", "latv$i.text_value = ?";
            push @args, $attr->{type}{id}, $attr->{text_value};
        }

        $i += 1;
    }

    my $query = 'SELECT link.id FROM link ' . join(' ', @joins) . ' WHERE ' . join(' AND ', @conditions);
    return $self->sql->select_single_value($query, @args);
}

sub find_or_insert
{
    my ($self, $values) = @_;

    my $id = $self->find($values);
    return $id if defined $id;

    my @attrs = @{ $values->{attributes} // [] };

    my $row = {
        link_type => $values->{link_type_id},
        attribute_count => scalar(@attrs),
        ended => $values->{ended},
    };
    add_partial_date_to_row($row, $values->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $values->{end_date}, 'end_date');
    $id = $self->sql->insert_row('link', $row, 'id');

    foreach my $attr (@attrs) {
        my $attribute_type = $attr->{type}{id};

        $self->sql->insert_row('link_attribute', {
            link           => $id,
            attribute_type => $attribute_type,
        });

        if (non_empty($attr->{credited_as})) {
            $self->sql->insert_row('link_attribute_credit', {
                attribute_type => $attribute_type,
                link => $id,
                credited_as => $attr->{credited_as},
            });
        }

        if (non_empty($attr->{text_value})) {
            $self->sql->insert_row('link_attribute_text_value', {
                link           => $id,
                attribute_type => $attribute_type,
                text_value     => $attr->{text_value},
            });
        }
    }

    return $id;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
