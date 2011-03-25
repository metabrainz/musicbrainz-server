#!/usr/bin/perl -w

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use File::Basename qw( basename );
use File::Temp qw( tempdir );
use File::Path qw( rmtree mkpath );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::ReportFactory;
use MusicBrainz::Server::PagedReport;
use DBDefs;
$| = 1;

@ARGV = "^" if not @ARGV;

my $outputdir = &DBDefs::MB_SERVER_ROOT . "/data/reports";

if (not -d $outputdir) {
    mkpath $outputdir
        or die "mkdir: $!\n";
}

my $errors = 0;

my $c = MusicBrainz::Server::Context->create_script_context();

for my $name (MusicBrainz::Server::ReportFactory->all_report_names) {
    my $output = "$outputdir/$name";

    unless (grep { $name =~ /$_/i } @ARGV) {
        print localtime() . " : Not running $name\n";
        next;
    }

    my $tempdir = tempdir(DIR => $outputdir, CLEANUP => 1);
    if (not $tempdir) {
        warn "tempdir: $!\n";
        ++$errors;
        next;
    }
    if (not -w "$tempdir") {
        warn "Can't write to $tempdir!\n";
        ++$errors;
        next;
    }

    my $report = MusicBrainz::Server::ReportFactory->create_report($name, $c);
    my $writer = MusicBrainz::Server::PagedReport->Save("$tempdir/$name");

    print localtime() . " : Running $name (in $tempdir)\n";
    my $t0 = time;
    eval {
        $report->run($writer);
    };
    if ($@) {
        warn "$name died with $@\n";
        ++$errors;
        rmtree($tempdir);
        next;
    }
    my $t = time() - $t0;

    $writer->End;

    my $size = 0;
    $size += -s($_) for glob("$tempdir/*");
    $size ||= "unknown";
    print localtime() . " : $name finished; time=$t size=$size\n";

    unless (chmod 0755, $tempdir) {
        warn "chmod $tempdir: $!\n";
        ++$errors;
    }

    if (-d $output and not rmtree($output)) {
        warn "Failed to remove existing directory $output: $!\n";
        ++$errors;
        next;
    }

    unless (rename $tempdir, $output) {
        warn "Failed to rename $tempdir to $output: $!\n";
        ++$errors;
        rmtree($tempdir);
        next;
    }

    print localtime() . " : $name successfully swapped in\n";
}

print localtime() . " : Completed with 1 error\n" if $errors == 1;
print localtime() . " : Completed with $errors errors\n" if $errors != 1;
exit($errors ? 1 : 0);

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 1998 Robert Kaye

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
