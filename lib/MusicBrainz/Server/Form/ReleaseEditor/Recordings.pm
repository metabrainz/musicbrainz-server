package MusicBrainz::Server::Form::ReleaseEditor::Recordings;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'rec_mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'rec_mediums.medium_id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'rec_mediums.associations' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'rec_mediums.associations.gid' => ( type => 'Hidden' );
has_field 'rec_mediums.associations.confirmed' => ( type => 'Hidden', required => 1 );
has_field 'rec_mediums.associations.edit_sha1' => ( type => 'Hidden' );
has_field 'rec_mediums.associations.update_recording' => ( type => 'Checkbox' );
has_field 'infer_durations' => ( type => 'Checkbox' );
has_field 'propagate_all_track_changes' => ( type => 'Checkbox' );

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
