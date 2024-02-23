#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../lib";

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Storable qw( nstore );

use MusicBrainz::Script::Utils qw( get_foreign_keys );
use MusicBrainz::Server::Context;

my $database = 'MAINTENANCE';
my $output_file = 'foreign_keys';
my $show_help = 0;

GetOptions(
    'database=s' => \$database,
    'output=s' => \$output_file,
    'help' => \$show_help,
) or exit 2;

pod2usage() if $show_help;

my $c = MusicBrainz::Server::Context->create_script_context(
    database => $database,
);

my $dbh = $c->sql->dbh;
my $table_info_sth = $dbh->table_info('%', '%', '%', 'TABLE');
my $foreign_keys = {};

for my $table_info (@{ $table_info_sth->fetchall_arrayref }) {
    my $schema = $table_info->[1];
    my $table = $table_info->[2];

    get_foreign_keys($dbh, 1, $schema, $table, $foreign_keys);
    get_foreign_keys($dbh, 2, $schema, $table, $foreign_keys);
}

nstore($foreign_keys, $output_file);

=head1 SYNOPSIS

Dumps foreign key information (suitable for use with
`MusicBrainz::Server::Role::FollowForeignKeys`) to a file.

This allows accessing such information on mirror servers,
for example.

Options:

    --help          show this help
    --database DB   database to read from
                    (default: MAINTENANCE)
    --output FILE   file to write to
                    (default: foreign_keys)

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
