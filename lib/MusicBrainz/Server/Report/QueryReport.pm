package MusicBrainz::Server::Report::QueryReport;
use Moose::Role;

with 'MusicBrainz::Server::Report';

requires 'query';

sub run {
    my ($self) = @_;

    my $qualified_table = $self->qualified_table;
    my $query = $self->query;

    $self->sql->do("DROP TABLE IF EXISTS $qualified_table");
    $self->sql->do(
        "SELECT s.*
         INTO $qualified_table
         FROM ( $query ) s"
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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

