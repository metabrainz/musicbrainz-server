package MusicBrainz::Server::Form::User::AdjustFlags;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'flags' );

has_field 'submitted' => (
    type => 'Integer',
);

has_field 'auto_editor' => (
    type => 'Boolean',
);

has_field 'bot' => (
    type => 'Boolean',
);

has_field 'untrusted' => (
    type => 'Boolean',
);

has_field 'link_editor' => (
    type => 'Boolean',
);

has_field 'location_editor' => (
    type => 'Boolean',
);

has_field 'no_nag' => (
    type => 'Boolean',
);

has_field 'wiki_transcluder' => (
    type => 'Boolean',
);

has_field 'mbid_submitter' => (
    type => 'Boolean',
);

has_field 'account_admin' => (
    type => 'Boolean',
);

1;

=head1 COPYRIGHT

Copyright (C) 2010 Pavan Chander

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
