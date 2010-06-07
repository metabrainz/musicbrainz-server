#!/usr/bin/env perl

use FindBin;

my $root = $FindBin::Bin;


my $releasegroups = [
    '370fb2f6-9f43-3933-b089-8a6b4f92d7df', # pokemon ost, use for translation AR test.
    '79e3ac21-8359-3761-ba35-251a1bd04d68', # !!!, use in alias testing.
    '202cad78-a2e1-3fa7-b8bc-77c1f737e3da', # plone, bootleg vs official test.
    '22b54315-6e51-350b-bb34-e6e16f7688bd', # dj distance, multiple releases test
    '56683a0b-45b8-3664-a231-5b68efe2e7e2', # dj distance, multiple releases test
    ];

my $cmd = "$root/release-group-sql-dump.pl $root/../t/sql/webservice.sql";

system ("$cmd ".join (" ", @$releasegroups));


