package MusicBrainz::Server;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use MusicBrainz;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/
-Debug
ConfigLoader
Static::Simple

StackTrace

Session
Session::State::Cookie
Session::Store::FastMmap

FormBuilder

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
    "View::Default" => {
        FILTERS => {
            'mb_date' => \&MusicBrainz::Server::Filters::date,
            'release_date' => \&MusicBrainz::Server::Filters::release_date,
        }
    }
);

__PACKAGE__->config->{'Plugin::Authentication'} = {
    default_realm => 'moderators',
    realms => {
        moderators => {
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

# Start the application
__PACKAGE__->setup();

sub mb
{
    my $self = shift;

    unless(defined $self->{_mb} && defined $self->{_mb}->{DBH})
    {
        my $mb = new MusicBrainz;
        $mb->Login();
        $self->{_mb} = $mb
    }   

    return $self->{_mb};
}

sub form_posted {
    return shift->request->method eq 'POST'
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
