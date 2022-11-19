package MusicBrainz::Server::Form::Admin::Attributes::Language;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Constants qw( :language_frequency );
use MusicBrainz::Server::Translation qw( lp );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( iso_code_1 iso_code_2b iso_code_2t iso_code_3 name frequency ) }

has '+name' => ( default => 'attr' );

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'iso_code_1' => (
    type => 'Text',
    maxlength => 2,
);

has_field 'iso_code_2b' => (
    type => 'Text',
    maxlength => 3,
);

has_field 'iso_code_2t' => (
    type => 'Text',
    maxlength => 3,
);

has_field 'iso_code_3' => (
    type => 'Text',
    required  => 1,
    maxlength => 3,
);

has_field 'frequency' => (
    type => 'Select',
    required => 1
);

sub options_frequency {
    return [
        $LANGUAGE_FREQUENCY_HIDDEN, lp('Hidden', 'language optgroup'),
        $LANGUAGE_FREQUENCY_OTHER, lp('Other', 'language optgroup'),
        $LANGUAGE_FREQUENCY_FREQUENT, lp('Frequently used', 'language optgroup'),
    ]
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
