package MusicBrainz::Server::Form::EditNoteModify;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_edit_note );

has '+name' => ( default => 'edit-note-modify' );

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );
has_field 'reason' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1,
);
has_field 'text' => (
    type => 'Text',
    input_without_param => '',
);

sub validate
{
    my ($self) = @_;

    unless ($self->field('cancel')->input) {
        if (!defined $self->field('text')->value) {
            $self->field('text')->add_error(l('You must provide an edit note. If you want to blank the note, please remove it instead.'));
        } elsif (!is_valid_edit_note($self->field('text')->value)) {
            $self->field('text')->add_error(l('Your edit note seems to have no actual content. Please provide a note that will be helpful to your fellow editors!'));
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
