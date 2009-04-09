package MusicBrainz::Server;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst;
use DBDefs;
use MusicBrainz;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

my @args = qw/
ConfigLoader
Static::Simple

StackTrace

I18N::Gettext

Session
Session::State::Cookie

Authentication

Cache
Cache::Memcached
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
            'mb_date' => \&MusicBrainz::Server::Filters::date,
            'release_date' => \&MusicBrainz::Server::Filters::release_date,
        },
        RECURSION => 1,
        TEMPLATE_EXTENSION => '.tt',
        PLUGIN_BASE => 'MusicBrainz::Server::Plugin',
        PRE_PROCESS => 'components/common-macros.tt',
    },
);

__PACKAGE__->config->{'Plugin::Cache'}{backend} = {
    class   => "Cache::Memcached::libmemcached",
    servers => &DBDefs::CACHE_OPTIONS->{servers},
    debug   => &DBDefs::CACHE_OPTIONS->{debug},
};

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
        "musicbrainz.org" => { 
            use_session => 0,
            credential => { 
                class =>          'HTTP',
                type  =>          'digest',
                password_type  => 'clear',
                password_field => 'password',
                username_field => 'username'
            },
            store => {
                class => '+MusicBrainz::Server::Authentication::WebService'
            }
        }
    }
};

__PACKAGE__->config->{form} = {
    no_fillin       => 1,
    pre_load_forms  => 1,
    form_name_space => 'MusicBrainz::Server::Forms',
};

push @args, &DBDefs::SESSION_STORE;

__PACKAGE__->config->{session} = &DBDefs::SESSION_STORE_ARGS;

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

# Start the application
__PACKAGE__->setup(@args);

sub dispatch {
    my $self = shift;
    $self->mb_logout;
    $self->NEXT::dispatch(@_);
    $self->mb_logout;
}

sub mb {
    my $self = shift;
    if (!defined($self->{mb})) {
        $self->{mb} = MusicBrainz->new;
        $self->{mb}->Login;
    }
    return $self->{mb};
}

sub mb_logout {
    my $self = shift;
    if (defined($self->{mb})) {
        $self->{mb}->Logout;
        $self->{mb} = undef;
    }
}

sub entity_url
{
    my ($self, $entity, $action, @args) = @_;

    # Determine the type of the entity - thus which control to use
    my $type = $entity->entity_type;
    $action ||= 'show';

    # Now find the controller
    my $controller = $self->controller(ucfirst($type))
        or die "$type is not a valid type";

    # Lookup the action
    my $catalyst_action = $controller->action_for($action)
        or die "$action is not a valid action for the controller $type";

    # Parse capture arguments.
    my $id = $entity->mbid || $entity->id;

    return $self->uri_for($catalyst_action, [ $id ], @args);
}

=head2 form_posted

This returns true if the request was a post request.

=cut

sub form_posted
{
    my $c = shift;

    return $c->req->method eq 'POST';
}


=head1 NAME

musicbrainz - Catalyst based application

=head1 SYNOPSIS

    script/musicbrainz_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<musicbrainz::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
