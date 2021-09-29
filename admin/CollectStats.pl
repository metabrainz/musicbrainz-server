#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MusicBrainz::Server::Context;
use Sql;
use Getopt::Long;

my $output_file;
GetOptions(
    "output-file=s"                => \$output_file,
) or exit 2;

my $c = MusicBrainz::Server::Context->create_script_context;
my $sql = Sql->new($c->conn);

$sql->begin;
$c->model('Statistics')->recalculate_all($output_file);
$sql->commit;

if (-t STDOUT && !$output_file)
{
    my $all = $c->model('Statistics')->fetch;
    printf "%10d : %s\n", $all->{$_}, $_
        for sort keys %$all;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
