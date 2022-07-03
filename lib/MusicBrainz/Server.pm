package MusicBrainz::Server;

use Moose;
BEGIN { extends 'Catalyst' }

use Class::Load qw( load_class );
use DBDefs;
use Digest::SHA qw( sha256 );
use JSON;
use MIME::Base64 qw( encode_base64 );
use Moose::Util qw( does_role );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    datetime_to_iso8601
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Log qw( logger );
use MusicBrainz::Server::Validation qw( is_positive_integer );
use POSIX qw(SIGALRM);
use Scalar::Util qw( refaddr );
use Sys::Hostname;
use Time::HiRes qw( clock_gettime CLOCK_REALTIME CLOCK_MONOTONIC );
use Try::Tiny;
use URI;
use aliased 'MusicBrainz::Server::Translation';
use feature 'state';

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
    'View::Default' => {
        expose_methods => [qw(
            boolean_to_json
            comma_list
            comma_only_list
            form_to_json
        )],
        FILTERS => {
            'format_length' => \&MusicBrainz::Server::Filters::format_length,
            'format_wikitext' => \&MusicBrainz::Server::Filters::format_wikitext,
            'format_editnote' => \&MusicBrainz::Server::Filters::format_editnote,
            'locale' => \&MusicBrainz::Server::Filters::locale,
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

unless (DBDefs->CATALYST_DEBUG) {
    # $c->debug provides its own error pages
    push @args, 'ErrorInfo';
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
    push @args, 'Session::Store::Dummy';

    # /static is usually taken care of by Plack or nginx, but not when running
    # as part of Test::WWW::Selenium::Catalyst, so we need Static::Simple when
    # running tests.
    push @args, 'Static::Simple';
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
    push @args, '-Debug';
}

if (DBDefs->SESSION_COOKIE) {
    __PACKAGE__->config->{session}{cookie_name} = DBDefs->SESSION_COOKIE;
}

if (DBDefs->SESSION_DOMAIN) {
    __PACKAGE__->config->{session}{cookie_domain} = DBDefs->SESSION_DOMAIN;
}

__PACKAGE__->config->{session}{cookie_expires} = DBDefs->WEB_SESSION_SECONDS_TO_LIVE;

if (DBDefs->USE_ETAGS) {
    push @args, 'Cache::HTTP';
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

has relative_uri => (
    is => 'ro',
    lazy => 1,
    isa => 'URI',
    default => sub {
        my ($self) = @_;
        my $uri = URI->new($self->req->uri->path);
        $uri->path_query($self->req->uri->path_query);
        return $uri;
    },
);

sub redirect_back {
    my ($c, %opts) = @_;

    my $returnto_param = $c->req->query_params->{returnto};
    my $fallback_opt = $opts{fallback};

    if (!defined $returnto_param && defined $fallback_opt) {
        $returnto_param = $c->get_relative_uri($fallback_opt);
    }

    my $returnto = URI->new($returnto_param);

    if (
        $returnto eq '' ||
        # Check that we weren't given an external URL. Only URLs relative to
        # the current domain are allowed.
        (
            $returnto->authority &&
            $returnto->authority ne $c->req->uri->authority
        )
    ) {
        $returnto->path_query('/');
        $returnto->fragment(undef);
    }

    if (my $callback = $opts{callback}) {
        $callback->($returnto);
    }

    $c->res->redirect($returnto);
}

# XXX temporary hack for remove_from_merge in common-macros.tt, and
# merge-helper.tt.
use WWW::Form::UrlEncoded qw( build_urlencoded );
sub returnto_relative_uri {
    build_urlencoded(returnto => shift->relative_uri);
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
    $c->res->cookies->{lang} = {
        'value' => $lang,
        'path' => '/',
        'expires' => time()+31536000,
        $c->req->secure ? (
            'samesite' => 'None',
            'secure' => '1',
        ) : (),
    };
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
    my $beta_cookie = $c->req->cookies->{beta};
    my $beta_redirect = (defined $beta_cookie &&
                         defined $beta_cookie->value &&
                         $beta_cookie->value eq 'on' &&
                         !DBDefs->IS_BETA);
    if ( $unset_beta ) {
        $c->res->cookies->{beta} = {
            'value' => '',
            'path' => '/',
            'expires' => time()-86400,
            $c->req->secure ? (
                'samesite' => 'None',
                'secure' => '1',
            ) : (),
        };
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
        $c->log->warn($c->req->method . ' ' . $c->req->uri . ' caused a warning: ' . $warning);
    };

    $c->$orig(@args);
};

my $ORIG_ENTITY_CACHE_TTL = DBDefs->can('ENTITY_CACHE_TTL');
my $ORIG_CACHE_NAMESPACE = DBDefs->can('CACHE_NAMESPACE');

before dispatch => sub {
    my ($self) = @_;

    my $ctx = $self->model('MB')->context;

    # The mb-set-database header is added by:
    #  1) the http proxy in t/selenium.mjs
    #  2) make_jsonld_request in
    #     lib/MusicBrainz/Server/Sitemap/Incremental.pm
    # and instructs us to use the specified database instead of
    # READWRITE. We ignore the header unless USE_SET_DATABASE_HEADER
    # is also enabled.
    my $database = $self->req->headers->header('mb-set-database');
    if (DBDefs->USE_SET_DATABASE_HEADER && $database) {
        no warnings 'redefine';
        $ctx->database($database);
        $ctx->clear_connector;
        my $cache_namespace = DBDefs->CACHE_NAMESPACE;
        *DBDefs::CACHE_NAMESPACE = sub { $cache_namespace . $database . ':' };
        *DBDefs::ENTITY_CACHE_TTL = sub { 1 };
    } else {
        # Use a fresh database connection for every request, and
        # remember to disconnect at the end.
        $ctx->connector->refresh;
    }

    # Any time `TO_JSON` is called on an Entity, it may add other
    # entity data it references into the `$linked_entities` hash. This
    # must be reset per-request.
    $MusicBrainz::Server::Entity::Util::JSON::linked_entities = {};
};


after dispatch => sub {
    my ($self) = @_;

    my $ctx = $self->model('MB')->context;

    $ctx->connector->disconnect;
    $ctx->store->disconnect;
    $ctx->cache->disconnect;

    my $database = $self->req->headers->header('mb-set-database');
    if (DBDefs->USE_SET_DATABASE_HEADER && $database) {
        no warnings 'redefine';
        # Clear the connector and database handles, so that we revert
        # back to the default (READWRITE, or READONLY for mirrors).
        $ctx->clear_connector;
        $ctx->clear_database;
        *DBDefs::CACHE_NAMESPACE = $ORIG_CACHE_NAMESPACE;
        *DBDefs::ENTITY_CACHE_TTL = $ORIG_ENTITY_CACHE_TTL;
    }

    $MusicBrainz::Server::Entity::Util::JSON::linked_entities = undef;
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
        local $Catalyst::Plugin::ErrorInfo::suppress_sentry = 1
            if $timed_out;

        $c->$orig(@args);

        if (!$c->debug && scalar @{ $c->error }) {
            try { $c->stash->{hostname} = hostname; } catch {};
            $c->stash(
                component_path => $timed_out
                    ? 'main/error/TimeoutError'
                    : 'main/error/Error500',
                component_props => {
                    $c->stash->{edit} ? (edits => [ $c->stash->{edit}->TO_JSON ]) : (),
                    formattedErrors => $c->stash->{formatted_errors},
                    hostname => $c->stash->{hostname},
                    useLanguages => boolean_to_json($c->stash->{use_languages}),
                },
                current_view => 'Node',
            );
            $c->clear_errors;
            if ($c->stash->{error_body_in_stash}) {
                $c->res->{body} = $c->stash->{body};
                $c->res->{status} = $c->stash->{status};
            } else {
                $c->view->process($c);
                # Catalyst::Engine::finalize_error unsets $c->encoding. [1]
                # We're rendering our own error page here, not using theirs,
                # so set it back to UTF-8.
                #
                # (This issue doesn't manifest when the `ErrorInfo` plugin is
                # active, because that implements a new `finalize_error`.)
                #
                # [1] https://github.com/perl-catalyst/catalyst-runtime/
                #     blob/5757858/lib/Catalyst/Engine.pm#L253-L259
                $c->encoding('UTF-8');
                $c->res->{status} = $timed_out ? 503 : 500;
            }
        }
    });
};

sub try_get_session {
    my ($c, $key) = @_;
    return $c->sessionid ? $c->session->{$key} : undef;
}

around make_session_cookie => sub {
    my ($orig, $self, $sid, %attrs) = @_;

    my $cookie = $self->$orig($sid, %attrs);
    $cookie->{samesite} = 'Lax';
    $cookie->{secure} = 1 if $self->req->secure;
    return $cookie;
};

has json => (
    is => 'ro',
    default => sub {
        return JSON->new->allow_blessed->convert_blessed;
    }
);

has json_canonical => (
    is => 'ro',
    default => sub {
        return JSON->new->allow_blessed->canonical->convert_blessed;
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

sub form_posted_and_valid {
    my ($self, $form, $params) = @_;

    return 0 unless $self->form_posted;
    return $self->form_submitted_and_valid($form, $params);
}

sub form_submitted_and_valid {
    my ($self, $form, $params) = @_;

    $params = $self->req->params
        unless defined $params;

    return 0 unless
        %{$params} &&
        $form->process(params => $params) &&
        $form->has_params;

    return 1;
}

sub generate_nonce {
    my ($self) = @_;

    state $counter = 0;
    encode_base64(
        sha256(
            join q(.),
                DBDefs->NONCE_SECRET,
                refaddr($self->req),
                refaddr($self->res),
                clock_gettime(CLOCK_REALTIME),
                clock_gettime(CLOCK_MONOTONIC),
                ($counter++)),
        '',
    );
}

sub get_csrf_token {
    my ($self, $session_key) = @_;

    my $existing_token;
    if (defined $session_key) {
        $existing_token = delete $self->session->{$session_key};
    }
    return $existing_token;
}

sub generate_csrf_token {
    my ($self) = @_;

    my $session_key = 'csrf_token:' . $self->generate_nonce;
    my $token = $self->generate_nonce;
    $self->session->{$session_key} = $token;
    $self->session_expire_key($session_key, 600); # 10 minutes
    return ($session_key, $token);
}

sub set_csp_headers {
    my ($self) = @_;

    return if defined $self->res->header('Content-Security-Policy');

    my $globals_script_nonce = $self->generate_nonce;
    $self->stash->{globals_script_nonce} = $globals_script_nonce;

    # CSP headers are generally only added where SecureForm is also used:
    # account and admin-related forms. So there's no need to account for
    # external origins like coverartarchive.org, archive.org, etc. here,
    # as those are used on entity pages which don't have a CSP.
    # Userscripts should continue to work for the same reason:
    # edit and entity pages are unaffected. Avoid using the
    # SecureForm attribute in those places.
    my @csp_script_src = (
        'script-src',
        q('self'),
        qq('nonce-$globals_script_nonce'),
        'staticbrainz.org'
    );

    my @csp_style_src = (
        'style-src',
        q('self'),
        'staticbrainz.org',
    );

    my @csp_img_src = (
        'img-src',
        q('self'),
        'data:',
        'staticbrainz.org',
    );

    my @csp_frame_src = ('frame-src', q('self'));
    if ($self->req->path eq 'register') {
        my $use_captcha = ($self->req->address &&
                           defined DBDefs->RECAPTCHA_PUBLIC_KEY &&
                           defined DBDefs->RECAPTCHA_PRIVATE_KEY);
        if ($use_captcha) {
            push @csp_script_src, qw(
                https://www.google.com/recaptcha/
                https://www.gstatic.com/recaptcha/
                https://www.recaptcha.net/recaptcha/
            );
            push @csp_frame_src, qw(
                https://www.google.com/recaptcha/
                https://www.recaptcha.net/recaptcha/
            );
        }
    }

    $self->res->header(
        # X-Frame-Options is obsoleted by `frame-ancestors` on the
        # Content-Security-Policy header; user agents that support
        # the latter should ignore X-Frame-Options.
        'X-Frame-Options' => 'DENY',
        'Content-Security-Policy' => (
            q(default-src 'self'; frame-ancestors 'none'; ) .
            (join '; ', map { join ' ', @{$_} } (
                \@csp_script_src,
                \@csp_style_src,
                \@csp_img_src,
                \@csp_frame_src,
            ))
        ),
    );
}

sub is_cross_origin {
    my $self = shift;

    my $origin = $self->req->header('Origin');
    return 0 unless defined $origin;

    my $mb_origin = DBDefs->SSL_REDIRECTS_ENABLED
        ? ('https://' . DBDefs->WEB_SERVER_SSL)
        : ('http://' . DBDefs->WEB_SERVER);

    return $origin ne $mb_origin;
}

sub unsanitized_editor_json {
    my ($self, $editor) = @_;

    my $json = $editor->_unsanitized_json;

    if ($self->user_exists) {
        my $active_user = $self->user;

        if ($editor->id == $active_user->id) {
            my $birth_date = $editor->birth_date;
            if ($birth_date) {
                $json->{birth_date} = {
                    year => $birth_date->year,
                    month => $birth_date->month,
                    day => $birth_date->day,
                };
            }
            $json->{email} = $editor->email;
        } elsif ($active_user->is_account_admin) {
            $json->{email} = $editor->email;
        }
    }

    return $json;
}

sub TO_JSON {
    my $self = shift;

    # Whitelist of keys that we use in the templates.
    my @stash_keys = qw(
        can_delete
        collaborative_collections
        commons_image
        containment
        current_language
        current_language_html
        entity
        genre_map
        globals_script_nonce
        jsonld_data
        last_replication_date
        more_tags
        new_edit_notes_mtime
        number_of_collections
        number_of_revisions
        own_collections
        release_artwork
        release_artwork_count
        release_cdtoc_count
        server_details
        server_languages
        source_entity
        subscribed
        to_merge
        top_tags
        user_tags
    );

    my @boolean_stash_keys = qw(
        current_action_requires_auth
        hide_merge_helper
        makes_no_changes
        new_edit_notes
    );

    my %stash;
    for (@stash_keys) {
        $stash{$_} = $self->stash->{$_} if exists $self->stash->{$_};
    }

    for (@boolean_stash_keys) {
        $stash{$_} = boolean_to_json($self->stash->{$_})
            if exists $self->stash->{$_};
    }

    if (my $entity = delete $stash{entity}) {
        if (ref($entity) =~ /^MusicBrainz::Server::Entity::/) {
            $stash{entity} = $entity->TO_JSON;
        }
    }

    # convert DateTime objects to iso8601-formatted strings
    if (my $date = $stash{last_replication_date}) {
        $stash{last_replication_date} = datetime_to_iso8601($date);
    }

    # Limit server_languages data to what's needed, since the complete output
    # is very large.
    if (my $server_languages = delete $stash{server_languages}) {
        my @server_languages = map {
            my $lang = $_;
            { name => $lang->[0],
              map { $_ => $lang->[1]->{$_} } qw( id native_language native_territory ) }
        } @{$server_languages};
        $stash{server_languages} = \@server_languages;
    }

    if (my $server_details = delete $stash{server_details}) {
        $stash{alert} = $server_details->{alert};
        $stash{alert_mtime} = $server_details->{alert_mtime};
    }

    if (my $to_merge = delete $stash{to_merge}) {
        $stash{to_merge} = to_json_array($to_merge);
    }

    if (my $release_artwork = delete $stash{release_artwork}) {
        $stash{release_artwork} = to_json_object($release_artwork);
    }

    my $req = $self->req;
    my %headers;
    for my $name ($req->headers->header_field_names) {
        $headers{lc($name)} = $req->headers->header($name);
    }

    my $session = $self->session;
    if ($session) {
        my $tport = $session->{tport};
        my $merger = $session->{merger};

        $session = {};
        if (is_positive_integer($tport)) {
            $session->{tport} = $tport + 0;
        }
        if (defined $merger) {
            $session->{merger} = $merger->TO_JSON;
        }
    }

    return {
        action => {
            name => $self->action->name,
        },
        user => (
            $self->user_exists
                ? $self->unsanitized_editor_json($self->user)
                : undef
        ),
        user_exists => boolean_to_json($self->user_exists),
        debug => boolean_to_json($self->debug),
        relative_uri => '' . $self->relative_uri,
        req => {
            body_params => $req->body_params,
            headers => \%headers,
            method => uc($req->method),
            query_params => $req->query_params,
            secure => boolean_to_json($req->secure),
            uri => '' . $req->uri,
        },
        stash => \%stash,
        sessionid => scalar($self->sessionid),
        session => $session,
        flash => $self->flash,
    };
}

=head1 NAME

MusicBrainz::Server - Catalyst-based MusicBrainz server

=head1 SYNOPSIS

    script/musicbrainz_server.pl

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2008 Oliver Charles
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
