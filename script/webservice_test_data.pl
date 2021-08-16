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
    '22ca85ec-ee39-3895-aef9-dee5d5c2f4d6', # Surrender, chemical brothers - lots of ARs
    '961c672c-7a3f-30c1-9e44-4e3ab02affd5', # Make it hot, sampled on Music:Response - Surrender
    '9b5006e5-b276-3a05-bcdd-8d986842320b', # House of the Holy on Atlantic
    '3e38adc0-bb7d-39d1-a811-7ce6db5d869d', # Recipe for hate, published by Atlantic
    'd3cad1a9-9173-3f9f-b853-bd0852ceae1a', # Future sound of Budapest, has SKC & Bratwa for artist/artist AR
    'a4d2a86c-bbd6-352b-b9fa-f9da86df842c', # Something on MCA to get a recording/label AR
    'a8c946f5-8d26-3534-bab7-37c57eebbc1c', # Should have recording url ARs
    'cde61708-3be3-31ad-ba61-06af6af59565',
    '04ba5879-e3ac-3cba-8a69-ee7da8ad8c4c', # These provide recording/release ARs
];

my $cmd = "$root/release-group-sql-dump.pl $root/../t/sql/webservice.sql";

system ("$cmd ".join (' ', @$releasegroups));


