#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package DBDefs::Default;

use File::Spec::Functions qw( splitdir catdir catfile tmpdir );
use Cwd qw( abs_path );
use JSON qw( encode_json );
use MusicBrainz::Server::Replication ':replication_type';
use String::ShellQuote qw( shell_quote );

################################################################################
# Directories
################################################################################

# The server root, i.e. the parent directory of admin, bin, lib, root, etc.
sub MB_SERVER_ROOT {
    my @splitfilename = splitdir(abs_path(__FILE__));
    my @parentdir = @splitfilename[0..(scalar @splitfilename - 4)];
    return catdir(@parentdir);
}
# Where static files are located
sub STATIC_FILES_DIR { my $self = shift; $self->MB_SERVER_ROOT . '/root/static' }

################################################################################
# The Database
################################################################################

# What type of server is this?
# * RT_MASTER - This is a master replication server.  Changes are allowed, and
#               they result in replication packets being produced.
# * RT_SLAVE  - This is a slave replication server.  After loading a snapshot
#               produced by a master, the only changes allowed are those made
#               by applying the next replication packet in turn.  If the slave
#               server is not going to be used for development work, change
#               DB_STAGING_SERVER to 0.
#
#               A READONLY database connection must be configured if you
#               choose RT_SLAVE, as well as the usual READWRITE.
# * RT_STANDALONE - This server neither generates nor uses replication
#               packets.  Changes to the database are allowed.
sub REPLICATION_TYPE { RT_STANDALONE }

# If you plan to use the RT_SLAVE setting (replicated data from MusicBrainz' Live Data Feed)
# you must sign in at https://metabrainz.org and generate an access token to access
# the replication packets. Enter the access token below:
# NOTE: DO NOT EXPOSE THIS ACCESS TOKEN PUBLICLY!
#
sub REPLICATION_ACCESS_TOKEN { "" }

################################################################################
# GPG Signature
################################################################################

# Location of the public key file to use for verifying packets.
sub GPG_PUB_KEY { "" }

# Define how validation deals with the missing signature file:
#   FAIL    - validation fails if signature file is missing
#   PASS    - validation passes if signature file is missing
sub GPG_MISSING_SIGNATURE_MODE { "PASS" }

# Key identifiers (compatible with --recipient in GPG) for
# signatures and encryption of data dumps and packets. Should
# only be required on the master server.
sub GPG_SIGN_KEY { "" }
sub GPG_ENCRYPT_KEY { "" }

################################################################################
# HTTP Server Names
################################################################################

# The host names used by the server.
# To use a port number other than 80, add it like so: "myhost:8000"
# Additionally you should set the environment variable
# MUSICBRAINZ_USE_PROXY=1 when using a reverse proxy to make the server
# aware of it when generating things like the canonical url in catalyst.
sub WEB_SERVER                { "localhost:5000" }
# Relevant only if SSL redirects are enabled
sub WEB_SERVER_SSL            { "localhost" }
sub SEARCH_SERVER             { "search.musicbrainz.org" }
sub SEARCH_ENGINE             { "SOLR" }
# Whether to use x-accel-redirect for webservice searches,
# using /internal/search as the internal redirect
sub SEARCH_X_ACCEL_REDIRECT   { 0 }
# Used, for example, to have emails sent from the beta server list the
# main server
sub WEB_SERVER_USED_IN_EMAIL  { my $self = shift; $self->WEB_SERVER }

# Used for automatic beta redirection. Enabled if BETA_REDIRECT_HOSTNAME
# is truthy.
sub IS_BETA                   { 0 }
sub BETA_REDIRECT_HOSTNAME    { '' }

# The base URI to use for JSON-LD (RDF) identifiers. Includes scheme.
sub JSON_LD_ID_BASE_URI       { "http://musicbrainz.org" }

# The server to use for rel="canonical" links. Includes scheme.
sub CANONICAL_SERVER          { "https://musicbrainz.org" }

# The server used to link to CritiqueBrainz users and reviews.
sub CRITIQUEBRAINZ_SERVER     { "https://critiquebrainz.org" }

# The URL where static resources are located, excluding the trailing slash.
sub STATIC_RESOURCES_LOCATION { '//' . shift->WEB_SERVER . '/static/build' }

################################################################################
# Mail Settings
################################################################################

sub SMTP_SERVER { "localhost" }

# This value should be set to some secret value for your server.  Any old
# string of stuff should do; something suitably long and random, like for
# passwords.  However you MUST change it from the default
# value (the empty string).  This is so an attacker can't just look in CVS and
# see the default secret value, and then use it to attack your server.

sub SMTP_SECRET_CHECKSUM { "" }
sub EMAIL_VERIFICATION_TIMEOUT { 604800 } # one week

################################################################################
# Server Settings
################################################################################

# Set this to 0 if this is the master MusicBrainz server or a slave mirror.
# Keeping this defined enables the banner that is shown across the top of each
# page, as well as some testing features that are only enabled when not on
# the live server.
sub DB_STAGING_SERVER { 1 }

# This description is shown in the banner when DB_STAGING_SERVER is enabled.
# If left empty the default value will be shown.
sub DB_STAGING_SERVER_DESCRIPTION { '' }

# Only change this if running a non-sanitized database on a staging server,
# e.g. http://beta.musicbrainz.org.
# * It shows a banner informing that 'all passwords have been reset to "mb"'.
# * It disables the IP lookup admin tool.
sub DB_STAGING_SERVER_SANITIZED { 1 }

# Testing features enable "Accept edit" and "Reject edit" links on edits,
# this should only be enabled on staging servers. Also, this enables non-admin
# users to edit user permissions.
sub DB_STAGING_TESTING_FEATURES { my $self = shift; $self->DB_STAGING_SERVER }

# SSL_REDIRECTS_ENABLED should be set to 1 on production.  It enables
# the "RequireSSL" attribute on Catalyst actions, which will redirect
# users to the SSL version of a Catalyst action (and redirect back to
# http:// after the action is complete, though only if the user
# started there).  If set to 0 no SSL redirects will be done, which is
# suitable for local or development deployments.
sub SSL_REDIRECTS_ENABLED { 0 }

# The user agent string sent via LWP to external services, e.g. the MediaWiki
# and CritiqueBrainz APIs.
sub LWP_USER_AGENT {
    my $self = shift;

    # Space at end causes LWP to append the default libwww-perl/X.X bits
    return 'musicbrainz-server/'. $self->DB_SCHEMA_SEQUENCE .' ('. $self->WEB_SERVER .') ';
}

################################################################################
# Documentation Server Settings
################################################################################
sub WIKITRANS_SERVER     { "wiki.musicbrainz.org" }

# The path to MediaWiki's api.php file. This is required to automatically
# determine which documentation pages need to be updated in the
# transclusion table.
sub WIKITRANS_SERVER_API { "wiki.musicbrainz.org/api.php" }

# To enable documentation search on your server, create your own Google Custom
# Search engine and enter its ID as the value of GOOGLE_CUSTOM_SEARCH.
# Alternatively, if you're okay with the search results pointing to
# the musicbrainz.org server, you can use '006539527923176875863:xsv3chs2ovc'.
sub GOOGLE_CUSTOM_SEARCH { '' }

################################################################################
# Cache Settings
################################################################################

# A namespace prefix to be applied to all items in all caches, whether for
# entities or user login sessions. Note that this is used by the default
# PLUGIN_CACHE_OPTIONS, CACHE_MANAGER_OPTIONS, and DATASTORE_REDIS_ARGS
# implementations; if you redefine those, CACHE_NAMESPACE will only be used if
# you use it in your own definitions.
sub CACHE_NAMESPACE { 'MB:' }

# PLUGIN_CACHE_OPTIONS are the options configured for Plugin::Cache.  $c->cache
# is provided by Plugin::Cache, and is required for HTTP Digest authentication
# in the webservice (Catalyst::Authentication::Credential::HTTP).
sub PLUGIN_CACHE_OPTIONS {
    my $self = shift;
    return {
        class => 'MusicBrainz::Server::CacheWrapper::Redis',
        server => '127.0.0.1:6379',
        namespace => $self->CACHE_NAMESPACE . 'Catalyst:',
    };
}

# The caching options here relate to object caching in Redis - such as for
# artists, releases, etc. in order to speed up queries.
sub CACHE_MANAGER_OPTIONS {
    my $self = shift;
    my %CACHE_MANAGER_OPTIONS = (
        profiles => {
            external => {
                class => 'MusicBrainz::Server::CacheWrapper::Redis',
                options => {
                    server => '127.0.0.1:6379',
                    namespace => $self->CACHE_NAMESPACE,
                },
            },
        },
        default_profile => 'external',
    );

    return \%CACHE_MANAGER_OPTIONS
}

# Sets the TTL for entities stored in Redis, in seconds. On slave servers,
# this is set to 1 hour by default, to mitigate MBS-8726. On standalone
# servers, this is set to 1 day; cache invalidation is already handled by the
# server in that case, so keys may be evicted sooner, but an upper limit is
# set in case the same Redis instance storing login sessions is being used
# (where no memory limit should be in place). In production, where separate
# Redis instances might be used to store sessions and cached entities, this
# can be set to 0 if there's already a memory limit configured for Redis.
sub ENTITY_CACHE_TTL {
    return 3600 if shift->REPLICATION_TYPE == RT_SLAVE;
    return 86400;
}

################################################################################
# Sessions (advanced)
################################################################################

# The session store holds user login sessions. Session::Store::MusicBrainz
# uses DATASTORE_REDIS_ARGS to connect to and store sessions in Redis.

sub SESSION_STORE { "Session::Store::MusicBrainz" }
sub SESSION_STORE_ARGS { return {} }
sub SESSION_EXPIRE { return 36000; } # 10 hours

# Redis by default has 16 numbered databases available, of which DB 0
# is the default.  Here you can configure which of these databases are
# used by musicbrainz-server.
#
# test_database will be completely erased on each test run, so make
# sure it doesn't point at any production data you may have in your
# redis server.

sub DATASTORE_REDIS_ARGS {
    my $self = shift;
    return {
        database => 0,
        namespace => $self->CACHE_NAMESPACE,
        server => '127.0.0.1:6379',
        test_database => 1,
    };
}

################################################################################
# Session cookies
################################################################################

# How long (in seconds) a web/rdf session can go "idle" before being timed out
sub WEB_SESSION_SECONDS_TO_LIVE { 3600 * 3 }

# The cookie name to use
sub SESSION_COOKIE { "AF_SID" }
# The domain into which the session cookie is written
sub SESSION_DOMAIN { undef }

################################################################################
# Other Settings
################################################################################

# Set this value to something true (e.g. 1) to set the server to read-only.
# To date, this option is widely ignored in the code; don't be surprised if you
# set it to true and find that writes are still possible.
sub DB_READ_ONLY { 0 }

# Set this value to a message that you'd like to display to users when
# they attempt to write to your read-only database (not used if DB_READ_ONLY
# is false)
sub DB_READ_ONLY_MESSAGE { <<EOF }
This server is temporarily in read-only mode
for database maintainance.
EOF

# Development server feature.
# Used to display which git branch is currently running along with information
# about the last commit
my $git_info = shell_quote(catfile(__PACKAGE__->MB_SERVER_ROOT, 'script/git_info'));
sub GIT_BRANCH { qx( $git_info branch ) }
sub GIT_MSG { qx( $git_info msg ) }
sub GIT_SHA { qx( $git_info sha ) }

# Amazon associate and developer ids
my %amazon_store_associate_ids = (
    'amazon.ca'         => 'music0b72-20',
    'amazon.co.jp'    => 'musicbrainzjp-22',
    'amazon.co.uk'    => 'music080d-21',
    'amazon.com'    => 'musicbrainz0d-20',
    'amazon.de'         => 'music059-21',
    'amazon.fr'         => 'music083d-21',
    'amazon.it'         => 'music084d-21',
    'amazon.es'         => 'music02e-21',
);

sub AWS_ASSOCIATE_ID
{
    shift;
    return keys %amazon_store_associate_ids if not @_;
    return $amazon_store_associate_ids{$_[0]};
}

sub AWS_PRIVATE { '' }
sub AWS_PUBLIC { '' }

sub AMAZON_ASSOCIATE_TAG { '' }

# To enable use of reCAPTCHA:
# 1. make sure $ENV{'REMOTE_ADDR'} is the ip address of the visitor.
# 2. replace undef with your recaptcha keys:
sub RECAPTCHA_PUBLIC_KEY { return undef }
sub RECAPTCHA_PRIVATE_KEY { return undef }

# internet archive private/public keys (for coverartarchive.org).
sub COVER_ART_ARCHIVE_ACCESS_KEY { };
sub COVER_ART_ARCHIVE_SECRET_KEY { };
sub COVER_ART_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf("//%s.s3.us.archive.org/", shift) };
sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "//coverartarchive.org" };
sub COVER_ART_ARCHIVE_IA_DOWNLOAD_PREFIX { '//archive.org/download' };
sub COVER_ART_ARCHIVE_IA_METADATA_PREFIX { 'https://archive.org/metadata' };

# Mapbox access token must be set to display area/place maps.
sub MAPBOX_MAP_ID { 'mapbox/streets-v11' }
sub MAPBOX_ACCESS_TOKEN { '' }

# Set to 26 for the following features:
#  * PKCE for OAuth 2.0 clients.
#    (admin/sql/updates/20200914-oauth-pkce.sql)
#  * recording_first_release_date table.
#    (admin/sql/updates/20201028-mbs-1424.sql)
sub ACTIVE_SCHEMA_SEQUENCE { 25 }

# Enable PKCE for OAuth 2.0 clients.
sub OAUTH2_ENABLE_PKCE { shift->ACTIVE_SCHEMA_SEQUENCE >= 26 }

# Disallow OAuth2 requests over plain HTTP
sub OAUTH2_ENFORCE_TLS { my $self = shift; !$self->DB_STAGING_SERVER }

sub USE_ETAGS { 1 }

sub CATALYST_DEBUG { 1 }

# If you are developing on MusicBrainz, you should set this to a true value
# This will turn off some optimizations (such as CSS/JS compression) to make
# developing and debugging easier
sub DEVELOPMENT_SERVER { 1 }

# How long to wait before rechecking template files (undef uses the
# Template::Toolkit default)
sub STAT_TTL { shift->DEVELOPMENT_SERVER() ? undef : 1200 }

# Please activate the officially approved languages here. Not every .po
# file is active because we might have fully translated languages which
# are not yet properly supported, like right-to-left languages
sub MB_LANGUAGES {qw()}

# Should the site fall back to browser settings when trying to set a language
# (note: will still only use languages in MB_LANGUAGES)
sub LANGUAGE_FALLBACK_TO_BROWSER{ 1 }

# Bugs can be sent to a Sentry instance (https://sentry.io) via these settings.
# The DSNs can be found on the project configuration page.
sub SENTRY_DSN { undef }
sub SENTRY_DSN_PUBLIC { undef }

# Configure which html validator should be used.  If you run tests
# often, you should probably run a local copy of the validator.  See
# http://about.validator.nu/#src for instructions.
sub HTML_VALIDATOR { 'http://validator.w3.org/nu/?out=json' }
# sub HTML_VALIDATOR { 'http://localhost:8888?out=json' }

# We use a small Node.js server (root/server.js) to render React.js
# templates. RENDERER_SOCKET configures the local (UNIX) socket path it
# listens on.
sub RENDERER_SOCKET {
    catfile(tmpdir, 'musicbrainz-template-renderer.socket')
}
# If FORK_RENDERER is set to a true value, MusicBrainz Server will fork and
# exec root/server.js automatically. TERM signals received by plackup will
# also be passed along to the renderer. Otherwise, it is assumed that the
# renderer was run manually and is already listening on RENDERER_SOCKET.
#
# This option is convenient for development servers.
#
# Note: FORK_RENDERER works fine when using plackup by itself, but does not
# play nicely with superdaemons such as Starman or Server::Starter that
# prefork worker processes. Signals are not passed through properly when
# using those, leaving duplicate, orphan renderer processes. Set
# FORK_RENDERER to '0' and start the renderer manually
# (./script/start_renderer.pl) when using a superdaemon.
sub FORK_RENDERER { 1 }

# Base URL of external Discourse instance.
sub DISCOURSE_SERVER { '' }
# Used to authenticate when synchronizing SSO records.
# See https://meta.discourse.org/t/discourse-api-documentation/22706
sub DISCOURSE_API_KEY { '' }
sub DISCOURSE_API_USERNAME { '' }
# See https://meta.discourse.org/t/official-single-sign-on-for-discourse/13045
sub DISCOURSE_SSO_SECRET { '' }

# Secret key used to generate nonce values in some contexts, e.g. CSRF tokens
# and CSP headers. Even without a secret set, the generated nonces are very
# unlikely to be guessed; this is mainly only useful for an additional layer
# of security on the MusicBrainz production site.
sub NONCE_SECRET { '' }

# When enabled, if Catalyst receives a request with an `mb-set-database`
# header, all database queries will go to the specified database instead of
# READWRITE, as defined in the DatabaseConnectionFactory->register_databases
# section of DBDefs.pm. This is only useful if you're running Selenium or
# Sitemaps tests locally.
#
# This defaults to the deprecated `USE_SELENIUM_HEADER` for backwards-
# compatibility.
sub USE_SET_DATABASE_HEADER { shift->USE_SELENIUM_HEADER }
sub USE_SELENIUM_HEADER { 0 }

# Used to create search indexes dump from SolrCloud.
sub SOLRCLOUD_COLLECTIONS_API { undef }
sub SOLRCLOUD_BACKUP_LOCATION { undef }
sub SOLRCLOUD_RSYNC_BANDWIDTH { undef }
sub SOLRCLOUD_SSH_CIPHER_SPEC { undef }
sub SEARCH_INDEXES_DUMP_COMPRESSION_LEVEL { undef }

sub WIKIMEDIA_COMMONS_IMAGES_ENABLED { 1 }

# On release browse endpoints in the webservice, we limit the number of
# releases returned such that the total number of tracks doesn't exceed this
# number.
sub WS_TRACK_LIMIT { 500 }

################################################################################
# Profiling
################################################################################
# Set these to >0 to enable profiling

# Log if a request in /ws takes more than x seconds
sub PROFILE_WEB_SERVICE { 0 }

# Log if a request in / (not /ws) takes more than x seconds
sub PROFILE_SITE { 0 }

# The maximum amount of time a process can be serving a single request. This
# function takes a Catalyst::Request as input, and should return the amount of time
# in seconds that it should take to respond to this request.
# If undef, the process is never killed.
sub DETERMINE_MAX_REQUEST_TIME { undef }

sub LOGGER_ARGUMENTS {
    return (
        outputs => [
            [ 'Screen', min_level => 'debug', newline => 1 ],
        ],
    )
}

1;
# eof DBDefs.pm
