package MusicBrainz::Server::Form::Vote;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation qw( is_valid_edit_note );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'enter-vote' );

has_field 'vote' => (
    type => 'Repeatable',
    required => 1,
);

has_field 'vote.edit_id' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
);

has_field 'vote.vote' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
);

has_field 'vote.edit_note' => (
    type => 'Text',
    validate_method => \&validate_note,
);

sub validate_note {
    my ($self, $field) = @_;

    if (!is_valid_edit_note($field->value)) {
        $field->value(undef);
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
