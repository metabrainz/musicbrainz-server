package MusicBrainz::Server::Report;
use Moose;

use Sql;

has 'c' => ( is => 'ro' );

sub gather_data
{
    die 'Not implemented.';
}

sub gather_data_from_query
{
    my ($self, $writer, $query, $args, $filter) = @_;
    $args ||= [];

    my $sql = $self->c->sql;
    $sql->select($query, @$args);
    while (my $row = $sql->next_row_hash_ref) {
        next if $filter and not($row = &$filter($row));
        $writer->Print($row);
    }
    $sql->finish;
}

sub run
{
    my ($self, $writer) = @_;

    $self->gather_data($writer);
}

sub post_load
{
}

sub filter_by_artists
{
}

sub template
{
    die 'Not implemented.';
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
