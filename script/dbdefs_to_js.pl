#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DBDefs;
use JSON;
use Readonly;

my ($output_path) = @ARGV;

Readonly our @BOOLEAN_DEFS => qw(
    DB_READ_ONLY
    DB_STAGING_SERVER
    DEVELOPMENT_SERVER
    IS_BETA
);

Readonly our @HASH_DEFS => qw(
);

Readonly our @NUMBER_DEFS => qw(
    REPLICATION_TYPE
    STAT_TTL
);

Readonly our @STRING_DEFS => qw(
    BETA_REDIRECT_HOSTNAME
    CANONICAL_SERVER
    DB_STAGING_SERVER_DESCRIPTION
    GIT_BRANCH
    GIT_MSG
    GIT_SHA
    GOOGLE_ANALYTICS_CODE
    GOOGLE_CUSTOM_SEARCH
    MAPBOX_ACCESS_TOKEN
    MAPBOX_MAP_ID
    RENDERER_SOCKET
    SENTRY_DSN
    SENTRY_DSN_PUBLIC
    STATIC_RESOURCES_LOCATION
    WEB_SERVER
);

Readonly our @QW_DEFS => qw(
    MB_LANGUAGES
);

Readonly our %CLIENT_DEFS => (
    DEVELOPMENT_SERVER => 1,
    GIT_BRANCH => 1,
    GIT_SHA => 1,
    MAPBOX_ACCESS_TOKEN => 1,
    MAPBOX_MAP_ID => 1,
    MB_LANGUAGES => 1,
    SENTRY_DSN_PUBLIC => 1,
    STATIC_RESOURCES_LOCATION => 1,
);

sub get_value {
    my $def = shift;

    # Values can be overridden via the environment.
    $ENV{$def} // DBDefs->$def;
}

my $server_code = '';
my $client_code = '';

for my $def (@BOOLEAN_DEFS) {
    my $value = get_value($def);

    if (defined $value && $value eq '1') {
        $value = 'true';
    } else {
        $value = 'false';
    }

    my $line = "exports.$def = $value;\n";
    $server_code .= $line;
    $client_code .= $line if $CLIENT_DEFS{$def};
}

my $json = JSON->new->allow_nonref->ascii->canonical;

for my $def (@HASH_DEFS, @NUMBER_DEFS, @STRING_DEFS) {
    my $value = get_value($def);
    $value = $json->encode($value);
    my $line = "exports.$def = $value;\n";
    $server_code .= $line;
    $client_code .= $line if $CLIENT_DEFS{$def};
}

for my $def (@QW_DEFS) {
    my @words = get_value($def);
    my $value = $json->encode(join ' ', @words);
    my $line = "exports.$def = $value;\n";
    $server_code .= $line;
    $client_code .= $line if $CLIENT_DEFS{$def};
}

my $server_js_path = "$FindBin::Bin/../root/static/scripts/common/DBDefs.js";
my $client_js_path = ($server_js_path =~ s/\.js$/-client.js/r);

open(my $fh, '>', $server_js_path);
print $fh $server_code;
close $fh;

open($fh, '>', $client_js_path);
print $fh $client_code;
close $fh;
