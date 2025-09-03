#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DBDefs;
use JSON;
use Readonly;

use MusicBrainz::Server::DatabaseConnectionFactory;

Readonly our @BOOLEAN_DEFS => qw(
    DB_READ_ONLY
    DB_STAGING_SERVER
    DB_STAGING_SERVER_SANITIZED
    DB_STAGING_TESTING_FEATURES
    DEVELOPMENT_SERVER
    DISABLE_IMAGE_EDITING
    IS_BETA
    WIKIMEDIA_COMMONS_IMAGES_ENABLED
);

Readonly our @NUMBER_DEFS => qw(
    ACTIVE_SCHEMA_SEQUENCE
    REPLICATION_TYPE
    STAT_TTL
);

Readonly our @STRING_DEFS => qw(
    BETA_REDIRECT_HOSTNAME
    CANONICAL_SERVER
    CRITIQUEBRAINZ_SERVER
    DB_STAGING_SERVER_DESCRIPTION
    GIT_BRANCH
    GIT_MSG
    GIT_SHA
    GOOGLE_CUSTOM_SEARCH
    MAPBOX_ACCESS_TOKEN
    MAPBOX_MAP_ID
    MB_SERVER_ROOT
    MTCAPTCHA_PUBLIC_KEY
    RENDERER_SOCKET
    SENTRY_DSN
    SENTRY_DSN_PUBLIC
    STATIC_RESOURCES_LOCATION
    WEB_SERVER
    WIKITRANS_SERVER
);

Readonly our @QW_STRING_DEFS => qw(
    MB_LANGUAGES
);

Readonly our %CLIENT_DEFS => (
    CRITIQUEBRAINZ_SERVER => 1,
    DB_STAGING_TESTING_FEATURES => 1,
    DEVELOPMENT_SERVER => 1,
    DISABLE_IMAGE_EDITING => 1,
    GIT_BRANCH => 1,
    GIT_SHA => 1,
    MAPBOX_ACCESS_TOKEN => 1,
    MAPBOX_MAP_ID => 1,
    MB_LANGUAGES => 1,
    MTCAPTCHA_PUBLIC_KEY => 1,
    SENTRY_DSN_PUBLIC => 1,
    STATIC_RESOURCES_LOCATION => 1,
    WEB_SERVER => 1,
    WIKITRANS_SERVER => 1,
);

my @conversions = (
    {
        defs => \@BOOLEAN_DEFS,
        convert => sub { shift ? \\1 : \\0 },
        flowtype => 'boolean',
    },
    {
        defs => \@NUMBER_DEFS,
        convert => sub { \(0 + (shift // 0)) },
        flowtype => 'number',
    },
    {
        defs => \@STRING_DEFS,
        convert => sub { \('' . (shift // '')) },
        flowtype => 'string',
    },
    {
        defs => \@QW_STRING_DEFS,
        convert => sub { \[map { '' . ($_ // '') } @_] },
        flowtype => '$ReadOnlyArray<string>',
    },
    {
        defs => ['DATABASES'],
        convert => sub {
            my ($databases) = @_;

            my %conversion = map {
                my $db = $databases->{$_};
                ($_ => {
                    user => '' . ($db->username // ''),
                    password => '' . ($db->password // ''),
                    database => '' . ($db->database // ''),
                    host => '' . ($db->host // ''),
                    port => 0 + ($db->port // 0),
                })
            } keys %{$databases};

            return \\%conversion;
        },
        flowtype => (
            '{' .
                '+[name: string]: {' .
                    '+database: string, ' .
                    '+host: string, ' .
                    '+password: string, ' .
                    '+port: number, '.
                    '+user: string'.
                '}' .
            '}'
        ),
    },
);

sub get_value {
    my $def = shift;

    if ($def eq 'DATABASES') {
        return \%MusicBrainz::Server::DatabaseConnectionFactory::databases;
    }

    # Values can be overridden via the environment.
    $ENV{$def} // DBDefs->$def;
}

my $json = JSON->new->allow_nonref->ascii->canonical;
my $server_code = "// \@flow strict\n";
my $client_code = "// \@flow strict\n";
my $browser_code = <<'EOF';
// @flow strict

/*
 * window[GLOBAL_JS_NAMESPACE].DBDefs contains the values exported by
 * DBDefs-client.mjs.
 * See root/layout/components/globalsScript.mjs for more info.
 *
 * This file should not be imported directly. It's substituted for
 * ./DBDefs-client.mjs via the NormalModuleReplacementPlugin in
 * webpack/browserConfig.js.
 */

const DBDefs = window[GLOBAL_JS_NAMESPACE].DBDefs;
EOF

for my $conversion (@conversions) {
    my ($defs, $convert, $flowtype) = @{$conversion}{qw(defs convert flowtype)};

    for my $def (@$defs) {
        my @raw_value = get_value($def);
        my $json_value = $json->encode(${$convert->(@raw_value)});
        my $line = "export const $def/*: $flowtype */ = $json_value;\n";
        $server_code .= $line;
        if ($CLIENT_DEFS{$def}) {
            $client_code .= $line;
            my $browser_line  = "export const $def = DBDefs.$def;\n";
            $browser_code .= $browser_line;
        }
    }
}

my $common_dir = "$FindBin::Bin/../root/static/scripts/common";
my $server_js_path = "$common_dir/DBDefs.mjs";
my $client_js_path = "$common_dir/DBDefs-client.mjs";
my $browser_js_path = "$common_dir/DBDefs-client-browser.mjs";

open(my $fh, '>', $server_js_path);
print $fh $server_code;
close $fh;

open($fh, '>', $client_js_path);
print $fh $client_code;
close $fh;

open($fh, '>', $browser_js_path);
print $fh $browser_code;
close $fh;
