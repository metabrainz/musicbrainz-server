package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use Sql;
use MusicBrainz::Server::Entity::PartialDate;

our @EXPORT_OK = qw( partial_date_from_row placeholders query_to_list );

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
