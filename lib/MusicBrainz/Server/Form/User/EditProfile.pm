package MusicBrainz::Server::Form::User::EditProfile;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::UserProfile';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'profile' );

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
