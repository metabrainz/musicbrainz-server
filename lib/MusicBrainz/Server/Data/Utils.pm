package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use Sql;
use MusicBrainz::Server::Entity::PartialDate;

our @EXPORT_OK = qw(
    partial_date_from_row
    placeholders
    load_subobjects
    query_to_list
    query_to_list_limited
    uniq
);

sub load_subobjects
{
    my ($data_access, $attr_obj, @objs) = @_;
    my $attr_id = $attr_obj . "_id";
    my %ids = map { $_->$attr_id => 1 } @objs;
    my @ids = grep { $_ } keys %ids;
    if (@ids) {
        my $data = $data_access->get_by_ids(@ids);
        foreach my $obj (@objs) {
            my $id = $obj->meta->get_attribute($attr_id)->get_value($obj);
            if (exists $data->{$id}) {
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

sub placeholders
{
    return join ",", ("?") x scalar(@_);
}

sub query_to_list
{
    my ($c, $builder, $query, @args) = @_;
    my $sql = Sql->new($c->mb->dbh);
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

sub uniq
{
    my %h = map { $_ => 1 } @_;
    return keys %h;
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
