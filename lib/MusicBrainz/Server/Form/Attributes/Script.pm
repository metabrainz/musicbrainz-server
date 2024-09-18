package MusicBrainz::Server::Form::Attributes::Script;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Constants qw( :script_frequency );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( iso_code iso_number name frequency ) }

has '+name' => ( default => 'attr' );

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255,
);

has_field 'iso_code' => (
    type => 'Text',
    required  => 1,
    maxlength => 4,
);

has_field 'iso_number' => (
    type => 'Text',
    required  => 1,
    maxlength => 3,
);

has_field 'frequency' => (
    type => 'Select',
    required => 1,
);

sub options_frequency {
    return [
        $SCRIPT_FREQUENCY_HIDDEN, 'Hidden',
        $SCRIPT_FREQUENCY_UNCOMMON, 'Other (Uncommon)',
        $SCRIPT_FREQUENCY_OTHER, 'Other',
        $SCRIPT_FREQUENCY_FREQUENT, 'Frequently used',
    ];
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
