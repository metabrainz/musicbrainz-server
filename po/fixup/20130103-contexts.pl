#!/usr/bin/perl -w

use strict;
use warnings;

use Locale::PO;
use Clone qw( clone );
use File::Slurp qw( read_dir );

for my $file (map { './' . $_ } grep { /^mb_server\..*\.po$/ } read_dir('.')) {
    my $aref = Locale::PO->load_file_asarray($file);

    my @strings = ("Attach CD TOC", "Guess case", "Add Artist", "Add Label", "Add Release Group", "Add Release", "Add Standalone Recording", "Add Work", "Add ISRC", "Add Cover Art", "Reorder Cover Art");

    my @new;
    for my $po (@$aref) {
        if (grep { '"' . $_ . '"' eq $po->msgid } @strings) {
            my $clone = clone($po);
            $clone->msgctxt('header');
            $po->msgctxt('button/menu');
            push @new, $clone;
        }
    }

    push @$aref, @new;

    Locale::PO->save_file_fromarray($file,$aref);
}
