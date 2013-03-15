#!/usr/bin/perl -w

use strict;
use warnings;

use Locale::PO;
use Clone qw( clone );
use File::Slurp qw( read_dir );

for my $file (map { './' . $_ } grep { /^mb_server\..*\.po$/ } read_dir('.')) {
    my $aref = Locale::PO->load_file_asarray($file);

    my @strings = ("(none)");

    my @new;
    for my $po (@$aref) {
        if (grep { '"' . $_ . '"' eq $po->msgid } @strings) {
            my $tag_clone = clone($po);
            my $type_clone = clone($po);
            my $email_clone = clone($po);
            my $description_clone = clone($po);
            my $lt_clone = clone($po);
            my $lp_clone = clone($po);
            my $changes_clone = clone($po);
            $po->msgctxt('comment');

            $tag_clone->msgctxt('tag');
            $type_clone->msgctxt('type');
            $email_clone->msgctxt('email');
            $description_clone->msgctxt('description');
            $lt_clone->msgctxt('link type');
            $lp_clone->msgctxt('link phrase');
            $changes_clone->msgctxt('annotation changes');
            push @new, ($tag_clone, $type_clone, $email_clone,
                        $description_clone, $lt_clone, $lp_clone, $changes_clone);
        }
    }

    push @$aref, @new;

    Locale::PO->save_file_fromarray($file,$aref);
}
