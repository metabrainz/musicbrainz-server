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

use File::Spec::Functions qw( splitdir catdir );
use Cwd qw( abs_path );
use MusicBrainz::Server::Translation 'l';

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
use MusicBrainz::Server::Replication ':replication_type';
sub REPLICATION_TYPE { RT_STANDALONE }

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
# signatures and encryption of data dumps and packets.
sub GPG_SIGN_KEY { "" }
sub GPG_ENCRYPT_KEY { "" }

################################################################################
# HTTP Server Names
################################################################################

# The host names used by the server.
# To use a port number other than 80, add it like so: "myhost:8000"
sub WEB_SERVER                { "localhost:5000" }
sub WEB_SERVER_SSL            { "localhost" }
sub LUCENE_SERVER             { "search.musicbrainz.org" }
sub WEB_SERVER_USED_IN_EMAIL  { my $self = shift; $self->WEB_SERVER }

sub IS_BETA                   { 0 }
sub BETA_REDIRECT_HOSTNAME    { '' }

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
# Default: "This is a MusicBrainz development server."
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
                keys => [qw( at g c lng lt mf rgt rs rp scr wt )],
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
# Minify settings
################################################################################

# The following two values determine how scripts and styles are minified. By
# default, a dummy minifier is used:
sub MINIFY_DUMMY { shift; my %args = @_; return $args{input}; }
sub MINIFY_SCRIPTS { return \&MINIFY_DUMMY; }
sub MINIFY_STYLES { return \&MINIFY_DUMMY; }

# If you wish to minify either javascript or css, uncomment the following lines
# and install the neccesary CPAN packages.
# sub MINIFY_SCRIPTS { use Javascript::Closure; return \&Javascript::Closure::minify }
# sub MINIFY_STYLES { use CSS::Minifier; return \&CSS::Minifier::minify }

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
        prefix => $self->MEMCACHED_NAMESPACE(),
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
sub COVER_ART_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf("http://%s.s3.us.archive.org/", shift) };
sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "//coverartarchive.org" };

# Add a Google Analytics tracking code to enable Google Analytics tracking.
sub GOOGLE_ANALYTICS_CODE { '' }

# Disallow OAuth2 requests over plain HTTP
sub OAUTH2_ENFORCE_TLS { my $self = shift; !$self->DB_STAGING_SERVER }

sub USE_ETAGS { 1 }

sub CATALYST_DEBUG { 1 }

# If you are developing on MusicBrainz, you should set this to a true value
# This will turn off some optimizations (such as CSS/JS compression) to make
# developing and debugging easier
sub DEVELOPMENT_SERVER { 1 }

# Please activate the officially approved languages here. Not every .po
# file is active because we might have fully translated languages which
# are not yet properly supported, like right-to-left languages
sub MB_LANGUAGES {qw()}

# Should the site fall back to browser settings when trying to set a language
# (note: will still only use languages in MB_LANGUAGES)
sub LANGUAGE_FALLBACK_TO_BROWSER{ 1 }

# Private, please do not change
sub _RUNNING_TESTS { 0 }

# Set this to an email address and the server will email any bugs to you
sub EMAIL_BUGS { undef }

# Configure which html validator should be used.  If you run tests
# often, you should probably run a local copy of the validator.  See
# http://about.validator.nu/#src for instructions.
sub HTML_VALIDATOR { 'http://validator.w3.org/nu/?out=json' }
# sub HTML_VALIDATOR { 'http://localhost:8888?out=json' }

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

1;
# eof DBDefs.pm
