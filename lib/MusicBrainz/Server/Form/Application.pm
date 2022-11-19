package MusicBrainz::Server::Form::Application;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Constants qw( :oauth_redirect_uri_re );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'application' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
    default => '',
);

has_field 'oauth_type' => (
    type => 'Select',
    required => 1,
    default => 'web',
);

has_field 'oauth_redirect_uri' => (
    type => '+MusicBrainz::Server::Form::Field::OAuthRedirectURI',
    default => '',
);

sub options_oauth_type
{
    my ($self) = @_;

    return [
        { value => 'web', label => 'Web Application' },
        { value => 'installed', label => 'Installed Application' },
    ];
}

sub validate
{
    my ($self) = @_;

    if ($self->field('oauth_type')->value eq 'web') {
        if (!$self->field('oauth_redirect_uri')->value) {
            $self->field('oauth_redirect_uri')->add_error(
                l('Redirect URL must be entered for web applications.')
            );
        } elsif ($self->field('oauth_redirect_uri')->value !~ $OAUTH_WEB_APP_REDIRECT_URI_RE) {
            $self->field('oauth_redirect_uri')->add_error(
                l('Redirect URL scheme must be either <code>http</code> or ' .
                  '<code>https</code> for web applications.')
            );
        }
    } elsif ($self->field('oauth_redirect_uri')->value) {
        if ($self->field('oauth_redirect_uri')->value !~ $OAUTH_INSTALLED_APP_REDIRECT_URI_RE) {
            $self->field('oauth_redirect_uri')->add_error(
                l('Redirect URL scheme must be a reverse-DNS string, as in ' .
                  '<code>org.example.app://auth</code>, for installed applications.')
            );
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
