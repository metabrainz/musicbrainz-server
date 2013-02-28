package MusicBrainz::Server::Form::Application;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'application' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'oauth_type' => (
    type => 'Select',
    required => 1,
);

has_field 'oauth_redirect_uri' => (
    type => '+MusicBrainz::Server::Form::Field::OAuthRedirectURI'
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
            $self->field('oauth_redirect_uri')->add_error('Redirect URL must be entered for web applications.');
        }
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 Lukas Lalinsky

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
