package MusicBrainz::Server::Form::ReleaseEditor::EditNote;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation 'l';

extends 'MusicBrainz::Server::Form::Step';
with 'MusicBrainz::Server::Form::Role::EditNote';

# Slightly hackish, but lets us know if we're editing an existing release or not
has_field 'id' => ( type => 'Integer' );

has '+requires_edit_note' => (
    lazy => 1,
    default => sub { !shift->field('id')->value }
);

sub requires_edit_note_text {
    l("You must provide an edit note when adding a release. Even just a URL or something like “CD in hand” helps!")
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
