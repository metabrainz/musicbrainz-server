package MusicBrainz::Server;

use Moose;
BEGIN { extends 'Catalyst' }

use Class::Load qw( load_class );
use DBDefs;
use Encode;
use JSON;
use Moose::Util qw( does_role );
use MusicBrainz::Sentry qw( sentry_enabled );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Log qw( logger );
use POSIX qw(SIGALRM);
use Sys::Hostname;
use Try::Tiny;
use URI;
use aliased 'MusicBrainz::Server::Translation';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
my @args = qw/
Session
Session::State::Cookie

Cache
Authentication
/;

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in musicbrainz.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.
require MusicBrainz::Server::Filters;

__PACKAGE__->config(
    name => 'MusicBrainz::Server',
    default_view => 'Default',
    encoding => 'UTF-8',
    "View::Default" => {
        expose_methods => [qw(
            comma_list
            comma_only_list
        )],
        FILTERS => {
            'release_date' => \&MusicBrainz::Server::Filters::release_date,
            'format_length' => \&MusicBrainz::Server::Filters::format_length,
            'format_distance' => \&MusicBrainz::Server::Filters::format_distance,
            'format_wikitext' => \&MusicBrainz::Server::Filters::format_wikitext,
            'format_editnote' => \&MusicBrainz::Server::Filters::format_editnote,
            'format_setlist' => \&MusicBrainz::Server::Filters::format_setlist,
            'language' => \&MusicBrainz::Server::Filters::language,
            'locale' => \&MusicBrainz::Server::Filters::locale,
            'gravatar' => \&MusicBrainz::Server::Filters::gravatar,
            'coverart_https' => \&MusicBrainz::Server::Filters::coverart_https
        },
        RECURSION => 1,
        TEMPLATE_EXTENSION => '.tt',
        PLUGIN_BASE => 'MusicBrainz::Server::Plugin',
        PRE_PROCESS => [
            'components/common-macros.tt',
            'components/forms.tt',
        ],
        ENCODING => 'UTF-8',
        EVAL_PERL => 1,
        COMPILE_EXT => '.ttc',
        COMPILE_DIR => '/tmp/ttc'
    },
    'Plugin::Session' => {
        expires => DBDefs->SESSION_EXPIRE
    },
    stacktrace => {
        enable => 1
    },
    use_request_uri_for_path => 1
);

if ($ENV{'MUSICBRAINZ_USE_PROXY'})
{
    __PACKAGE__->config( using_frontend_proxy => 1 );
}

if (sentry_enabled) {
    push @args, 'Sentry';
}

__PACKAGE__->config->{'Plugin::Cache'}{backend} = DBDefs->PLUGIN_CACHE_OPTIONS;

require MusicBrainz::Server::Authentication::WS::Credential;
require MusicBrainz::Server::Authentication::WS::Store;
require MusicBrainz::Server::Authentication::Store;
__PACKAGE__->config->{'Plugin::Authentication'} = {
    default_realm => 'moderators',
    use_session => 0,
    realms => {
        moderators => {
            use_session => 1,
            credential => {
                class => '+MusicBrainz::Server::Authentication::Credential',
            },
            store => {
                class => '+MusicBrainz::Server::Authentication::Store'
            }
        },
        'musicbrainz.org' => {
            use_session => 0,
            credential => {
                class => '+MusicBrainz::Server::Authentication::WS::Credential',
                type => 'digest',
                password_field => 'ha1',
                password_type => 'clear'
            },
            store => {
                class => '+MusicBrainz::Server::Authentication::WS::Store'
            }
        }
    }
};

# This bit is only required to load if we're running under a proxy
# Hence, only load it if the module has been installed.
if (eval { require Catalyst::TraitFor::Request::ProxyBase; 1}) {
    require CatalystX::RoleApplicator;
    CatalystX::RoleApplicator->import();
    __PACKAGE__->apply_request_class_roles(
        qw/
              Catalyst::TraitFor::Request::ProxyBase
          /);
}


__PACKAGE__->config->{form} = {
    no_fillin       => 1,
    pre_load_forms  => 1,
    form_name_space => 'MusicBrainz::Server::Forms',
};

if ($ENV{'MUSICBRAINZ_RUNNING_TESTS'}) {
    push @args, "Session::Store::Dummy";

    # /static is usually taken care of by Plack or nginx, but not when running
    # as part of Test::WWW::Selenium::Catalyst, so we need Static::Simple when
    # running tests.
    push @args, "Static::Simple";
    __PACKAGE__->config->{'Plugin::Static::Simple'} = {
        mime_types => {
            json => 'application/json; charset=UTF-8',
        },
        dirs => [ 'static' ],
        no_logs => 1
    }
} else {
    push @args, DBDefs->SESSION_STORE;
    __PACKAGE__->config->{'Plugin::Session'} = DBDefs->SESSION_STORE_ARGS;
}

if (DBDefs->STAT_TTL) {
    __PACKAGE__->config->{'View::Default'}->{'STAT_TTL'} = DBDefs->STAT_TTL;
}

if (DBDefs->CATALYST_DEBUG) {
    push @args, "-Debug";
}

if (DBDefs->SESSION_COOKIE) {
    __PACKAGE__->config->{session}{cookie_name} = DBDefs->SESSION_COOKIE;
}

if (DBDefs->SESSION_DOMAIN) {
    __PACKAGE__->config->{session}{cookie_domain} = DBDefs->SESSION_DOMAIN;
}

__PACKAGE__->config->{session}{cookie_expires} = DBDefs->WEB_SESSION_SECONDS_TO_LIVE;

if (DBDefs->USE_ETAGS) {
    push @args, "Cache::HTTP";
}

if ($ENV{'MUSICBRAINZ_USE_TEST_DATABASE'})
{
    use MusicBrainz::Server::DatabaseConnectionFactory;
    MusicBrainz::Server::DatabaseConnectionFactory->connector_class('MusicBrainz::Server::Test::Connector');
    warn "WARNING: Using test database schema\n";
}

{
    use MusicBrainz::Server::CatalystLogger;
    __PACKAGE__->log( MusicBrainz::Server::CatalystLogger->new( dispatch => logger() ) );
}

# Start the application
__PACKAGE__->setup(@args);

=head2 form_posted

This returns true if the request was a post request.

=cut

sub form_posted
{
    my $c = shift;

    return $c->req->method eq 'POST';
}

sub form
{
    my ($c, $stash, $form_name, %args) = @_;
    die '$c->form required $stash => $form_name as arguments' unless $stash && $form_name;
    $form_name = "MusicBrainz::Server::Form::$form_name";
    load_class($form_name);
    my $form = $form_name->new(%args, ctx => $c);
    $c->stash( $stash => $form );
    return $form;
}

sub relative_uri
{
    my ($self) = @_;
    my $uri = URI->new($self->req->uri->path);
    $uri->path_query($self->req->uri->path_query);

    return $uri;
}

sub get_relative_uri {
    my ($c, $uri_string) = @_;

    my $uri = URI->new($uri_string);
    my $path = $uri->path_query;
    my $frag = $uri->fragment;

    $path = '/' . $path unless $path =~ /^\//;
    $path .= '#' . $frag if $frag;
    $path;
}

sub gettext  { shift; Translation->instance->gettext(@_) }
sub pgettext { shift; Translation->instance->pgettext(@_) }
sub ngettext { shift; Translation->instance->ngettext(@_) }

sub get_collator
{
    my ($self) = @_;
    return MusicBrainz::Server::Translation::get_collator(
        $self->stash->{current_language} // 'en'
    );
}

sub set_language_cookie {
    my ($c, $lang) = @_;
    $c->res->cookies->{lang} = { 'value' => $lang, 'path' => '/', 'expires' => time()+31536000 };
}

sub handle_unicode_encoding_exception {
    my $self = shift;

    $self->res->body('Sorry, but your request could not be decoded. Please ensure your request is encoded as UTF-8 and try again.');
    $self->res->status(400);
}

# Set and unset translation language
sub with_translations {
    my ($c, $code) = @_;

    $_->instance->build_languages_from_header($c->req->headers)
        for qw( MusicBrainz::Server::Translation
                MusicBrainz::Server::Translation::Statistics
                MusicBrainz::Server::Translation::Countries
                MusicBrainz::Server::Translation::Scripts
                MusicBrainz::Server::Translation::Languages
                MusicBrainz::Server::Translation::Attributes
                MusicBrainz::Server::Translation::Relationships
                MusicBrainz::Server::Translation::Instruments
                MusicBrainz::Server::Translation::InstrumentDescriptions );

    my $cookie_lang = Translation->instance->language_from_cookie($c->request->cookies->{lang});
    $c->set_language_cookie($c->request->cookies->{lang}->value) if defined $c->request->cookies->{lang};
    my $lang = Translation->instance->set_language($cookie_lang);
    my $html_lang = $lang =~ s/_([A-Z]{2})/-\L$1/r;

    $c->stash(
        current_language => $lang,
        current_language_html => $html_lang,
        use_languages => scalar @{ Translation->instance->all_languages() }
    );

    $code->();

    Translation->instance->unset_language();
};

around dispatch => sub {
    my ($orig, $c, @args) = @_;
    my $unset_beta = (defined $c->req->query_params->{unset_beta} &&
                      $c->req->query_params->{unset_beta} eq '1' &&
                      !DBDefs->IS_BETA);
    my $beta_redirect = (defined $c->req->cookies->{beta} &&
                      $c->req->cookies->{beta}->value eq 'on' &&
                      !DBDefs->IS_BETA);
    if ( $unset_beta ) {
        $c->res->cookies->{beta} = { 'value' => '', 'path' => '/', 'expires' => time()-86400 };
    }

    if (DBDefs->BETA_REDIRECT_HOSTNAME &&
            $beta_redirect && !$unset_beta &&
            !($c->req->uri =~ /set-beta-preference$/)) {
        my $ws = DBDefs->WEB_SERVER;
        my $new_url = $c->req->uri =~ s/$ws/DBDefs->BETA_REDIRECT_HOSTNAME/er;
        $c->res->redirect($new_url, 307);
    } else {
        $c->with_translations(sub {
            $c->$orig(@args)
        });
    }
};

# All warnings should be logged
around dispatch => sub {
    my ($orig, $c, @args) = @_;

    local $SIG{__WARN__} = sub {
        my $warning = shift;
        chomp $warning;
        $c->log->warn($c->req->method . " " . $c->req->uri . " caused a warning: " . $warning);
    };

    $c->$orig(@args);
};

# Use a fresh database connection for every request, and remember to disconnect at the end
before dispatch => sub {
    shift->model('MB')->context->connector->refresh;
};

after dispatch => sub {
    my ($self) = @_;

    my $c = $self->model('MB')->context;
    $c->connector->disconnect;
    $c->store->disconnect;
    $c->cache->disconnect;
};

# Timeout long running requests
around dispatch => sub {
    my ($orig, $c, @args) = @_;

    my $max_request_time = DBDefs->DETERMINE_MAX_REQUEST_TIME($c->req);

    if (defined($max_request_time) && $max_request_time > 0) {
        alarm($max_request_time);

        my $action = POSIX::SigAction->new(sub {
            my $context = $c->model('MB')->context;
            if (my $sth = $context->sql->sth) {
                $sth->cancel;
            }
            MusicBrainz::Server::Exceptions::GenericTimeout->throw(
                $c->req->method . ' ' . $c->req->uri .
                " took more than $max_request_time seconds"
            );
        });
        $action->safe(1);
        POSIX::sigaction(SIGALRM, $action);
    }

    $c->$orig(@args);

    alarm(0);
};

around 'finalize_error' => sub {
    my $orig = shift;
    my $c = shift;
    my @args = @_;

    $c->with_translations(sub {
        my $errors = $c->error;

        my $timed_out = 0;
        $timed_out = 1
            if scalar @$errors == 1 && blessed $errors->[0]
                && does_role($errors->[0], 'MusicBrainz::Server::Exceptions::Role::Timeout');

        # don't send timeouts to Sentry (log instead)
        local $Catalyst::Plugin::Sentry::suppress = 1
            if $timed_out;

        $c->$orig(@args);

        if (!$c->debug && scalar @{ $c->error }) {
            $c->stash->{errors} = $errors;
            $c->stash->{template} = $timed_out ?
                'main/timeout.tt' : 'main/500.tt';
            try { $c->stash->{hostname} = hostname; } catch {};
            $c->clear_errors;
            if ($c->stash->{error_body_in_stash}) {
                $c->res->{body} = $c->stash->{body};
                $c->res->{status} = $c->stash->{status};
            } else {
                $c->res->{body} = 'clear';
                $c->view('Default')->process($c);
                $c->res->{body} = encode('utf-8', $c->res->{body});
                $c->res->{status} = 503
                    if $timed_out;
            }
        }
    });
};

sub try_get_session {
    my ($c, $key) = @_;
    return $c->sessionid ? $c->session->{$key} : undef;
}

has json => (
    is => 'ro',
    default => sub {
        return JSON->new->allow_blessed->convert_blessed;
    }
);

has json_canonical_utf8 => (
    is => 'ro',
    default => sub {
        return JSON->new->allow_blessed->canonical->convert_blessed->utf8;
    }
);

has json_utf8 => (
    is => 'ro',
    default => sub {
        return JSON->new->allow_blessed->convert_blessed->utf8;
    }
);

sub TO_JSON {
    my $self = shift;

    # Whitelist of keys that we use in the templates.
    my @stash_keys = qw(
        current_language
        current_language_html
        entity
        hide_merge_helper
        jsonld_data
        last_replication_date
        linked_entities
        makes_no_changes
        merge_link
        new_edit_notes
        server_details
        server_languages
        to_merge
    );

    my %stash;
    for (@stash_keys) {
        $stash{$_} = $self->stash->{$_};
    }

    if (my $entity = delete $stash{entity}) {
        if (ref($entity) =~ /^MusicBrainz::Server::Entity::/) {
            $entity->serialize_with_linked_entities(\%stash);
        }
    }

    # convert DateTime objects to iso8601-formatted strings
    if (my $date = $stash{last_replication_date}) {
        $date = $date->clone;
        $date->set_time_zone('UTC');
        $stash{last_replication_date} = $date->iso8601 . 'Z';
    }

    # Limit server_languages data to what's needed, since the complete output
    # is very large.
    if (my $server_languages = $stash{server_languages}) {
        my @langs;
        for my $lang (@{$server_languages}) {
            push @langs,
                [ $lang->[0],
                  { map { $_ => $lang->[1]->{$_} }
                    qw( id native_language native_territory ) } ];
        }
        $stash{server_languages} = \@langs;
    }

    if (my $server_details = delete $stash{server_details}) {
        $stash{alert} = $server_details->{alert};
        $stash{alert_mtime} = $server_details->{alert_mtime};
    }

    my $req = $self->req;
    my %headers;
    for my $name ($req->headers->header_field_names) {
        $headers{$name} = $req->headers->header($name);
    }

    return {
        user => ($self->user_exists ? $self->user : undef),
        user_exists => boolean_to_json($self->user_exists),
        debug => boolean_to_json($self->debug),
        relative_uri => $self->relative_uri,
        req => {
            headers => \%headers,
            query_params => $req->query_params,
            uri => $req->uri,
        },
        stash => \%stash,
        sessionid => scalar($self->sessionid),
        session => $self->session,
        flash => $self->flash,
    };
}

=head1 NAME

MusicBrainz::Server - Catalyst-based MusicBrainz server

=head1 SYNOPSIS

    script/musicbrainz_server.pl

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2008 Oliver Charles
Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

1;
