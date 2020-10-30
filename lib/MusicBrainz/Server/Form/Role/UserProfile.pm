package MusicBrainz::Server::Form::Role::UserProfile;

use HTML::FormHandler::Moose::Role;
use List::MoreUtils qw( any all );
use MusicBrainz::Server::Form::Utils qw( language_options select_options_tree validate_username );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_url );

has_field 'username' => (
    type      => 'Text',
    required  => 1,
    maxlength => 64,
    validate_method => \&validate_username,
);

has_field 'biography' => (
    type => 'Text',
);

has_field 'website' => (
    type      => 'Text',
    maxlength => 255,
    apply     => [ {
        check => sub { is_valid_url($_[0]) },
        message => sub { l('Invalid URL format') },
    } ],
);

has_field 'email' => (
    type => 'Email',
);

has_field 'skip_verification' => (
    type => 'Boolean',
);

has_field 'gender_id' => (
    type => 'Select',
);

has_field 'area_id'   => ( type => 'Hidden' );
has_field 'area'      => (
    type => '+MusicBrainz::Server::Form::Field::Area'
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

sub options_gender_id { select_options_tree(shift->ctx, 'Gender') }
sub options_languages_language_id { return language_options(shift->ctx) }
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

    my $year = $field->field('year')->value;
    my $month = $field->field('month')->value;
    my $day = $field->field('day')->value;

    my @date_components = ($year, $month, $day);
    if ((any { defined } @date_components) &&
            !(all { defined } @date_components)) {
        return $field->add_error(l('You must supply a complete birth date for us to display your age.'));
    }

    if ($field->field('year')->value < 1900) {
        $field->field('year')->add_error(l('Birth year must be after 1900'));
    }

    return $field->add_error(l("invalid date")) unless Date::Calc::check_date($year, $month, $day);
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
