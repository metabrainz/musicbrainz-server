package MusicBrainz::Server::Form::User::EditProfile;

use HTML::FormHandler::Moose;
use List::MoreUtils qw( any all );
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

has_field 'gender_id' => (
    type => 'Select',
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'birth_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate'
);

has_field 'languages' => (
    type => 'Repeatable'
);

has_field 'languages.language_id' => (
    type => 'Select',
    required => 1
);

has_field 'languages.fluency' => (
    type => 'Select',
    required => 1
);

sub options_gender_id { shift->_select_all('Gender') }
sub options_country_id { shift->_select_all('Country') }
sub options_languages_language_id { shift->_select_all('Language') }
sub options_languages_fluency {
    return [
        'basic', l('Basic'),
        'intermediate', l('Intermediate'),
        'advanced', l('Advanced'),
        'native', l('Native')
    ]
}

sub validate_birth_date {
    my ($self, $field) = @_;
    my @date_components = values %{ $field->value };
    if ((any { defined } @date_components) &&
            !(all { defined } @date_components)) {
        return $field->add_error(l('You must supply a complete birth date'));
    }
}

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
