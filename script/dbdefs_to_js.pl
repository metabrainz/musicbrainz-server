#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DBDefs;
use JSON;
use Readonly;

Readonly our @BOOLEAN_DEFS => qw(
    DEVELOPMENT_SERVER
);

Readonly our @HASH_DEFS => qw(
    DATASTORE_REDIS_ARGS
);

Readonly our @NUMBER_DEFS => qw(
    RENDERER_PORT
);

Readonly our @STRING_DEFS => qw(
    STATIC_RESOURCES_LOCATION
);

Readonly our @QW_DEFS => qw(
    MB_LANGUAGES
);

my $code = '';

for my $def (@BOOLEAN_DEFS) {
    my $value = DBDefs->$def;

    if (defined $value && $value eq '1') {
        $value = 'true';
    } else {
        $value = 'false';
    }

    $code .= "exports.$def = $value;\n";
}

my $json = JSON->new->allow_nonref->ascii->canonical;

for my $def (@HASH_DEFS, @NUMBER_DEFS, @STRING_DEFS) {
    my $value = DBDefs->$def;
    $value = $json->encode($value);
    $code .= "exports.$def = $value;\n";
}

for my $def (@QW_DEFS) {
    my @words = DBDefs->$def;
    my $value = $json->encode(join ' ', @words);
    $code .= "exports.$def = $value;\n";
}

my $js_path = "$FindBin::Bin/../root/static/scripts/common/DBDefs.js";
open(my $fh, '>', $js_path);
print $fh $code;
