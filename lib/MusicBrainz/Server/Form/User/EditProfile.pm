package MusicBrainz::Server::Form::User::EditProfile;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'profile' );

has_field 'biography' => (
    type => 'Text',
);

has_field 'website' => (
    type      => 'Text',
    maxlength => 255,
    apply     => [ {
        check => sub { MusicBrainz::Server::Validation->IsValidURL($_[0]) },
        message => l('Invalid URL format'),
    } ],
);

has_field 'email' => (
    type => 'Email',
);

1;

=head1 COPYRIGHT

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
