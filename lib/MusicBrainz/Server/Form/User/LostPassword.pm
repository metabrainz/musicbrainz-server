package MusicBrainz::Server::Form::User::LostPassword;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'lostpassword' );

has_field 'username' => (
    type => 'Text',
    required => 1,
);

has_field 'email' => (
    type => 'Email',
    required => 1,
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
