package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use List::MoreUtils qw( zip );
use MusicBrainz::Server::Entity::PartialDate;
use OSSP::uuid;
use Sql;
use UNIVERSAL::require;

our @EXPORT_OK = qw(
    artist_credit_to_ref
    defined_hash
    generate_gid
    insert_and_create
    generate_gid
    load_subobjects
    partial_date_from_row
    partial_date_to_hash
    placeholders
    query_to_list
    query_to_list_limited
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
    my %ids = map { ($_->meta->get_attribute($attr_id)->get_value($_) || "") => 1 } @objs;
    my @ids = grep { $_ } keys %ids;
    if (@ids) {
        my $data = $data_access->get_by_ids(@ids);
        foreach my $obj (@objs) {
            my $id = $obj->meta->get_attribute($attr_id)->get_value($obj);
            if (defined $id && exists $data->{$id}) {
                $obj->meta->get_attribute($attr_obj)->set_value($obj, $data->{$id});
            }
        }
    }
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
        defined_hash(
                year => $date->year,
                month => $date->month,
                day => $date->day
        )
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
    $sql->Select($query, @args);
    my @result;
    while (1) {
        my $row = $sql->NextRowHashRef or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    $sql->Finish;
    return @result;
}

sub query_to_list_limited
{
    my ($c, $offset, $limit, $builder, $query, @args) = @_;
    my $sql = Sql->new($c->mb->dbh);
    $sql->Select($query, @args);
    my @result;
    while ($limit--) {
        my $row = $sql->NextRowHashRef or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    my $hits = $sql->Rows + $offset;
    $sql->Finish;
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
        my $id = $sql->InsertRow($data->_table, \%row, 'id');
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
