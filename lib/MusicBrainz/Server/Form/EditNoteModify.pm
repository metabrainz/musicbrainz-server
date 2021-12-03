package MusicBrainz::Server::Form::EditNoteModify;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-note-modify' );

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );
has_field 'reason' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1,
);
has_field 'text' => (
    type => 'Text',
    required => 1,
    input_without_param => '',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
