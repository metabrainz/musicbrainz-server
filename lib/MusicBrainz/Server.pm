package MusicBrainz::Server;

use Moose;
BEGIN { extends 'Catalyst' }

use Class::MOP;
use DBDefs;
use Encode;
use MusicBrainz::Server::Log qw( logger );

use aliased 'MusicBrainz::Server::Translation';

use Try::Tiny;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
my @args = qw/
StackTrace

Session
Session::State::Cookie

Cache
Authentication

Unicode::Encoding
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
        FILTERS => {
            'release_date' => \&MusicBrainz::Server::Filters::release_date,
	    'date_xsd_type' => \&MusicBrainz::Server::Filters::date_xsd_type,
            'format_length' => \&MusicBrainz::Server::Filters::format_length,
	    'format_length_xsd' => \&MusicBrainz::Server::Filters::format_length_xsd,
            'format_distance' => \&MusicBrainz::Server::Filters::format_distance,
            'format_wikitext' => \&MusicBrainz::Server::Filters::format_wikitext,
            'format_editnote' => \&MusicBrainz::Server::Filters::format_editnote,
            'uri_decode' => \&MusicBrainz::Server::Filters::uri_decode,
            'language' => \&MusicBrainz::Server::Filters::language,
            'locale' => \&MusicBrainz::Server::Filters::locale,
            'gravatar' => \&MusicBrainz::Server::Filters::gravatar,
            'amazon_https' => \&MusicBrainz::Server::Filters::amazon_https,
            'coverart_https' => \&MusicBrainz::Server::Filters::coverart_https
        },
        RECURSION => 1,
        TEMPLATE_EXTENSION => '.tt',
        PLUGIN_BASE => 'MusicBrainz::Server::Plugin',
        PRE_PROCESS => [
            'components/common-macros.tt',
            'components/forms.tt',
	    'components/rdfa-macros.tt',
        ],
        ENCODING => 'UTF-8',
    },
    'Plugin::Session' => {
        expires => 36000 # 10 hours
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

if (DBDefs::EMAIL_BUGS) {
    __PACKAGE__->config->{'Plugin::ErrorCatcher'} = {
        emit_module => 'Catalyst::Plugin::ErrorCatcher::Email'
    };

    __PACKAGE__->config->{'Plugin::ErrorCatcher::Email'} = {
        to => DBDefs::EMAIL_BUGS(),
        from => 'bug-reporter@' . DBDefs::WEB_SERVER(),
        use_tags => 1,
        subject => 'Unhandled error in %f (line %l)'
    };

    push @args, "ErrorCatcher";
}

__PACKAGE__->config->{'Plugin::Cache'}{backend} = &DBDefs::PLUGIN_CACHE_OPTIONS;

__PACKAGE__->config->{'Plugin::Authentication'} = {
    default_realm => 'moderators',
    use_session => 0,
    realms => {
        moderators => {
            use_session => 1,
            credential => {
                class => 'Password',
                password_field => 'password',
                password_type => 'clear'
            },
            store => {
                class => '+MusicBrainz::Server::Authentication::Store'
            }
        },
        'musicbrainz.org' => {
            use_session => 1,
            credential => {
                class => 'HTTP',
                type => 'digest',
                password_field => 'password',
                password_type => 'clear'
            },
            store => {
                class => '+MusicBrainz::Server::Authentication::Store'
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

if (&DBDefs::_RUNNING_TESTS) {
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
}
else {
    push @args, &DBDefs::SESSION_STORE;
    __PACKAGE__->config->{'Plugin::Session'} = &DBDefs::SESSION_STORE_ARGS;
}

if (&DBDefs::CATALYST_DEBUG) {
    push @args, "-Debug";
}

if (&DBDefs::SESSION_COOKIE) {
    __PACKAGE__->config->{session}{cookie_name} = &DBDefs::SESSION_COOKIE;
}

if (&DBDefs::SESSION_DOMAIN) {
    __PACKAGE__->config->{session}{cookie_domain} = &DBDefs::SESSION_DOMAIN;
}

__PACKAGE__->config->{session}{cookie_expires} = &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;

if (&DBDefs::USE_ETAGS) {
    push @args, "Cache::HTTP";
}

if (my $config = DBDefs::AUTO_RESTART) {
    __PACKAGE__->config->{'Plugin::AutoRestart'} = $config;
    push @args, 'AutoRestart';
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
    Class::MOP::load_class($form_name);
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

use POSIX qw(SIGALRM);

around 'dispatch' => sub {
    my $orig = shift;
    my $c = shift;

    $c->model('MB')->context->connector->refresh;

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
    my $lang = Translation->instance->set_language($cookie_lang);
    # because s///r is a perl 5.14 feature
    my $html_lang = $lang;
    $html_lang =~ s/_([A-Z]{2})/-\L$1/;
    $c->stash(
        current_language => $lang,
        current_language_html => $html_lang
    );

    if(my $max_request_time = DBDefs::MAX_REQUEST_TIME) {
        alarm($max_request_time);
        POSIX::sigaction(
            SIGALRM, POSIX::SigAction->new(sub {
                $c->log->error(sprintf("Request for %s took over %d seconds. Killing process",
                                       $c->req->uri,
                                       $max_request_time));
                $c->log->error(Devel::StackTrace->new->as_string);
                $c->log->_flush;
                if (my $sth = $c->model('MB')->context->sql->sth) {
                    $sth->cancel;
                }
                exit(42)
            }));

        $c->$orig(@_);

        alarm(0);
    }
    else {
        $c->$orig(@_);
    }
    Translation->instance->unset_language();
};

sub gettext  { shift; Translation->instance->gettext(@_) }
sub pgettext { shift; Translation->instance->pgettext(@_) }
sub ngettext { shift; Translation->instance->ngettext(@_) }

sub _handle_param_unicode_decoding {
    my ( $self, $value ) = @_;
    my $enc = $self->encoding;
    return try {
        Encode::is_utf8( $value ) ?
            $value
        : $enc->decode( $value, $Catalyst::Plugin::Unicode::Encoding::CHECK );
    }
    catch {
        $self->res->body('Sorry, but your request could not be decoded. Please ensure your request is encoded as utf-8 and try again.');
        $self->res->status(400);
    };
}

sub execute {
    my $c = shift;
    return do {
        local $SIG{__WARN__} = sub {
            my $warning = shift;
            chomp $warning;
            $c->log->warn($c->req->method . " " . $c->req->uri . " caused a warning: " . $warning);
        };
        $c->next::method(@_);
    };
}

sub finalize_error {
    my $c = shift;

    $c->next::method(@_);

    $c->model('MB')->context->connector->disconnect;

    if (!$c->debug && scalar @{ $c->error }) {
        $c->stash->{errors} = $c->error;
        $c->stash->{template} = 'main/500.tt';
        $c->stash->{stack_trace} = $c->_stacktrace;
        $c->clear_errors;
        $c->res->{body} = 'clear';
        $c->view('Default')->process($c);
        $c->res->{body} = encode('utf-8', $c->res->{body});
    }
}

=head1 NAME

MusicBrainz::Server - Catalyst-based MusicBrainz server

=head1 SYNOPSIS

    script/musicbrainz_server.pl

=head1 LICENSE

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
