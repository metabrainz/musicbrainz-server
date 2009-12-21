package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use List::MoreUtils qw( zip );
use MusicBrainz::Server::Entity::PartialDate;
use OSSP::uuid;
use Sql;
use Readonly;
use Storable;
use UNIVERSAL::require;

our @EXPORT_OK = qw(
    artist_credit_to_ref
    defined_hash
    hash_to_row
    deep_equal
    add_partial_date_to_row
    generate_gid
    insert_and_create
    generate_gid
    load_meta
    load_subobjects
    partial_date_from_row
    partial_date_to_hash
    placeholders
    query_to_list
    query_to_list_limited
    type_to_model
    order_by
);

Readonly my %TYPE_TO_MODEL => (
    'artist'        => 'Artist',
    'label'         => 'Label',
    'recording'     => 'Recording',
    'release'       => 'Release',
    'release_group' => 'ReleaseGroup',
    'url'           => 'URL',
    'work'          => 'Work',
);

sub artist_credit_to_ref
{
    my ($artist_credit) = @_;
    use Data::Dumper;
    my $ac = [ map {
        my @credit = ( { name => $_->name, artist => $_->artist_id } );
        push @credit, $_->join_phrase if $_->join_phrase;

        @credit;
    } @{ $artist_credit->names } ];
    return $ac;
}

sub load_subobjects
{
    my ($data_access, $attr_obj, @objs) = @_;
    my $attr_id = $attr_obj . "_id";
    my %ids = map { ($_->meta->find_attribute_by_name($attr_id)->get_value($_) || "") => 1 } @objs;
    my @ids = grep { $_ } keys %ids;
    my $data;
    if (@ids) {
        $data = $data_access->get_by_ids(@ids);
        foreach my $obj (@objs) {
            my $id = $obj->meta->find_attribute_by_name($attr_id)->get_value($obj);
            if (defined $id && exists $data->{$id}) {
                $obj->meta->find_attribute_by_name($attr_obj)->set_value($obj, $data->{$id});
            }
        }
    }
    return defined $data ? values %{$data} : ();
}

sub load_meta
{
    my ($c, $table, $builder, @objs) = @_;
    return unless @objs;
    my %id_to_obj = map { $_->id => $_ } @objs;
    my @ids = keys %id_to_obj;
    my $sql = Sql->new($c->mb->dbh);
    $sql->select("SELECT * FROM $table
                  WHERE id IN (" . placeholders(@ids) . ")", @ids);
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $id_to_obj{$row->{id}};
        $builder->($obj, $row);
    }
    $sql->finish;
}


sub partial_date_from_row
{
    my ($row, $prefix) = @_;
    my %info;
    $info{year} = $row->{$prefix . 'year'} if defined $row->{$prefix . 'year'};
    $info{month} = $row->{$prefix . 'month'} if defined $row->{$prefix . 'month'};
    $info{day} = $row->{$prefix . 'day'} if defined $row->{$prefix . 'day'};
    return MusicBrainz::Server::Entity::PartialDate->new(%info);
}

sub partial_date_to_hash
{
    my ($date) = @_;
    return {
        year => $date->year,
        month => $date->month,
        day => $date->day
    };
}

sub placeholders
{
    return join ",", ("?") x scalar(@_);
}

sub query_to_list
{
    my ($dbh, $builder, $query, @args) = @_;
    my $sql = Sql->new($dbh);
    $sql->select($query, @args);
    my @result;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    $sql->finish;
    return @result;
}

sub query_to_list_limited
{
    my ($dbh, $offset, $limit, $builder, $query, @args) = @_;
    my $sql = Sql->new($dbh);
    $sql->select($query, @args);
    my @result;
    while ($limit--) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    my $hits = $sql->row_count + $offset;
    $sql->finish;
    return (\@result, $hits);
}

sub insert_and_create
{
    my ($data, @objs) = @_;
    my $class = $data->_entity_class;
    $class->require;
    my $sql = Sql->new($data->c->mb->dbh);
    my %map = $data->_attribute_mapping;
    my @ret;
    for my $obj (@objs)
    {
        my %row = map { ($map{$_} || $_) => $obj->{$_} } keys %$obj;
        my $id = $sql->insert_row($data->_table, \%row, 'id');
        push @ret, $class->new( id => $id, %$obj);
    }

    return wantarray ? @ret : $ret[0];
}

sub generate_gid
{
    my $uuid = new OSSP::uuid;
    $uuid->make("v4");
    return $uuid->export("str");
}

sub defined_hash
{
    my %hash = @_;
    return map { $_ => $hash{$_} } grep { defined $hash{$_} } keys %hash;
}

sub hash_to_row
{
    my ($hash, $mapping) = @_;

    my %row;
    foreach my $db_key (keys %$mapping) {
        my $key = $mapping->{$db_key};
        if (exists $hash->{$key}) {
            $row{$db_key} = $hash->{$key};
        }
    }
    return \%row;
}

sub add_partial_date_to_row
{
    my ($row, $date, $prefix) = @_;

    if (defined $date) {
        foreach my $key (qw(year month day)) {
            if (exists $date->{$key}) {
                $row->{$prefix . '_' . $key} = $date->{$key};
            }
        }
    }
}

sub type_to_model
{
    return $TYPE_TO_MODEL{$_[0]} || undef;
}

sub order_by
{
    my ($order, $default, $map) = @_;

    my $order_by = $map->{$default};
    if ($order) {
        my $desc = 0;
        if ($order =~ /-(.*)/) {
            $desc = 1;
            $order = $1;
        }
        if (exists $map->{$order}) {
            $order_by = $map->{$order};
            if ($desc) {
                my @list = map { "$_ DESC" } split ',', $order_by;
                $order_by = join ',', @list;
            }
        }
    }
    return $order_by;
}

sub deep_equal {
    my ($a, $b) = @_;
    local $Storable::canonical = 1;
    return (Storable::freeze($a) eq Storable::freeze($b));
}

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
