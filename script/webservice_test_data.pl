#!/usr/bin/env perl

use FindBin;

my $root = $FindBin::Bin;


my $releasegroups = [
    'b84625af-6229-305f-9f1b-59c0185df016', # 7nin matsuri, pseudo-release test.
    '202cad78-a2e1-3fa7-b8bc-77c1f737e3da', # plone, bootleg vs official test.
    '22b54315-6e51-350b-bb34-e6e16f7688bd', # dj distance, multiple releases test.
    '56683a0b-45b8-3664-a231-5b68efe2e7e2', # dj distance, multiple releases test.
    '153f0a09-fead-3370-9b17-379ebd09446b', # m-flo, artist credit test.
    '23f421e7-431e-3e1d-bcbf-b91f5f7c5e2c', # boa, various-artists and relationships test.
    '86b4a630-4dd8-36f0-8bc9-e52fe7634320', # chris.su & skc, multiple artist rg and release
    'acc775e4-9b67-3828-a4a0-92df54273190', # An Andy C release on RAM records (artist-label ar)
    '7aec6fd9-25a6-3dce-b8fd-f93b3039bca6', # A release on frequency, label-label AR to RAM
    ];

my $cmd = "$root/release-group-sql-dump.pl $root/../t/sql/webservice.sql";

system ("$cmd ".join (" ", @$releasegroups));


