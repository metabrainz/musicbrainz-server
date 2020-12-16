#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DBDefs;
use JSON;
use Readonly;

use MusicBrainz::Server::DatabaseConnectionFactory;

my ($output_path) = @ARGV;

Readonly our @BOOLEAN_DEFS => qw(
    DB_READ_ONLY
    DB_STAGING_SERVER
    DB_STAGING_SERVER_SANITIZED
    DB_STAGING_TESTING_FEATURES
    DEVELOPMENT_SERVER
    IS_BETA
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
    GIT_BRANCH => 1,
    GIT_SHA => 1,
    MAPBOX_ACCESS_TOKEN => 1,
    MAPBOX_MAP_ID => 1,
    MB_LANGUAGES => 1,
    SENTRY_DSN_PUBLIC => 1,
    STATIC_RESOURCES_LOCATION => 1,
    WEB_SERVER => 1,
    WIKITRANS_SERVER => 1,
);

my @conversions = (
    {
        defs => \@BOOLEAN_DEFS,
        convert => sub { shift ? \\1 : \\0 },
    },
    {
        defs => \@NUMBER_DEFS,
        convert => sub { \(0 + shift) },
    },
    {
        defs => \@STRING_DEFS,
        convert => sub { \('' . shift) },
    },
    {
        defs => \@QW_STRING_DEFS,
        convert => sub { \[map { '' . $_ } @_] },
    },
    {
        defs => ['DATABASES'],
        convert => sub {
            my ($databases) = @_;

            my %conversion = map {
                my $db = $databases->{$_};
                ($_ => {
                    user => $db->username,
                    password => $db->password,
                    database => $db->database,
                    host => $db->host,
                    port => $db->port,
                })
            } keys %{$databases};

            return \\%conversion;
        },
    }
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
my $server_code = '';
my $client_code = '';

for my $conversion (@conversions) {
    my ($defs, $convert) = @{$conversion}{qw(defs convert)};

    for my $def (@$defs) {
        my @raw_value = get_value($def);
        my $json_value = \undef;

        if (defined $raw_value[0]) {
            $json_value = $convert->(@raw_value);
        }

        $json_value = $json->encode(${$json_value});

        my $line = "exports.$def = $json_value;\n";
        $server_code .= $line;
        $client_code .= $line if $CLIENT_DEFS{$def};
    }
}

my $common_dir = "$FindBin::Bin/../root/static/scripts/common";
my $server_js_path = "$common_dir/DBDefs.js";
my $client_json_path = "$common_dir/DBDefs-client-values.js";

open(my $fh, '>', $server_js_path);
print $fh $server_code;
close $fh;

open($fh, '>', $client_json_path);
print $fh $client_code;
close $fh;
