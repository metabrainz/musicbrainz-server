package MusicBrainz::Server::Form::Admin::EditUser;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::UserProfile';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'edit-user' );

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

has_field 'banner_editor' => (
    type => 'Boolean',
);

has_field 'mbid_submitter' => (
    type => 'Boolean',
);

has_field 'account_admin' => (
    type => 'Boolean',
);

has_field 'editing_disabled' => (
    type => 'Boolean',
);

has_field 'adding_notes_disabled' => (
    type => 'Boolean',
);

has_field 'spammer' => (
    type => 'Boolean',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Pavan Chander

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
