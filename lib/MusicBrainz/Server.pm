package MusicBrainz::Server;

use Moose;
BEGIN { extends 'Catalyst' }

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::CacheManager;
use MusicBrainz::Server::Context;
use UNIVERSAL::require;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

my @args = qw/
Static::Simple

StackTrace

I18N::Gettext

Session
Session::State::Cookie

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
    "View::Default" => {
        FILTERS => {
            'release_date' => \&MusicBrainz::Server::Filters::release_date,
            'format_length' => \&MusicBrainz::Server::Filters::format_length,
            'format_distance' => \&MusicBrainz::Server::Filters::format_distance,
            'format_wikitext' => \&MusicBrainz::Server::Filters::format_wikitext,
        },
        RECURSION => 1,
        TEMPLATE_EXTENSION => '.tt',
        PLUGIN_BASE => 'MusicBrainz::Server::Plugin',
        PRE_PROCESS => [
            'components/common-macros.tt',
            'components/forms.tt',
        ],
    },
);

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
        }
    }
};

__PACKAGE__->config->{form} = {
    no_fillin       => 1,
    pre_load_forms  => 1,
    form_name_space => 'MusicBrainz::Server::Forms',
};

if (&DBDefs::_RUNNING_TESTS) {
    push @args, "Session::Store::Dummy";
}
else {
    push @args, &DBDefs::SESSION_STORE;
    __PACKAGE__->config->{session} = &DBDefs::SESSION_STORE_ARGS;
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

# Start the application
__PACKAGE__->setup(@args);

has '_mb_cache_manager' => (
    is => 'rw',
    lazy => 1,
    builder => '_build__mb_cache_manager'
);

has '_mb_context' => (
    is => 'rw',
    lazy_build => 1,
    handles => [ 'mb', 'dbh', 'raw_mb', 'raw_dbh', 'cache' ]
);

sub _build__mb_cache_manager
{
    my $opts = &DBDefs::CACHE_MANAGER_OPTIONS;
    if (&DBDefs::_RUNNING_TESTS) {
        $opts = {
            profiles => {
                null => {
                    class => 'Cache::Null',
                    wrapped => 1,
                },
            },
            default_profile => 'null',
        };
    }
    return MusicBrainz::Server::CacheManager->new($opts);
}

sub _build__mb_context
{
    my $self = shift;
    return MusicBrainz::Server::Context->new(
        cache_manager => $self->_mb_cache_manager);
}

after 'dispatch' => sub
{
    my $self = shift;
    if ($self->_has_mb_context) {
        $self->_mb_context->logout;
        $self->_clear_mb_context;
    }
};

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
    $form_name->require;
    my $form = $form_name->new(%args, ctx => $c);
    $c->stash( $stash => $form );
    return $form;
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
