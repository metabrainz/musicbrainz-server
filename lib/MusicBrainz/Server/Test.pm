package MusicBrainz::Server::Test;

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Database;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Replication ':replication_type';
use Sql;

MusicBrainz::Server::Database->profile("test");

sub create_test_context
{
    my $cache_manager = MusicBrainz::Server::CacheManager->new(
        profiles => {
            null => {
                class => 'Cache::Null',
                wrapped => 1,
            },
        },
        default_profile => 'null',
    );
    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager);
}

sub _load_query
{
    my ($class, $query, $default) = @_;

    if (defined $query) {
        if ($query =~ /^\+/) {
            my $file_name = "<t/sql/" . substr($query, 1) . ".sql";
            open(FILE, $file_name) or die "Could not open $file_name";
            $query = do { local $/; <FILE> };
        }
    }
    else {
        open(FILE, "<" . $default);
        $query = do { local $/; <FILE> };
    }

    return $query;
}

sub prepare_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "admin/sql/InsertTestData.sql");

    my $sql = Sql->new($c->dbh);
    $sql->AutoCommit(1);
    $sql->Do($query);
}

sub prepare_raw_test_database
{
    my ($class, $c, $query) = @_;

    $query = $class->_load_query($query, "t/sql/clean_raw_db.sql");

    my $sql = Sql->new($c->raw_dbh);
    $sql->AutoCommit(1);
    $sql->Do($query);
}

sub prepare_test_server
{
    no warnings 'redefine';
    *DBDefs::_RUNNING_TESTS = sub { 1 };
    *DBDefs::REPLICATION_TYPE = sub { RT_STANDALONE };
}

sub get_latest_edit
{
    my ($class, $c) = @_;
    my $ed = MusicBrainz::Server::Data::Edit->new(c => $c);
    my $sql = Sql->new($c->raw_dbh);
    my $last_id = $sql->SelectSingleValue("SELECT id FROM edit ORDER BY ID DESC LIMIT 1") or return;
    return $ed->get_by_id($last_id);
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
