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

use Class::MOP;
use File::Spec::Functions qw( splitdir catdir );
use Cwd qw( abs_path );
use MusicBrainz::Server::Replication ':replication_type';
use MusicBrainz::Server::Translation 'l';

sub get_environment_hash {
    my $export = { map { $_->name => $_ } Class::MOP::Class->initialize('DBDefs')->get_all_methods('CODE') };

    my %exclude = map { $_ => 1 }
        qw( COVER_ART_ARCHIVE_UPLOAD_PREFIXER DOES get_environment_hash );

    return {
        map { $_ => join(',', grep { defined } $export->{$_}->body->('DBDefs')) }
        grep { !exists $exclude{$_} } grep { /^[A-Z]+(_[A-Z]+)*$/ } keys %$export
    };
}

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
sub LUCENE_SERVER             { "search.musicbrainz.org" }
# Whether to use x-accel-redirect for webservice searches,
# using /internal/search as the internal redirect
sub LUCENE_X_ACCEL_REDIRECT   { 0 }
# Used, for example, to have emails sent from the beta server list the
# main server
sub WEB_SERVER_USED_IN_EMAIL  { my $self = shift; $self->WEB_SERVER }

# Used for automatic beta redirection. Enabled if BETA_REDIRECT_HOSTNAME
# is truthy.
sub IS_BETA                   { 0 }
sub BETA_REDIRECT_HOSTNAME    { '' }

# The server to use for rel="canonical" links. Includes scheme.
sub CANONICAL_SERVER          { "https://musicbrainz.org" }

# The server used to link to CritiqueBrainz users and reviews.
sub CRITIQUEBRAINZ_SERVER     { "https://critiquebrainz.org" }

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
# If left undefined the default value will be shown.
# Several predefined constants can be used (set to e.g. shift->NAME_OF_CONSTANT
# Defaults to DB_STAGING_SERVER_DESCRIPTION_DEFAULT
sub DB_STAGING_SERVER_DESCRIPTION_DEFAULT { l('This is a MusicBrainz development server.') }
sub DB_STAGING_SERVER_DESCRIPTION_BETA { l('This beta test server allows testing of new features with the live database.') }
sub DB_STAGING_SERVER_DESCRIPTION { shift->DB_STAGING_SERVER_DESCRIPTION_DEFAULT }

# Only change this if running a non-sanitized database on a dev server,
# e.g. http://test.musicbrainz.org.
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

# MEMCACHED_SERVERS allows configuration of global memcached servers, if more
# close configuration is not required
sub MEMCACHED_SERVERS { return ['127.0.0.1:11211']; };

# MEMCACHED_NAMESPACE allows configuration of a global memcached namespace, if
# more close configuration is not required
sub MEMCACHED_NAMESPACE { return 'MB:'; };

# PLUGIN_CACHE_OPTIONS are the options configured for Plugin::Cache.  $c->cache
# is provided by Plugin::Cache, and is required for HTTP Digest authentication
# in the webservice (Catalyst::Authentication::Credential::HTTP).
#
# Using Cache::Memory is good for a development environment, but is likely not
# suited for production.  Use something like memcached in a production setup.
#
# If you want to use something such as Memcached, the settings here should be
# the same as the settings you use for the session store.
#
sub PLUGIN_CACHE_OPTIONS {
    my $self = shift;
    return {
        class => "Cache::Memcached::Fast",
        servers => $self->MEMCACHED_SERVERS(),
        namespace => $self->MEMCACHED_NAMESPACE(),
    };
};

# Use memcached and a small in-memory cache, see below if you
# want to disable caching
#
# The caching options here relate to object caching - such as caching artists,
# releases, etc in order to speed up queries. If you are using Memcached
# to store sessions as well this should be a *different* memcached server.
sub CACHE_MANAGER_OPTIONS {
    my $self = shift;
    my %CACHE_MANAGER_OPTIONS = (
        profiles => {
            memory => {
                class => 'Cache::Memory',
                wrapped => 1,
                keys => [qw( area_type artist_type g c lng label_type mf place_type release_group_type release_group_secondary_type rs rp scr work_type )],
                options => {
                    default_expires => '1 hour',
                },
            },
            external => {
                class => 'Cache::Memcached::Fast',
                options => {
                    servers => $self->MEMCACHED_SERVERS(),
                    namespace => $self->MEMCACHED_NAMESPACE()
                },
            },
        },
        default_profile => 'external',
    );

    return \%CACHE_MANAGER_OPTIONS
}

# Sets the TTL for entities stored in memcached, in seconds. On slave servers,
# this is set to 1 hour by default, to mitigate MBS-8726. On standalone
# servers, this is set to 0 (meaning no expiration is set), because cache
# invalidation is already handled by the server in that case.
sub ENTITY_CACHE_TTL {
    return 3600 if shift->REPLICATION_TYPE == RT_SLAVE;
    return 0;
}

################################################################################
# Rate-Limiting
################################################################################

# The "host:port" of the ratelimit server ($MB_SERVER/bin/ratelimit-server).
# If undef, the rate-limit code always returns undef (as it does if there is
# an error).
# Just like the memcached server settings, there is NO SECURITY built into the
# ratelimit protocol, so be careful about enabling it.
sub RATELIMIT_SERVER { undef }

################################################################################
# Sessions (advanced)
################################################################################

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
        prefix => 'MB:',
        database => 0,
        test_database => 1,
        redis_new_args => {
            server => '127.0.0.1:6379',
            reconnect => 60,
            encoding => undef,
        }
    };
};

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
sub GIT_BRANCH
{
  my $self = shift;
  if ($self->DB_STAGING_SERVER) {
    my $branch = `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d'`;
    $branch =~ s/\* (.+)/$1/;
    my $sha = `git log -1 --format=format:"%h"`;
    my $msg = `git log -1 --format=format:"Last commit by %an on %ad%n%s" --date=short`;
    return $branch, $sha, $msg;
  }
}

# How long an annotation is considered as being locked.
sub ANNOTATION_LOCK_TIME { 60*15 }

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

# Add a Google Analytics tracking code to enable Google Analytics tracking.
sub GOOGLE_ANALYTICS_CODE { '' }

sub MAPBOX_MAP_ID { 'mapbox.streets' }
sub MAPBOX_ACCESS_TOKEN { '' }

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

# Set this to an email address and the server will email any bugs to you
sub EMAIL_BUGS { undef }

# Configure which html validator should be used.  If you run tests
# often, you should probably run a local copy of the validator.  See
# http://about.validator.nu/#src for instructions.
sub HTML_VALIDATOR { 'http://validator.w3.org/nu/?out=json' }
# sub HTML_VALIDATOR { 'http://localhost:8888?out=json' }

# We use a small HTTP server (root/server.js) to render React.js templates.
# These configure the host/port it listens on. If RENDERER_HOST is '', then
# musicbrainz-server will fork & exec root/server.js for us (convenient on
# development servers). Otherwise, it'll assume the service is running
# separately.
sub RENDERER_HOST { '' }
sub RENDERER_PORT { 9009 }

# Base URL of external Discourse instance.
sub DISCOURSE_SERVER { '' }
# Used to authenticate when synchronizing SSO records.
# See https://meta.discourse.org/t/discourse-api-documentation/22706
sub DISCOURSE_API_KEY { '' }
sub DISCOURSE_API_USERNAME { '' }
# See https://meta.discourse.org/t/official-single-sign-on-for-discourse/13045
sub DISCOURSE_SSO_SECRET { '' }

################################################################################
# Profiling
################################################################################
# Set these to >0 to enable profiling

# Log if a request in /ws takes more than x seconds
sub PROFILE_WEB_SERVICE { 0 }

# Log if a request in / (not /ws) takes more than x seconds
sub PROFILE_SITE { 0 }

# If you want the FastCGI processes to restart, configure this
sub AUTO_RESTART {
#    return {
#        active => 1,
#        check_each => 10,
#        max_bits => 134217728,
#        min_handled_requests => 100
#    }
}

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

sub ADMIN_EMAILS { "root" }

# Were to put database exports, and replication data, for public consumption;
# who should own them, and what mode they should have.
sub FTP_DATA_DIR { "/var/ftp/pub/musicbrainz/data" }
sub FTP_USER { "musicbrainz" }
sub FTP_GROUP { "musicbrainz" }
sub FTP_DIR_MODE { 755 }
sub FTP_FILE_MODE { 644 }

# Where to back things up to, who should own the backup files, and what mode
# those files should have.
# The backups include a full database export, and all replication data.
sub BACKUP_DIR { "/home/musicbrainz/backup" }
sub BACKUP_USER { "musicbrainz" }
sub BACKUP_GROUP { "musicbrainz" }
sub BACKUP_DIR_MODE { 700 }
sub BACKUP_FILE_MODE { 600 }

sub RSYNC_FULLEXPORT_SERVER { 'ftp-data@taz.localdomain' }
sub RSYNC_REPLICATION_SERVER { 'metabrainz@sakura.localdomain' }

1;
# eof DBDefs.pm
