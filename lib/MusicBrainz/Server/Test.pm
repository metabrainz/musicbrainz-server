package MusicBrainz::Server::Test;

use MusicBrainz;
use MusicBrainz::Server::Database;
use Sql;

MusicBrainz::Server::Database->profile("test");

sub prepare_test_database
{
    my ($class, $c) = @_;

    my $mb = $c->mb;

    open(FILE, "<admin/sql/InsertTestData.sql");
    my $test_data_query = do { local $/; <FILE> };

    my $sql = Sql->new($mb->{dbh});
    $sql->AutoCommit(1);
    $sql->Do($test_data_query);
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
